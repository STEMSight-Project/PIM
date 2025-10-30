/**
 * useHLS Hook
 *
 * React hook for managing HLS.js player lifecycle and state.
 * Handles player initialization, cleanup, events, and error recovery.
 */

import { HLSRecordingStatus, hlsService } from "@/services/hlsService";
import Hls, { ErrorData, Events } from "hls.js";
import { useCallback, useEffect, useRef, useState } from "react";

export interface UseHLSOptions {
  /** Room ID for the recording (e.g., AMB-001-ROOM-001) */
  roomId: string | null;

  /** Auto-play when ready */
  autoPlay?: boolean;

  /** Enable low latency mode for live streaming */
  lowLatencyMode?: boolean;

  /** Maximum buffer length in seconds */
  maxBufferLength?: number;

  /** Enable debug logging */
  debug?: boolean;

  /** Polling interval for status updates (ms) - default: 15000ms (15s, matches segment duration/2) */
  statusPollingInterval?: number;
}

export interface UseHLSReturn {
  /** Video element ref to attach to <video> */
  videoRef: React.RefObject<HTMLVideoElement | null>;

  /** Current HLS.js instance */
  hls: Hls | null;

  /** Loading state */
  isLoading: boolean;

  /** Error message if any */
  error: string | null;

  /** Current status message */
  status: string;

  /** Recording status from backend */
  recordingStatus: HLSRecordingStatus | null;

  /** Whether HLS is ready for playback */
  isHLSReady: boolean;

  /** Reload the HLS stream */
  reload: () => void;

  /** Manually start playback */
  play: () => Promise<void>;

  /** Pause playback */
  pause: () => void;

  /** Seek to specific time */
  seek: (time: number) => void;
}

