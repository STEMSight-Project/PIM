/**
 * Unit tests for hlsService
 * Tests HLS service methods for playlist, segments, and status polling
 */

import { api } from "@/services/api";
import { HLSRecordingStatus, hlsService } from "@/services/hlsService";
import { waitFor } from "@testing-library/react";

// Mock the api module
jest.mock("@/services/api");

const mockApi = api as jest.Mocked<typeof api>;

describe("hlsService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("getPlaylistUrl", () => {
    it("should return correct playlist URL", () => {
      const roomId = "AMB-001-ROOM-001";
      const url = hlsService.getPlaylistUrl(roomId);

      expect(url).toContain("/videos/hls/");
      expect(url).toContain(roomId);
      expect(url).toContain("playlist.m3u8");
    });
  });

  describe("getSegmentUrl", () => {
    it("should return correct segment URL", () => {
      const sessionId = "test-session";
      const segmentName = "segment-001.ts";
      const url = hlsService.getSegmentUrl(sessionId, segmentName);

      expect(url).toContain("/videos/hls/");
      expect(url).toContain(sessionId);
      expect(url).toContain(segmentName);
    });
  });

  describe("getRecordingStatus", () => {
    it("should fetch recording status successfully", async () => {
      const mockStatus: HLSRecordingStatus = {
        room_id: "AMB-001-ROOM-001",
        session_id: "test-session",
        status: "recording",
        is_active: true,
        duration: 120,
        segment_count: 4,
        hls_ready: true,
        playlist_url: "/videos/hls/AMB-001-ROOM-001/playlist.m3u8",
      };

      mockApi.get.mockResolvedValue({
        data: mockStatus,
        error: null,
      });

      const result = await hlsService.getRecordingStatus("AMB-001-ROOM-001");

      expect(result).toEqual(mockStatus);
      expect(mockApi.get).toHaveBeenCalledWith(
        "/videos/hls/AMB-001-ROOM-001/status"
      );
    });

    it("should return null on error", async () => {
      mockApi.get.mockResolvedValue({
        data: null,
        error: "Network error",
      });

      const result = await hlsService.getRecordingStatus("AMB-001-ROOM-001");

      expect(result).toBeNull();
    });

    it("should handle exception", async () => {
      mockApi.get.mockRejectedValue(new Error("Network failure"));

      const result = await hlsService.getRecordingStatus("AMB-001-ROOM-001");

      expect(result).toBeNull();
    });
  });

  describe("listRecordings", () => {
    it("should fetch recordings list successfully", async () => {
      const mockRecordings = [
        {
          room_id: "AMB-001-ROOM-001",
          session_id: "session-1",
          segment_count: 4,
          file_size: 1024000,
          duration: 120,
          created_at: "2025-10-28T10:00:00Z",
          playlist_url: "/videos/hls/AMB-001-ROOM-001/playlist.m3u8",
        },
      ];

      mockApi.get.mockResolvedValue({
        data: mockRecordings,
        error: null,
      });

      const result = await hlsService.listRecordings();

      expect(result).toEqual(mockRecordings);
      expect(mockApi.get).toHaveBeenCalledWith("/videos/hls/list");
    });

    it("should return empty array on error", async () => {
      mockApi.get.mockResolvedValue({
        data: null,
        error: "Error",
      });

      const result = await hlsService.listRecordings();

      expect(result).toEqual([]);
    });
  });

  describe("deleteRecording", () => {
    it("should delete recording successfully", async () => {
      mockApi.delete.mockResolvedValue({
        data: { success: true },
        error: null,
      });

      const result = await hlsService.deleteRecording("AMB-001-ROOM-001");

      expect(result).toBe(true);
      expect(mockApi.delete).toHaveBeenCalledWith(
        "/videos/hls/AMB-001-ROOM-001"
      );
    });

    it("should return false on error", async () => {
      mockApi.delete.mockResolvedValue({
        data: null,
        error: "Delete failed",
      });

      const result = await hlsService.deleteRecording("AMB-001-ROOM-001");

      expect(result).toBe(false);
    });
  });

  describe("isHLSReady", () => {
    it("should return true when HLS is ready", async () => {
      mockApi.get.mockResolvedValue({
        data: { hls_ready: true },
        error: null,
      });

      const result = await hlsService.isHLSReady("AMB-001-ROOM-001");

      expect(result).toBe(true);
    });

    it("should return false when HLS is not ready", async () => {
      mockApi.get.mockResolvedValue({
        data: { hls_ready: false },
        error: null,
      });

      const result = await hlsService.isHLSReady("AMB-001-ROOM-001");

      expect(result).toBe(false);
    });

    it("should return false on error", async () => {
      mockApi.get.mockResolvedValue({
        data: null,
        error: "Error",
      });

      const result = await hlsService.isHLSReady("AMB-001-ROOM-001");

      expect(result).toBe(false);
    });
  });

  describe("pollRecordingStatus", () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it("should poll status and call callback on segment change", async () => {
      const callback = jest.fn();
      const mockStatus1: HLSRecordingStatus = {
        room_id: "AMB-001-ROOM-001",
        status: "recording",
        is_active: true,
        segment_count: 2,
      };
      const mockStatus2: HLSRecordingStatus = {
        room_id: "AMB-001-ROOM-001",
        status: "recording",
        is_active: true,
        segment_count: 3, // Changed
      };

      let callCount = 0;
      mockApi.get.mockImplementation(async () => {
        callCount++;
        return {
          data: callCount === 1 ? mockStatus1 : mockStatus2,
          error: null,
        };
      });

      const cleanup = hlsService.pollRecordingStatus(
        "AMB-001-ROOM-001",
        callback,
        1000
      );

      // First poll (initial)
      await waitFor(() => {
        expect(callback).toHaveBeenCalledWith(mockStatus1);
      });

      // Advance timer
      jest.advanceTimersByTime(1000);

      // Second poll (segment count changed)
      await waitFor(() => {
        expect(callback).toHaveBeenCalledWith(mockStatus2);
        expect(callback).toHaveBeenCalledTimes(2);
      });

      cleanup();
    });

    it("should not call callback when segment count unchanged", async () => {
      const callback = jest.fn();
      const mockStatus: HLSRecordingStatus = {
        room_id: "AMB-001-ROOM-001",
        status: "recording",
        is_active: true,
        segment_count: 2,
      };

      mockApi.get.mockResolvedValue({
        data: mockStatus,
        error: null,
      });

      const cleanup = hlsService.pollRecordingStatus(
        "AMB-001-ROOM-001",
        callback,
        1000
      );

      // First poll
      await waitFor(() => {
        expect(callback).toHaveBeenCalledTimes(1);
      });

      // Advance timer
      jest.advanceTimersByTime(1000);
      await Promise.resolve();

      // Second poll - same segment count, no callback
      expect(callback).toHaveBeenCalledTimes(1);

      cleanup();
    });

    it("should stop polling when recording is not active", async () => {
      const callback = jest.fn();
      const mockStatus: HLSRecordingStatus = {
        room_id: "AMB-001-ROOM-001",
        status: "completed",
        is_active: false,
        segment_count: 5,
      };

      mockApi.get.mockResolvedValue({
        data: mockStatus,
        error: null,
      });

      const cleanup = hlsService.pollRecordingStatus(
        "AMB-001-ROOM-001",
        callback,
        1000
      );

      await Promise.resolve();

      // Advance timer - should not poll again
      jest.advanceTimersByTime(1000);
      await Promise.resolve();

      expect(callback).toHaveBeenCalledTimes(1);

      cleanup();
    });

    it("should cleanup polling when cleanup function is called", async () => {
      const callback = jest.fn();

      mockApi.get.mockResolvedValue({
        data: { segment_count: 1, is_active: true },
        error: null,
      });

      const cleanup = hlsService.pollRecordingStatus(
        "AMB-001-ROOM-001",
        callback,
        1000
      );

      // Stop polling immediately
      cleanup();

      // Advance timer
      jest.advanceTimersByTime(5000);
      await Promise.resolve();

      // Should not have called more than once
      expect(callback).toHaveBeenCalledTimes(0);
    });
  });
});
