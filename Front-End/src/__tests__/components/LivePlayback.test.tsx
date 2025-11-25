/**
 * Unit tests for HLSPlayer (Live Playback)
 * Covers: video element, loading state, error overlay, live indicator, status bar
 */

import React from "react";
import { HLSPlayer } from "@/components/HLSPlayer";
import { useHLS } from "@/hooks/useHLS";
import "@testing-library/jest-dom";
import { render, screen } from "@testing-library/react";

jest.mock("@/hooks/useHLS");

const mockUseHLS = useHLS as jest.MockedFunction<typeof useHLS>;

describe("HLSPlayer (Live Playback)", () => {
  const baseHLS = {
    videoRef: { current: null },
    hls: null,
    isLoading: false,
    error: null,
    status: "Ready",
    recordingStatus: null,
    isHLSReady: true,
    reload: jest.fn(),
    play: jest.fn().mockResolvedValue(undefined),
    pause: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseHLS.mockReturnValue(baseHLS as any);
  });

  it("renders a video element", () => {
    render(<HLSPlayer roomId={"AMB-001-ROOM-001"} showControls={true} />);

    const videos = document.querySelectorAll("video");
    expect(videos.length).toBeGreaterThan(0);
  });

  it("shows loading overlay when isLoading is true", () => {
    mockUseHLS.mockReturnValue({ ...baseHLS, isLoading: true, status: "Connecting to live stream..." } as any);

    render(<HLSPlayer roomId={"AMB-001-ROOM-001"} />);

    expect(screen.getByText(/Connecting to live stream/i)).toBeInTheDocument();
  });

  it("shows error overlay when error is present and exposes Retry", () => {
    mockUseHLS.mockReturnValue({ ...baseHLS, error: "Playlist not found" } as any);

    render(<HLSPlayer roomId={"AMB-001-ROOM-001"} />);

    expect(screen.getByText(/Playlist not found/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /retry/i })).toBeInTheDocument();
  });

  it("shows LIVE indicator when recordingStatus.is_active is true", () => {
    mockUseHLS.mockReturnValue({
      ...baseHLS,
      recordingStatus: { is_active: true, room_id: "AMB-001-ROOM-001" },
    } as any);

    render(<HLSPlayer roomId={"AMB-001-ROOM-001"} showStats={true} />);

    expect(screen.getByText(/LIVE/i)).toBeInTheDocument();
  });

  it("displays status bar text when ready", () => {
    mockUseHLS.mockReturnValue({ ...baseHLS, status: "Ready" } as any);

    render(<HLSPlayer roomId={"AMB-001-ROOM-001"} />);

    expect(screen.getByText(/Ready/i)).toBeInTheDocument();
  });
});