export function useHLS(options: UseHLSOptions): UseHLSReturn {
  const {
    roomId,
    autoPlay = false,
    lowLatencyMode = false,
    maxBufferLength = 30,
    debug = false,
    statusPollingInterval = 15000, // Poll every 15 seconds (half of 30s segment duration)
  } = options;

  const videoRef = useRef<HTMLVideoElement>(null);
  const hlsRef = useRef<Hls | null>(null);
  const pollCleanupRef = useRef<(() => void) | null>(null);
  const lastDurationRef = useRef<number>(0);
  const reloadTimerRef = useRef<NodeJS.Timeout | null>(null);

  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [status, setStatus] = useState<string>("Initializing...");
  const [recordingStatus, setRecordingStatus] =
    useState<HLSRecordingStatus | null>(null);
  const [isHLSReady, setIsHLSReady] = useState(false);

  /**
   * Initialize HLS player
   */
  const initializeHLS = useCallback(() => {
    if (!roomId || !videoRef.current) {
      return;
    }

    const video = videoRef.current;
    const playlistUrl = hlsService.getPlaylistUrl(roomId);

    if (debug) {
      console.log("[useHLS] Initializing player for room:", roomId);
      console.log("[useHLS] Playlist URL:", playlistUrl);
    }

    // Clean up existing instance
    if (hlsRef.current) {
      hlsRef.current.destroy();
      hlsRef.current = null;
    }

    setIsLoading(true);
    setError(null);
    setStatus("Loading playlist...");

    // Check browser support
    if (Hls.isSupported()) {
      // Modern browsers - use HLS.js
      const hls = new Hls({
        enableWorker: true,
        lowLatencyMode,
        maxBufferLength,
        debug,
      });

      hlsRef.current = hls;

      // Load source
      hls.loadSource(playlistUrl);
      hls.attachMedia(video);

      // Event: Manifest parsed
      hls.on(Events.MANIFEST_PARSED, (event, data) => {
        if (debug) {
          console.log("[useHLS] Manifest parsed:", data);
        }
        setStatus("Ready to play");
        setIsLoading(false);
        setIsHLSReady(true);

        if (autoPlay) {
          video.play().catch((err) => {
            console.warn("[useHLS] Auto-play prevented:", err);
            setStatus("Click to play");
          });
        }
      });

      // Event: Fragment loading
      hls.on(Events.FRAG_LOADING, (event, data) => {
        if (debug) {
          console.log(`[useHLS] Loading segment ${data.frag.sn}`);
        }
        setStatus(`Loading segment ${data.frag.sn}...`);
      });

      // Event: Fragment loaded
      hls.on(Events.FRAG_LOADED, (event, data) => {
        if (debug) {
          console.log(`[useHLS] Segment ${data.frag.sn} loaded`);
        }

        // Check if new segments might be available (for live/growing recordings)
        // Reload playlist every 15 seconds to check for new segments (half of segment duration)
        if (reloadTimerRef.current) {
          clearTimeout(reloadTimerRef.current);
        }

        reloadTimerRef.current = setTimeout(() => {
          if (hlsRef.current) {
            const currentDuration = videoRef.current?.duration || 0;

            // Only reload if we're near the end (within 30 seconds) or duration changed
            const isNearEnd = videoRef.current
              ? Math.abs(currentDuration - videoRef.current.currentTime) < 30
              : false;

            if (isNearEnd || currentDuration !== lastDurationRef.current) {
              if (debug) {
                console.log(
                  `[useHLS] Reloading playlist to check for new segments (duration: ${currentDuration}s)`
                );
              }

              lastDurationRef.current = currentDuration;
              hlsRef.current.loadLevel = -1; // Reset to auto quality

              // Trigger playlist reload without disrupting playback
              try {
                hlsRef.current.startLoad();
              } catch (err) {
                if (debug) {
                  console.warn("[useHLS] Error reloading playlist:", err);
                }
              }
            }
          }
        }, 15000); // Check every 15 seconds (half of 30-second segments)
      });

      // Event: Level updated (playlist updated with new segments)
      hls.on(Events.LEVEL_UPDATED, (event, data) => {
        if (debug) {
          console.log(
            `[useHLS] Playlist updated - segments: ${
              data.details?.fragments?.length || 0
            }`
          );
        }

        // Force video to update its duration
        if (
          videoRef.current &&
          videoRef.current.duration !== lastDurationRef.current
        ) {
          const newDuration = videoRef.current.duration;
          lastDurationRef.current = newDuration;

          if (debug) {
            console.log(
              `[useHLS] Duration updated: ${newDuration.toFixed(2)}s`
            );
          }

          // Dispatch a custom event to notify components about duration update
          videoRef.current.dispatchEvent(new Event("durationchange"));
        }
      });

      // Event: Error
      hls.on(Events.ERROR, (event, data: ErrorData) => {
        if (debug) {
          console.error("[useHLS] HLS error:", data);
        }

        if (data.fatal) {
          setIsLoading(false);

          switch (data.type) {
            case Hls.ErrorTypes.NETWORK_ERROR:
              setError(`Network error: ${data.details}`);
              setStatus("Network error - retrying...");

              // Try to recover
              setTimeout(() => {
                if (hlsRef.current) {
                  hlsRef.current.startLoad();
                }
              }, 1000);
              break;

            case Hls.ErrorTypes.MEDIA_ERROR:
              setError(`Media error: ${data.details}`);
              setStatus("Media error - recovering...");

              // Try to recover
              if (hlsRef.current) {
                hlsRef.current.recoverMediaError();
              }
              break;

            default:
              setError(`Fatal error: ${data.details}`);
              setStatus("Fatal error occurred");
              break;
          }
        }
      });
    } else if (video.canPlayType("application/vnd.apple.mpegurl")) {
      // Safari - native HLS support
      if (debug) {
        console.log("[useHLS] Using native HLS support");
      }

      video.src = playlistUrl;

      video.addEventListener("loadedmetadata", () => {
        setStatus("Ready to play");
        setIsLoading(false);
        setIsHLSReady(true);

        if (autoPlay) {
          video.play().catch((err) => {
            console.warn("[useHLS] Auto-play prevented:", err);
            setStatus("Click to play");
          });
        }
      });

      video.addEventListener("error", () => {
        setError("Failed to load recording");
        setStatus("Error loading video");
        setIsLoading(false);
      });
    } else {
      setError("HLS not supported in this browser");
      setStatus("Browser not supported");
      setIsLoading(false);
    }
  }, [roomId, autoPlay, lowLatencyMode, maxBufferLength, debug]);

  /**
   * Start polling recording status
   */
  const startStatusPolling = useCallback(() => {
    if (!roomId) return;

    // Clean up existing polling
    if (pollCleanupRef.current) {
      pollCleanupRef.current();
      pollCleanupRef.current = null;
    }

    // Start new polling
    const cleanup = hlsService.pollRecordingStatus(
      roomId,
      (status) => {
        setRecordingStatus(status);

        if (debug && status) {
          console.log("[useHLS] Status update:", status);
        }
      },
      statusPollingInterval
    );

    pollCleanupRef.current = cleanup;
  }, [roomId, statusPollingInterval, debug]);

  /**
   * Reload the stream
   */
  const reload = useCallback(() => {
    if (debug) {
      console.log("[useHLS] Reloading stream");
    }
    initializeHLS();
  }, [initializeHLS, debug]);

  /**
   * Play video
   */
  const play = useCallback(async () => {
    if (videoRef.current) {
      try {
        await videoRef.current.play();
      } catch (err) {
        console.error("[useHLS] Play error:", err);
        throw err;
      }
    }
  }, []);

  /**
   * Pause video
   */
  const pause = useCallback(() => {
    if (videoRef.current) {
      videoRef.current.pause();
    }
  }, []);

  /**
   * Seek to time
   */
  const seek = useCallback((time: number) => {
    if (videoRef.current) {
      videoRef.current.currentTime = time;

      // If video is paused, play it after seeking
      if (videoRef.current.paused) {
        videoRef.current.play().catch((err) => {
          console.warn("[useHLS] Play after seek prevented:", err);
        });
      }
    }
  }, []);

  /**
   * Initialize player when roomId changes
   */
  useEffect(() => {
    if (roomId) {
      initializeHLS();
      startStatusPolling();
    } else {
      setIsLoading(false);
      setError("No room ID provided");
      setStatus("No room selected");
    }

    // Cleanup
    return () => {
      // Clear reload timer
      if (reloadTimerRef.current) {
        clearTimeout(reloadTimerRef.current);
        reloadTimerRef.current = null;
      }

      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }

      if (pollCleanupRef.current) {
        pollCleanupRef.current();
        pollCleanupRef.current = null;
      }
    };
  }, [roomId, initializeHLS, startStatusPolling]);

  return {
    videoRef,
    hls: hlsRef.current,
    isLoading,
    error,
    status,
    recordingStatus,
    isHLSReady,
    reload,
    play,
    pause,
    seek,
  };
}
