/**
 * useHLSSegmentEvents Hook
 *
 * Listens for real-time HLS segment events via Server-Sent Events (SSE).
 * Automatically reloads HLS player when new segments are available.
 */

import Hls from "hls.js";
import { useEffect, useRef, useState } from "react";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export interface SegmentEvent {
  type: "connected" | "new_segment" | "heartbeat" | "error";
  room_id: string;
  segment_name?: string;
  segment_number?: number;
  segment_path?: string;
  file_size?: number;
  timestamp: string;
  error?: string;
}

export interface UseHLSSegmentEventsOptions {
  /** Room ID to monitor */
  roomId: string | null;

  /** HLS.js instance to reload on new segments */
  hls: Hls | null;

  /** Enable auto-reload when new segment detected */
  autoReload?: boolean;

  /** Enable debug logging */
  debug?: boolean;

  /** Callback when new segment detected */
  onSegmentAdded?: (event: SegmentEvent) => void;

  /** Callback when connected to SSE */
  onConnected?: (event: SegmentEvent) => void;

  /** Callback on SSE error */
  onError?: (error: string) => void;
}

export interface UseHLSSegmentEventsReturn {
  /** Whether SSE is connected */
  isConnected: boolean;

  /** Connection error if any */
  error: string | null;

  /** Latest segment event */
  lastSegment: SegmentEvent | null;

  /** Total segments received */
  segmentCount: number;

  /** Connection status message */
  status: string;

  /** Manually reconnect SSE */
  reconnect: () => void;
}

export function useHLSSegmentEvents(
  options: UseHLSSegmentEventsOptions
): UseHLSSegmentEventsReturn {
  const {
    roomId,
    hls,
    autoReload = true,
    debug = false,
    onSegmentAdded,
    onConnected,
    onError,
  } = options;

  const eventSourceRef = useRef<EventSource | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastSegment, setLastSegment] = useState<SegmentEvent | null>(null);
  const [segmentCount, setSegmentCount] = useState(0);
  const [status, setStatus] = useState<string>("Disconnected");

  /**
   * Connect to SSE endpoint
   */
  const connect = () => {
    if (!roomId) {
      if (debug) {
        ("[useHLSSegmentEvents] No room ID provided, skipping connection");
      }
      return;
    }

    // Clean up existing connection
    disconnect();

    const sseUrl = `${API_BASE_URL}/videos/hls/segments/${roomId}/events`;

    if (debug) {
    }

    try {
      const eventSource = new EventSource(sseUrl);
      eventSourceRef.current = eventSource;

      setStatus("Connecting...");
      setError(null);

      // Event: SSE connection opened
      eventSource.onopen = () => {
        if (debug) {
        }
        setIsConnected(true);
        setStatus("Connected");
        setError(null);
      };

      // Event: Message received
      eventSource.onmessage = (event) => {
        try {
          const data: SegmentEvent = JSON.parse(event.data);

          if (debug) {
          }

          switch (data.type) {
            case "connected":
              // Initial connection confirmation
              setStatus(`Connected to room ${data.room_id}`);
              if (onConnected) {
                onConnected(data);
              }
              break;

            case "new_segment":
              // New HLS segment available
              setLastSegment(data);
              setSegmentCount((prev) => prev + 1);
              setStatus(
                `New segment ${data.segment_number || "unknown"} available`
              );
              if (debug) {
                console.log(
                  `[useHLSSegmentEvents] New segment: ${data.segment_name} (${data.file_size} bytes)`
                );
              }

              // Callback
              if (onSegmentAdded) {
                onSegmentAdded(data);
              }

              // Auto-reload HLS player playlist (smooth, non-disruptive)
              if (autoReload && hls && hls.media) {
                const video = hls.media;
                const currentTime = video.currentTime;
                const duration = video.duration || 0;
                const isPlaying = !video.paused;

                // Check if we're near the live edge (within 15 seconds)
                const timeBehindLive = duration - currentTime;
                const isNearLive = timeBehindLive < 15;

                if (debug) {
                  console.log(
                    `[useHLSSegmentEvents] Auto-reload check - Time: ${currentTime.toFixed(
                      2
                    )}s, Duration: ${duration.toFixed(
                      2
                    )}s, Behind: ${timeBehindLive.toFixed(
                      2
                    )}s, Near Live: ${isNearLive}`
                  );
                }

                // ALWAYS reload playlist when new segment arrives
                // This ensures the player knows about new segments
                if (debug) {
                  console.log(
                    "[useHLSSegmentEvents] Forcing playlist reload for new segment..."
                  );
                }

                try {
                  // Force playlist reload by resetting level and restarting load
                  // This is the CORRECT way to refresh playlist in HLS.js
                  hls.loadLevel = -1; // Reset to auto quality selection

                  // Stop and restart loading to fetch updated playlist
                  hls.stopLoad();
                  hls.startLoad(currentTime); // Start from current position

                  if (debug) {
                    console.log(
                      "[useHLSSegmentEvents] Playlist reload triggered successfully"
                    );
                  }

                  // Ensure video continues playing if it was playing
                  if (isPlaying && video.paused) {
                    video.play().catch((err) => {
                      if (debug) {
                        console.warn(
                          "[useHLSSegmentEvents] Failed to resume playback:",
                          err
                        );
                      }
                    });
                  }
                } catch (err) {
                  if (debug) {
                    console.error(
                      "[useHLSSegmentEvents] Error refreshing playlist:",
                      err
                    );
                  }
                }
              }
              break;

            case "heartbeat":
              // Keep-alive ping
              if (debug) {
              }
              break;

            case "error":
              // Server-side error
              const errorMsg = data.error || "Unknown SSE error";
              setError(errorMsg);
              setStatus(`Error: ${errorMsg}`);

              if (debug) {
              }

              if (onError) {
                onError(errorMsg);
              }
              break;

            default:
              if (debug) {
                console.warn(
                  "[useHLSSegmentEvents] Unknown event type:",
                  data.type
                );
              }
          }
        } catch (err) {
          setError("Failed to parse SSE event");
        }
      };

      // Event: SSE error
      eventSource.onerror = (err) => {
        setIsConnected(false);
        setStatus("Connection error");
        setError("SSE connection failed");

        if (onError) {
          onError("SSE connection error");
        }

        // Close connection
        eventSource.close();
        eventSourceRef.current = null;

        // Attempt reconnection after 5 seconds
        reconnectTimeoutRef.current = setTimeout(() => {
          if (debug) {
          }
          connect();
        }, 5000);
      };
    } catch (err) {
      setError("Failed to connect to SSE");
      setStatus("Connection failed");
    }
  };

  /**
   * Disconnect from SSE
   */
  const disconnect = () => {
    // Clear reconnection timeout
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    // Close EventSource
    if (eventSourceRef.current) {
      if (debug) {
      }

      eventSourceRef.current.close();
      eventSourceRef.current = null;
      setIsConnected(false);
      setStatus("Disconnected");
    }
  };

  /**
   * Manually reconnect
   */
  const reconnect = () => {
    if (debug) {
    }
    connect();
  };

  /**
   * Auto-connect when roomId or hls changes
   */
  useEffect(() => {
    if (roomId && hls) {
      connect();
    } else {
      disconnect();
    }

    // Cleanup on unmount
    return () => {
      disconnect();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [roomId, hls]);

  return {
    isConnected,
    error,
    lastSegment,
    segmentCount,
    status,
    reconnect,
  };
}
