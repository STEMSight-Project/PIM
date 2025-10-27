/**
 * HLS Service
 *
 * Provides methods for interacting with HLS (HTTP Live Streaming) endpoints.
 * Handles playlist fetching, segment loading, and recording status checks.
 */

import { api } from "./api";

export interface HLSRecordingStatus {
  room_id: string;
  session_id?: string;
  status: "recording" | "completed" | "unknown";
  is_active: boolean;
  duration?: number;
  segment_count?: number;
  hls_ready?: boolean;
  playlist_url?: string;
  recording_path?: string;
  file_size?: number;
}

export interface HLSRecordingInfo {
  room_id: string;
  session_id?: string;
  session_name?: string;
  ambulance_number?: string;
  segment_count: number;
  file_size: number;
  duration?: number;
  created_at: string;
  playlist_url: string;
}

class HLSService {
  private baseUrl: string;

  constructor() {
    // Get base URL from environment or default to localhost
    this.baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
  }

  /**
   * Get the full URL for an HLS playlist
   */
  getPlaylistUrl(roomId: string): string {
    return `${this.baseUrl}/videos/hls/${roomId}/playlist.m3u8`;
  }

  /**
   * Get the full URL for an HLS segment
   */
  getSegmentUrl(sessionId: string, segmentName: string): string {
    return `${this.baseUrl}/videos/hls/${sessionId}/${segmentName}`;
  }

  /**
   * Get recording status
   *
   * @param sessionId - The session ID to check
   * @returns Recording status information
   */
  async getRecordingStatus(
    sessionId: string
  ): Promise<HLSRecordingStatus | null> {
    try {
      const response = await api.get<HLSRecordingStatus>(
        `/videos/hls/${sessionId}/status`
      );

      if (response.error) {
        console.error("Error fetching recording status:", response.error);
        return null;
      }

      return response.data;
    } catch (error) {
      console.error("Error fetching recording status:", error);
      return null;
    }
  }

  /**
   * List all available recordings
   *
   * @returns Array of recording information
   */
  async listRecordings(): Promise<HLSRecordingInfo[]> {
    try {
      const response = await api.get<HLSRecordingInfo[]>("/videos/hls/list");

      if (response.error) {
        console.error("Error listing recordings:", response.error);
        return [];
      }

      return response.data || [];
    } catch (error) {
      console.error("Error listing recordings:", error);
      return [];
    }
  }

  /**
   * Delete a recording
   *
   * @param sessionId - The session ID to delete
   * @returns Success status
   */
  async deleteRecording(sessionId: string): Promise<boolean> {
    try {
      const response = await api.delete(`/videos/hls/${sessionId}`);

      if (response.error) {
        console.error("Error deleting recording:", response.error);
        return false;
      }

      return true;
    } catch (error) {
      console.error("Error deleting recording:", error);
      return false;
    }
  }

  /**
   * Check if HLS is ready for playback
   *
   * @param sessionId - The session ID to check
   * @returns True if HLS is ready (has playlist and segments)
   */
  async isHLSReady(sessionId: string): Promise<boolean> {
    const status = await this.getRecordingStatus(sessionId);
    return status?.hls_ready || false;
  }

  /**
   * Wait for HLS to be ready
   *
   * Polls the status endpoint until HLS is ready or timeout is reached.
   *
   * @param sessionId - The session ID to wait for
   * @param timeoutMs - Maximum time to wait in milliseconds (default: 30000)
   * @param intervalMs - Polling interval in milliseconds (default: 1000)
   * @returns True if HLS became ready, false if timeout
   */
  async waitForHLSReady(
    sessionId: string,
    timeoutMs: number = 30000,
    intervalMs: number = 1000
  ): Promise<boolean> {
    const startTime = Date.now();

    while (Date.now() - startTime < timeoutMs) {
      const ready = await this.isHLSReady(sessionId);

      if (ready) {
        return true;
      }

      // Wait before next check
      await new Promise((resolve) => setTimeout(resolve, intervalMs));
    }

    return false;
  }

  /**
   * Poll recording status
   *
   * Continuously polls the status endpoint and calls a callback with updates.
   * Returns a cleanup function to stop polling.
   *
   * @param sessionId - The session ID to monitor
   * @param callback - Function to call with status updates
   * @param intervalMs - Polling interval in milliseconds (default: 2000)
   * @returns Cleanup function to stop polling
   */
  pollRecordingStatus(
    sessionId: string,
    callback: (status: HLSRecordingStatus | null) => void,
    intervalMs: number = 2000
  ): () => void {
    let isPolling = true;

    const poll = async () => {
      while (isPolling) {
        const status = await this.getRecordingStatus(sessionId);
        callback(status);

        // Stop polling if recording is completed
        if (status && !status.is_active) {
          isPolling = false;
          break;
        }

        await new Promise((resolve) => setTimeout(resolve, intervalMs));
      }
    };

    poll();

    // Return cleanup function
    return () => {
      isPolling = false;
    };
  }
}

// Export singleton instance
export const hlsService = new HLSService();
export default hlsService;
