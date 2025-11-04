"use client";

// ============================================================================
// useStreaming - Live WebRTC Camera Viewer Hook
// ============================================================================
/**
 * Hook for viewing live ambulance camera feeds via WebRTC
 *
 * **Purpose:** Manage WebRTC peer connections for live video streaming (viewer-side)
 *
 * **Use When:**
 * - Displaying live camera feed to users
 * - Building camera viewer components
 * - Implementing video player with live stream
 *
 * **Don't Use For:**
 * - Session management (use `useRealtimeAmbulanceSessions` from `useRealtime.ts` instead)
 * - Admin dashboards (use `useRealtimeAmbulanceSessions` from `useRealtime.ts` instead)
 * - HLS playback (use `useHLS` instead)
 *
 * **Key Features:**
 * - WebRTC peer connection management
 * - Automatic reconnection with exponential backoff
 * - Connection quality monitoring
 * - Video element ref management
 * - User-friendly status messages
 *
 * @example
 * ```tsx
 * function LiveCameraViewer({ ambulanceId, roomId }) {
 *   const {
 *     videoRef,
 *     isConnected,
 *     error,
 *     userFriendlyStatus,
 *     startStreaming,
 *     stopStreaming,
 *   } = useStreaming();
 *
 *   useEffect(() => {
 *     startStreaming(ambulanceId, roomId);
 *     return () => stopStreaming();
 *   }, [ambulanceId, roomId]);
 *
 *   return (
 *     <div>
 *       <video ref={videoRef} autoPlay playsInline />
 *       <p>{userFriendlyStatus}</p>
 *     </div>
 *   );
 * }
 * ```
 *
 * @see {@link STREAMING_HOOKS_GUIDE.md} for detailed usage guide
 */

import { ambulanceStreamingService } from "@/services/streamingService";
import type { AmbulanceSession, CameraRoom } from "@/types";
import { useCallback, useEffect, useRef, useState } from "react";

// ============================================================================
// TYPE DEFINITIONS
// ============================================================================

interface UseStreamingReturn {
  // State
  isConnected: boolean;
  isConnecting: boolean;
  isReconnecting: boolean;
  error: string | null;
  connectionQuality: "poor" | "fair" | "good" | "excellent" | null;
  reconnectionAttempts: number;
  maxReconnectionAttempts: number;

  // Enhanced UX properties
  reconnectionCountdown: number | null;
  reconnectionProgress: number;
  userFriendlyStatus: string | null;
  canManualRetry: boolean;
  isUserCancelledReconnection: boolean;
  isWaitingForData: boolean; // NEW: Waiting for video data

  currentSession: AmbulanceSession | null;

  // Refs for external access
  videoRef: React.RefObject<HTMLVideoElement | null>;
  peerConnectionRef: React.RefObject<RTCPeerConnection | null>;

  // Actions
  startStreaming: (ambulanceId: string, cameraId?: string) => Promise<void>;
  stopStreaming: () => void;
  clearError: () => void;
  toggleFullscreen: () => void;
  reconnect: () => Promise<void>;
  cancelReconnection: () => void;
}

// ============================================================================
// MAIN HOOK IMPLEMENTATION
// ============================================================================

export function useStreaming(): UseStreamingReturn {
  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isReconnecting, setIsReconnecting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [connectionQuality, setConnectionQuality] = useState<
    "poor" | "fair" | "good" | "excellent" | null
  >(null);
  const [reconnectionAttempts, setReconnectionAttempts] = useState(0);
  const [isWaitingForData, setIsWaitingForData] = useState(false); // NEW: Track waiting for video data

  // Enhanced UX state for reconnection
  const [reconnectionCountdown, setReconnectionCountdown] = useState<
    number | null
  >(null);
  const [reconnectionProgress, setReconnectionProgress] = useState(0);
  const [userFriendlyStatus, setUserFriendlyStatus] = useState<string | null>(
    null
  );
  const [canManualRetry, setCanManualRetry] = useState(false);
  const [isUserCancelledReconnection, setIsUserCancelledReconnection] =
    useState(false);

  const [currentSession, setCurrentSession] = useState<AmbulanceSession | null>(
    null
  );
  const maxReconnectionAttempts = 5;

  // ============================================================================
  // REFS (for avoiding stale closures and cleanup)
  // ============================================================================

  const videoRef = useRef<HTMLVideoElement>(null);
  const peerConnectionRef = useRef<RTCPeerConnection | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const currentAmbulanceIdRef = useRef<string | null>(null);
  const currentCameraIdRef = useRef<string | null>(null);
  const reconnectionTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isUserStoppedRef = useRef(false);
  const videoDataTimeoutRef = useRef<NodeJS.Timeout | null>(null); // NEW: Timeout for video data
  const videoEventCleanupRef = useRef<(() => void) | null>(null); // NEW: Cleanup function for video event listeners

  // 🔥 NEW: Ref-based state tracking to prevent stale closure issues
  const isConnectingRef = useRef(false);
  const isConnectedRef = useRef(false);

  // ============================================================================
  // HELPER FUNCTIONS (sync state with refs)
  // ============================================================================

  /**
   * Set connecting state (syncs both state and ref to prevent stale closures)
   */
  const setConnectingState = useCallback((value: boolean) => {
    isConnectingRef.current = value;
    setIsConnecting(value);
  }, []);

  const setConnectedState = useCallback((value: boolean) => {
    isConnectedRef.current = value;
    setIsConnected(value);
  }, []);

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /**
   * Clear error state
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const resetReconnectionState = useCallback(() => {
    setReconnectionAttempts(0);
    setIsReconnecting(false);
    setReconnectionCountdown(null);
    setReconnectionProgress(0);
    setUserFriendlyStatus(null);
    setCanManualRetry(false);
    setIsUserCancelledReconnection(false);
    if (reconnectionTimeoutRef.current) {
      clearTimeout(reconnectionTimeoutRef.current);
      reconnectionTimeoutRef.current = null;
    }
  }, []);

  /**
   * Update session status in database
   */
  const updateSessionStatus = useCallback(
    async (sessionId: string, isActive: boolean) => {
      try {
        const response = await ambulanceStreamingService.updateAmbulanceSession(
          sessionId,
          { is_active: isActive }
        );
        if (response.data) {
          setCurrentSession(response.data);
        }
      } catch (error) {
        console.error("Failed to update session status:", error);
      }
    },
    []
  );

  /**
   * Find active session for ambulance (started by RPi device)
   */
  const findActiveSession = useCallback(
    async (ambulanceId: string): Promise<AmbulanceSession | null> => {
      try {
        // Look for active sessions for this ambulance (started by RPi devices)
        const sessionsResponse =
          await ambulanceStreamingService.getAmbulanceSessions({
            ambulance_id: ambulanceId,
            is_active: true, // Only get active sessions
          });

        if (sessionsResponse.data && sessionsResponse.data.length > 0) {
          const session = sessionsResponse.data[0];
          console.log("Found existing active ambulance session:", session.id);
          setCurrentSession(session);
          return session;
        }

        // No active session found - RPi device hasn't started streaming yet
        console.log("No active session found for ambulance:", ambulanceId);
        setCurrentSession(null);
        return null;
      } catch (error) {
        console.error("Error finding active ambulance session:", error);
        setCurrentSession(null);
        return null;
      }
    },
    []
  );

  /**
   * Wait for a camera room to become connected (i.e., streamer has sent first frame)
   * This prevents race condition where viewer tries to connect before track is ready
   */
  const waitForRoomConnected = useCallback(
    async (
      roomId: string,
      sessionId: string,
      timeoutMs: number = 15000
    ): Promise<CameraRoom | null> => {
      const startTime = Date.now();
      const pollInterval = 500; // Check every 500ms

      console.log(
        `⏳ Waiting for room ${roomId} to become connected (timeout: ${timeoutMs}ms)...`
      );

      while (Date.now() - startTime < timeoutMs) {
        try {
          // Get all rooms for this session and find the target room
          const roomsResponse = await ambulanceStreamingService.getCameraRooms({
            session_id: sessionId,
          });

          if (roomsResponse.data && roomsResponse.data.length > 0) {
            const room = roomsResponse.data.find((r) => r.id === roomId);
            if (room && room.connected) {
              console.log(`✅ Room ${roomId} is now connected!`);
              return room;
            }
          }

          // Wait before next poll
          await new Promise((resolve) => setTimeout(resolve, pollInterval));
        } catch (error) {
          console.error("Error polling room status:", error);
          // Continue polling despite errors
          await new Promise((resolve) => setTimeout(resolve, pollInterval));
        }
      }

      console.warn(`⚠️ Timeout waiting for room ${roomId} to become connected`);
      return null;
    },
    []
  );

  const getReconnectionDelay = useCallback((attempt: number): number => {
    // Exponential backoff: 2^attempt * 1000ms, max 30 seconds
    return Math.min(Math.pow(2, attempt) * 1000, 30000);
  }, []);

  const handleAutoReconnection = useCallback(() => {
    if (
      isUserStoppedRef.current ||
      !currentAmbulanceIdRef.current ||
      isUserCancelledReconnection
    ) {
      return;
    }

    if (reconnectionAttempts >= maxReconnectionAttempts) {
      setError(
        `Maximum reconnection attempts (${maxReconnectionAttempts}) reached. Please restart the stream manually.`
      );
      setIsReconnecting(false);
      setCanManualRetry(true);
      setUserFriendlyStatus(
        "Connection failed. You can try reconnecting manually."
      );
      return;
    }

    const nextAttempt = reconnectionAttempts + 1;
    const delay = getReconnectionDelay(nextAttempt);

    setReconnectionAttempts(nextAttempt);
    setIsReconnecting(true);
    setCanManualRetry(false);
    setReconnectionProgress((nextAttempt / maxReconnectionAttempts) * 100);

    // Set user-friendly status with countdown
    setUserFriendlyStatus(
      `Reconnecting to camera... (Attempt ${nextAttempt} of ${maxReconnectionAttempts})`
    );
    setError(null); // Clear technical error messages during reconnection

    // Set countdown timer
    let countdown = Math.ceil(delay / 1000);
    setReconnectionCountdown(countdown);

    // Update countdown every second
    const countdownInterval = setInterval(() => {
      countdown -= 1;
      setReconnectionCountdown(countdown);
      if (countdown <= 0) {
        clearInterval(countdownInterval);
        setReconnectionCountdown(null);
      }
    }, 1000);

    console.log(
      `Scheduling reconnection attempt ${nextAttempt}/${maxReconnectionAttempts} in ${delay}ms`
    );

    reconnectionTimeoutRef.current = setTimeout(async () => {
      if (
        isUserStoppedRef.current ||
        !currentAmbulanceIdRef.current ||
        !currentCameraIdRef.current
      ) {
        console.log("Reconnection cancelled - stream stopped or no camera");
        return;
      }

      try {
        console.log(
          `🔄 Executing reconnection attempt ${nextAttempt}/${maxReconnectionAttempts}`
        );
        setError(`Reconnecting... (${nextAttempt}/${maxReconnectionAttempts})`);
        setUserFriendlyStatus(`Reconnection attempt ${nextAttempt}...`);

        // Clean up existing connection properly
        if (peerConnectionRef.current) {
          console.log("Closing existing peer connection...");
          try {
            peerConnectionRef.current.close();
          } catch (closeErr) {
            console.warn("Error closing peer connection:", closeErr);
          }
          peerConnectionRef.current = null;
        }

        // Small delay to ensure cleanup completes
        await new Promise((resolve) => setTimeout(resolve, 500));

        // Create new connection
        console.log("Creating new peer connection for reconnection...");
        const pc = await createPeerConnection(currentCameraIdRef.current!);
        peerConnectionRef.current = pc;

        console.log(`✅ Reconnection attempt ${nextAttempt} successful`);
        setError(null);
        setUserFriendlyStatus("Reconnected successfully");
      } catch (err) {
        console.error(`❌ Reconnection attempt ${nextAttempt} failed:`, err);
        const errorMessage = err instanceof Error ? err.message : String(err);

        // Schedule next attempt if we haven't reached the limit
        if (nextAttempt < maxReconnectionAttempts) {
          console.log(
            `Will retry reconnection (${
              nextAttempt + 1
            }/${maxReconnectionAttempts})`
          );
          setError(`Reconnection failed: ${errorMessage}. Retrying...`);
          handleAutoReconnection();
        } else {
          console.error(
            `Maximum reconnection attempts (${maxReconnectionAttempts}) reached`
          );
          setError(
            `Failed to reconnect after ${maxReconnectionAttempts} attempts. Please restart the stream manually.`
          );
          setIsReconnecting(false);
          setCanManualRetry(true);
          setUserFriendlyStatus("Connection failed. Manual restart required.");
        }
      }
    }, delay);
  }, [reconnectionAttempts, maxReconnectionAttempts, getReconnectionDelay]);

  const toggleFullscreen = useCallback(() => {
    const el = containerRef.current;
    if (!el) return;

    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      el.requestFullscreen();
    }
  }, []);

  const monitorConnectionQuality = useCallback((pc: RTCPeerConnection) => {
    const interval = setInterval(async () => {
      if (pc.connectionState === "closed") {
        clearInterval(interval);
        return;
      }

      try {
        const stats = await pc.getStats();
        let packetsLost = 0;
        let packetsReceived = 0;

        stats.forEach((report) => {
          if (report.type === "inbound-rtp" && report.mediaType === "video") {
            packetsLost += report.packetsLost || 0;
            packetsReceived += report.packetsReceived || 0;
          }
        });

        const totalPackets = packetsLost + packetsReceived;
        if (totalPackets > 0) {
          const lossRate = packetsLost / totalPackets;

          if (lossRate < 0.02) {
            setConnectionQuality("excellent");
          } else if (lossRate < 0.05) {
            setConnectionQuality("good");
          } else if (lossRate < 0.1) {
            setConnectionQuality("fair");
          } else {
            setConnectionQuality("poor");
          }
        }
      } catch (err) {
        console.warn("Failed to get connection stats:", err);
      }
    }, 5000); // Check every 5 seconds

    return interval;
  }, []);

  const createPeerConnection = useCallback(
    async (roomId: string): Promise<RTCPeerConnection> => {
      // roomId is the UUID (room.id) - we need to fetch room_name for API
      const pc = new RTCPeerConnection({
        iceServers: [
          { urls: "stun:stun.l.google.com:19302" },
          { urls: "stun:stun1.l.google.com:19302" },
        ],
      });

      // Set up event handlers
      pc.ontrack = (event) => {
        console.log("🎬 [ONTRACK] Received track event from streamer");
        console.log("🎬 [ONTRACK] Track kind:", event.track.kind);
        console.log("🎬 [ONTRACK] Track ID:", event.track.id);
        console.log("🎬 [ONTRACK] Track label:", event.track.label);
        console.log("🎬 [ONTRACK] Track readyState:", event.track.readyState);
        console.log("🎬 [ONTRACK] Track muted:", event.track.muted);
        console.log("🎬 [ONTRACK] Number of streams:", event.streams.length);

        if (event.streams.length > 0) {
          console.log(
            "🎬 [ONTRACK] Stream ID:",
            event.streams[0].id,
            "Active:",
            event.streams[0].active
          );
          console.log(
            "🎬 [ONTRACK] Stream tracks:",
            event.streams[0].getTracks().length
          );
        }

        if (videoRef.current && event.streams[0]) {
          console.log("✅ [VIDEO] Attaching stream to video element");

          // 🔥 CRITICAL: Clean up previous event listeners to prevent accumulation
          if (videoEventCleanupRef.current) {
            console.log("🧹 [VIDEO] Cleaning up previous event listeners");
            videoEventCleanupRef.current();
            videoEventCleanupRef.current = null;
          }

          // 🔥 CRITICAL: Reset video element state before attaching new stream
          if (videoRef.current.srcObject) {
            console.log("🔄 [VIDEO] Removing previous srcObject");
            videoRef.current.srcObject = null;
          }

          videoRef.current.srcObject = event.streams[0];

          // 🔥 CRITICAL: Set video properties for proper playback
          videoRef.current.muted = true; // Mute to allow autoplay
          videoRef.current.playsInline = true; // For mobile devices
          videoRef.current.autoplay = true; // Enable autoplay

          // Log video element state
          console.log(
            "📺 [VIDEO] Video readyState before play:",
            videoRef.current.readyState
          );
          console.log(
            "📺 [VIDEO] Video networkState:",
            videoRef.current.networkState
          );
          console.log("📺 [VIDEO] Video paused:", videoRef.current.paused);

          // 🔥 CRITICAL: Force play even if track is initially muted
          const tryPlay = async () => {
            try {
              await videoRef.current!.play();
              console.log("✅ [VIDEO] Video play() succeeded");
            } catch (err) {
              console.error("❌ [VIDEO] Video autoplay failed:", err);
              console.log(
                "⚠️ [VIDEO] User interaction required - video will play when user clicks"
              );
              // Set a flag or show UI to prompt user to click
              setUserFriendlyStatus("Click anywhere to start video");
            }
          };

          tryPlay();

          // NEW: Set up video data timeout monitoring
          setIsWaitingForData(true);
          console.log("⏳ [VIDEO] Waiting for video data...");

          // Clear any existing timeout
          if (videoDataTimeoutRef.current) {
            clearTimeout(videoDataTimeoutRef.current);
          }

          // Set 2-second timeout for receiving video data
          videoDataTimeoutRef.current = setTimeout(() => {
            // Check if video is actually playing (has received data)
            if (videoRef.current) {
              console.warn(
                "⚠️ [VIDEO-TIMEOUT] No video data received within 2 seconds"
              );
              console.warn(
                "⚠️ [VIDEO-TIMEOUT] readyState:",
                videoRef.current.readyState
              );
              console.warn(
                "⚠️ [VIDEO-TIMEOUT] paused:",
                videoRef.current.paused
              );
              console.warn(
                "⚠️ [VIDEO-TIMEOUT] currentTime:",
                videoRef.current.currentTime
              );

              if (videoRef.current.readyState < 2 || videoRef.current.paused) {
                setIsWaitingForData(true);
                setUserFriendlyStatus("Waiting for video data from camera...");
              }
            }
          }, 2000);

          // Monitor video metadata to detect when data is actually flowing
          const handleVideoData = () => {
            console.log(
              "🎉 [VIDEO-DATA] Video data received! Event:",
              event.type
            );
            console.log(
              "🎉 [VIDEO-DATA] readyState:",
              videoRef.current?.readyState
            );
            console.log(
              "🎉 [VIDEO-DATA] currentTime:",
              videoRef.current?.currentTime
            );

            if (videoDataTimeoutRef.current) {
              clearTimeout(videoDataTimeoutRef.current);
              videoDataTimeoutRef.current = null;
            }
            setIsWaitingForData(false);
            setUserFriendlyStatus("Receiving live video stream");
            console.log("✅ [VIDEO-DATA] Successfully receiving live stream");

            // 🔥 CRITICAL: Ensure video is playing when data arrives
            if (videoRef.current && videoRef.current.paused) {
              console.log(
                "🔄 [VIDEO-DATA] Video paused, attempting to play..."
              );
              videoRef.current.play().catch((err) => {
                console.error("❌ [VIDEO-DATA] Play failed:", err);
              });
            }

            videoRef.current?.removeEventListener(
              "loadeddata",
              handleVideoData
            );
            videoRef.current?.removeEventListener("playing", handleVideoData);
          };

          // Add all possible video events for debugging
          const debugVideoEvents = [
            "loadstart",
            "loadedmetadata",
            "loadeddata",
            "canplay",
            "canplaythrough",
            "playing",
            "play",
            "pause",
            "ended",
            "error",
            "stalled",
            "suspend",
            "waiting",
          ];

          // 🔥 CRITICAL: Store event listeners for cleanup
          const eventListeners: Array<{ event: string; handler: () => void }> =
            [];

          debugVideoEvents.forEach((eventName) => {
            const handler = () => {
              console.log(`📺 [VIDEO-EVENT] ${eventName}`);
              if (eventName === "error" && videoRef.current?.error) {
                console.error(
                  "📺 [VIDEO-ERROR]",
                  videoRef.current.error.message
                );
              }

              // 🔥 CRITICAL: Try to play when video can play
              if (
                (eventName === "canplay" || eventName === "canplaythrough") &&
                videoRef.current &&
                videoRef.current.paused
              ) {
                console.log(
                  `🔄 [${eventName.toUpperCase()}] Video ready, attempting to play...`
                );
                videoRef.current.play().catch((err) => {
                  console.error(
                    `❌ [${eventName.toUpperCase()}] Play failed:`,
                    err
                  );
                });
              }
            };

            videoRef.current?.addEventListener(eventName, handler);
            eventListeners.push({ event: eventName, handler });
          });

          videoRef.current.addEventListener("loadeddata", handleVideoData);
          videoRef.current.addEventListener("playing", handleVideoData);
          eventListeners.push({
            event: "loadeddata",
            handler: handleVideoData,
          });
          eventListeners.push({ event: "playing", handler: handleVideoData });

          // 🔥 CRITICAL: Store cleanup function
          videoEventCleanupRef.current = () => {
            eventListeners.forEach(({ event, handler }) => {
              videoRef.current?.removeEventListener(event, handler);
            });
            console.log("🧹 [VIDEO] Removed all event listeners");
          };

          // Also listen to track events
          event.track.onmute = () => {
            console.warn("🔇 [TRACK] Track muted");
          };
          event.track.onunmute = () => {
            console.log("🔊 [TRACK] Track unmuted");
            // 🔥 CRITICAL: Retry playing video when track unmutes
            if (videoRef.current && videoRef.current.paused) {
              console.log("🔄 [TRACK] Track unmuted, retrying video play...");
              videoRef.current.play().catch((err) => {
                console.error("❌ [TRACK] Retry play failed:", err);
              });
            }
          };
          event.track.onended = () => {
            console.warn("🛑 [TRACK] Track ended");
          };
        } else {
          console.error("❌ [ONTRACK] No video element or stream available");
        }
      };

      pc.onconnectionstatechange = () => {
        const timestamp = new Date().toISOString();
        console.log(
          `🔌 [CONNECTION-STATE] ${timestamp} - State:`,
          pc.connectionState
        );
        console.log("🔌 [CONNECTION-STATE] ICE state:", pc.iceConnectionState);
        console.log(
          "🔌 [CONNECTION-STATE] Signaling state:",
          pc.signalingState
        );

        // Log transceiver state
        const transceivers = pc.getTransceivers();
        console.log("🔌 [CONNECTION-STATE] Transceivers:", transceivers.length);
        transceivers.forEach((t, idx) => {
          console.log(`  - Transceiver ${idx}:`, {
            direction: t.direction,
            currentDirection: t.currentDirection,
            mid: t.mid,
            receiver: {
              track: t.receiver.track
                ? {
                    id: t.receiver.track.id,
                    kind: t.receiver.track.kind,
                    readyState: t.receiver.track.readyState,
                    muted: t.receiver.track.muted,
                  }
                : null,
            },
          });
        });

        switch (pc.connectionState) {
          case "connected":
            console.log("✅ [CONNECTED] WebRTC connection established!");
            console.log(
              "✅ [CONNECTED] Checking for tracks in transceivers..."
            );

            // Check if we have tracks
            let hasVideoTrack = false;
            transceivers.forEach((t) => {
              if (t.receiver.track && t.receiver.track.kind === "video") {
                hasVideoTrack = true;
                console.log(
                  "✅ [CONNECTED] Found video track:",
                  t.receiver.track.id
                );
              }
            });

            if (!hasVideoTrack) {
              console.warn(
                "⚠️ [CONNECTED] No video tracks found despite connection!"
              );
            }

            setConnectedState(true); // 🔥 Use helper
            setConnectingState(false); // 🔥 Use helper
            setIsReconnecting(false);
            setError(null);
            setUserFriendlyStatus("Live stream connected");
            resetReconnectionState();

            // Clear any pending video data timeout
            if (videoDataTimeoutRef.current) {
              clearTimeout(videoDataTimeoutRef.current);
              videoDataTimeoutRef.current = null;
            }
            break;
          case "connecting":
            console.log("🔄 [CONNECTING] Establishing WebRTC connection...");
            setConnectingState(true); // 🔥 Use helper
            setUserFriendlyStatus("Establishing connection...");
            break;
          case "disconnected":
            console.warn(
              "⚠️ [DISCONNECTED] Connection disconnected - will attempt reconnection"
            );
            console.warn("⚠️ [DISCONNECTED] ICE state:", pc.iceConnectionState);
            console.warn(
              "⚠️ [DISCONNECTED] Signaling state:",
              pc.signalingState
            );
            setConnectedState(false); // 🔥 Use helper
            setConnectingState(false); // 🔥 Use helper
            // Only auto-reconnect if user didn't manually stop
            if (!isUserStoppedRef.current) {
              handleAutoReconnection();
            }
            break;
          case "failed":
            console.error(
              "❌ [FAILED] Connection failed - will attempt reconnection"
            );
            console.error("❌ [FAILED] ICE state:", pc.iceConnectionState);
            console.error("❌ [FAILED] Signaling state:", pc.signalingState);
            setConnectedState(false); // 🔥 Use helper
            setConnectingState(false); // 🔥 Use helper
            // Only auto-reconnect if user didn't manually stop
            if (!isUserStoppedRef.current) {
              handleAutoReconnection();
            }
            break;
          case "closed":
            console.log("🔒 [CLOSED] Connection closed");
            setConnectedState(false); // 🔥 Use helper
            setConnectingState(false); // 🔥 Use helper
            setConnectionQuality(null);

            // Clear video data timeout
            if (videoDataTimeoutRef.current) {
              clearTimeout(videoDataTimeoutRef.current);
              videoDataTimeoutRef.current = null;
            }
            break;
        }
      };

      pc.onicegatheringstatechange = () => {
        console.log("ICE gathering state:", pc.iceGatheringState);
      };

      pc.oniceconnectionstatechange = () => {
        console.log("ICE connection state:", pc.iceConnectionState);

        switch (pc.iceConnectionState) {
          case "connected":
          case "completed":
            console.log("✅ ICE connection established");
            monitorConnectionQuality(pc);
            setError(null); // Clear any previous errors
            break;
          case "checking":
            console.log("🔍 ICE connection checking...");
            setUserFriendlyStatus("Checking network connection...");
            break;
          case "failed":
            console.error("❌ ICE connection failed");
            setError(
              "Network connection failed - please check your internet connection"
            );
            // Don't immediately reconnect on ICE failure - give it time to recover
            break;
          case "disconnected":
            console.warn("⚠️ ICE connection disconnected");
            setError("Network connection lost - trying to reconnect...");
            // ICE disconnected can be temporary, don't panic
            break;
          case "closed":
            console.log("🔒 ICE connection closed");
            break;
        }
      };

      // Add transceivers for receiving media
      console.log("🎥 [SETUP] Adding transceivers for video and audio...");
      const videoTransceiver = pc.addTransceiver("video", {
        direction: "recvonly",
      });
      const audioTransceiver = pc.addTransceiver("audio", {
        direction: "recvonly",
      });
      console.log("🎥 [SETUP] Video transceiver added:", videoTransceiver.mid);
      console.log("🎥 [SETUP] Audio transceiver added:", audioTransceiver.mid);

      // Create offer
      console.log("📝 [SDP] Creating offer...");
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      console.log("📝 [SDP] Offer created:", offer.type);
      console.log("📝 [SDP] Local description set");
      console.log(
        "📝 [SDP] Offer SDP (first 200 chars):",
        offer.sdp?.substring(0, 200)
      );

      // Wait for ICE gathering to complete
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error("ICE gathering timeout"));
        }, 10000); // 10 second timeout

        if (pc.iceGatheringState === "complete") {
          clearTimeout(timeout);
          resolve();
          return;
        }

        const handleICEGatheringStateChange = () => {
          if (pc.iceGatheringState === "complete") {
            pc.removeEventListener(
              "icegatheringstatechange",
              handleICEGatheringStateChange
            );
            clearTimeout(timeout);
            resolve();
          }
        };

        pc.addEventListener(
          "icegatheringstatechange",
          handleICEGatheringStateChange
        );
      });

      // Send offer to server and get answer using ambulance camera streaming
      // Note: roomId is passed as camera_id parameter to the API
      // roomId is actually room_name (e.g., "AMB-001-ROOM-001")
      try {
        console.log(`📡 [API] Sending offer to server for room: ${roomId}...`);
        const response = await ambulanceStreamingService.connectCameraViewer(
          roomId, // room_name is used as camera_id parameter
          {
            sdp: pc.localDescription!.sdp,
            type: pc.localDescription!.type,
          }
        );

        console.log("📡 [API] Server response received");
        console.log("📡 [API] Response has data:", !!response.data);
        console.log("📡 [API] Response has SDP:", !!response.data?.sdp);
        console.log("📡 [API] Response type:", response.data?.type);

        if (response.data && response.data.sdp && response.data.type) {
          console.log(
            "📝 [SDP] Answer SDP (first 200 chars):",
            response.data.sdp.substring(0, 200)
          );

          // Validate that the type is a valid RTCSdpType
          const validTypes: RTCSdpType[] = [
            "answer",
            "offer",
            "pranswer",
            "rollback",
          ];
          const responseType = response.data.type as RTCSdpType;

          if (!validTypes.includes(responseType)) {
            throw new Error(`Invalid SDP type received: ${response.data.type}`);
          }

          console.log(
            "📝 [SDP] Setting remote description (answer from server)..."
          );
          await pc.setRemoteDescription(
            new RTCSessionDescription({
              sdp: response.data.sdp,
              type: responseType,
            })
          );
          console.log(
            "✅ [SDP] Remote description set successfully for ambulance camera"
          );
          console.log(
            "✅ [SDP] Signaling complete, waiting for ICE and media..."
          );
        } else {
          const errorMessage =
            response.error || "No SDP answer received from server";
          console.error("❌ [API] Server response invalid:", errorMessage);
          throw new Error(errorMessage);
        }
      } catch (err) {
        console.error("❌ [API] Failed to set remote description:", err);
        pc.close();
        throw err;
      }

      return pc;
    },
    [
      monitorConnectionQuality,
      resetReconnectionState,
      handleAutoReconnection,
      currentSession,
      updateSessionStatus,
    ]
  );

  const startStreaming = useCallback(
    async (ambulanceId: string, roomId?: string): Promise<void> => {
      console.log("🚀 [START] ========================================");
      console.log("🚀 [START] Starting streaming process...");
      console.log("🚀 [START] Ambulance ID:", ambulanceId);
      console.log("🚀 [START] Room ID:", roomId || "(will be determined)");

      // 🔥 CRITICAL: Use refs for guard check to avoid stale closure
      console.log("🚀 [START] Is Connecting (ref):", isConnectingRef.current);
      console.log("🚀 [START] Is Connected (ref):", isConnectedRef.current);

      // ✅ Guard: Prevent duplicate connections using refs
      if (isConnectingRef.current || isConnectedRef.current) {
        console.warn(
          "⚠️ [START] Streaming already in progress - ignoring duplicate request"
        );
        console.warn("⚠️ [START] isConnecting:", isConnectingRef.current);
        console.warn("⚠️ [START] isConnected:", isConnectedRef.current);
        return;
      }

      // ✅ Guard: Check for existing peer connection
      if (
        peerConnectionRef.current &&
        peerConnectionRef.current.connectionState !== "closed"
      ) {
        console.warn(
          "⚠️ [START] Existing peer connection detected - cleaning up before starting"
        );
        console.warn(
          "⚠️ [START] Old connection state:",
          peerConnectionRef.current.connectionState
        );
        peerConnectionRef.current.close();
        peerConnectionRef.current = null;
      }

      if (!ambulanceId) {
        setError("Ambulance ID is required for streaming");
        return;
      }

      try {
        setConnectingState(true); // 🔥 Use helper to sync ref + state
        setError(null);
        setUserFriendlyStatus("Looking for active ambulance camera...");
        isUserStoppedRef.current = false;
        currentAmbulanceIdRef.current = ambulanceId;
        resetReconnectionState();

        console.log("🔍 [SESSION] Looking for active session...");
        // Look for existing active session (started by RPi device)
        const sessionPromise = findActiveSession(ambulanceId);
        const timeoutPromise = new Promise((_, reject) =>
          setTimeout(
            () => reject(new Error("Session lookup timeout after 10s")),
            10000
          )
        );

        const session = (await Promise.race([
          sessionPromise,
          timeoutPromise,
        ])) as AmbulanceSession | null;

        if (!session) {
          const errorMsg =
            "No active ambulance session found. Please ensure the ambulance camera device is connected and streaming.";
          console.error("❌ [SESSION] No active session found");
          console.error("❌ [SESSION] Error message:", errorMsg);
          throw new Error(errorMsg);
        }

        console.log("✅ [SESSION] Found active session:", session.id);
        console.log("✅ [SESSION] Session started at:", session.started_at);
        console.log("✅ [SESSION] Session type:", session.session_type);

        // Get camera rooms for this ambulance session
        console.log("🔍 [ROOM] Getting camera rooms for session...");
        const roomsResponse = await ambulanceStreamingService.getCameraRooms({
          session_id: session.id,
        });

        console.log(
          "🔍 [ROOM] Found",
          roomsResponse.data?.length || 0,
          "room(s)"
        );

        if (!roomsResponse.data || roomsResponse.data.length === 0) {
          console.error("❌ [ROOM] No camera rooms found");
          throw new Error("No camera rooms found for this ambulance session");
        }

        // Log all rooms
        roomsResponse.data.forEach((room, idx) => {
          console.log(`  - Room ${idx + 1}:`, {
            id: room.id,
            room_name: room.room_name,
            connected: room.connected,
            camera_id: room.camera_id,
          });
        });

        // Find the target room
        let selectedRoom;
        if (roomId) {
          console.log("🔍 [ROOM] Looking for specific room ID:", roomId);

          // Check if roomId is a placeholder ID
          if (roomId.startsWith("placeholder-")) {
            // Extract camera UUID from placeholder
            const cameraId = roomId.replace("placeholder-", "");
            console.log(
              "🔍 [ROOM] Detected placeholder ID, looking for camera_id:",
              cameraId
            );
            selectedRoom = roomsResponse.data.find(
              (r) => r.camera_id === cameraId
            );
          } else {
            // Look for room by ID (UUID)
            selectedRoom = roomsResponse.data.find((r) => r.id === roomId);
          }

          if (!selectedRoom) {
            console.error("❌ [ROOM] Specified room not found:", roomId);
            throw new Error(
              `Camera room ${roomId} not found or not streaming yet`
            );
          }
        } else {
          // No specific room requested - use first connected, or first available
          const connectedRoom = roomsResponse.data.find((r) => r.connected);
          selectedRoom = connectedRoom || roomsResponse.data[0];
        }

        const targetRoomId = selectedRoom.id; // UUID for identification
        const targetRoomName = selectedRoom.room_name; // Display name for API

        console.log(
          "🎯 [ROOM] Selected room:",
          targetRoomName,
          `(UUID: ${targetRoomId})`,
          selectedRoom.connected ? "(connected)" : "(not connected yet)"
        );

        // ✅ If room is not connected yet, wait for it to become ready
        if (!selectedRoom.connected) {
          console.log(
            "⏳ [ROOM] Room not connected yet, waiting for stream to be ready..."
          );
          setUserFriendlyStatus(
            "Camera is connecting, waiting for stream to be ready..."
          );
          const waitedRoom = await waitForRoomConnected(
            targetRoomId,
            session.id,
            15000
          ); // Wait up to 15 seconds
          if (!waitedRoom) {
            console.warn(
              "⚠️ [ROOM] Room did not become connected within timeout, attempting connection anyway"
            );
          } else {
            console.log(
              "✅ [ROOM] Room is now connected:",
              waitedRoom.connected
            );
          }
        } else {
          console.log("✅ [ROOM] Room is already connected, proceeding");
        }

        // Store the room_name (display name used in API endpoints)
        currentCameraIdRef.current = targetRoomName;

        // currentCameraIdRef now stores the room_name for API calls
        console.log(
          "📝 [ROOM] Stored camera ID (room_name):",
          currentCameraIdRef.current
        );
        console.log("📝 [ROOM] Room UUID:", targetRoomId);

        // Clean up any existing connection
        if (peerConnectionRef.current) {
          peerConnectionRef.current.close();
        }

        if (!currentCameraIdRef.current) {
          throw new Error("Room name is required for streaming");
        }

        console.log(
          "🔌 [WEBRTC] Creating peer connection for room:",
          currentCameraIdRef.current
        );

        // Create peer connection using room_name (which is the camera_id parameter in API)
        const pc = await createPeerConnection(currentCameraIdRef.current);
        peerConnectionRef.current = pc;

        console.log("✅ [COMPLETE] Ambulance streaming connection established");
        console.log("✅ [COMPLETE] Session ID:", session.id);
        console.log("✅ [COMPLETE] Room Name:", currentCameraIdRef.current);
        console.log("✅ [COMPLETE] Room UUID:", targetRoomId);
        console.log("✅ [COMPLETE] ========================================");
        setUserFriendlyStatus("Connected to ambulance camera successfully!");
      } catch (err) {
        let message = "Failed to start streaming";
        let userMessage = "Unable to connect to camera";

        if (err instanceof Error) {
          if (err.message.includes("No active camera session")) {
            message = err.message;
            userMessage =
              "No camera is currently streaming. Please check if the camera device is active.";
          } else if (err.message.includes("Invalid SDP type")) {
            message = "Server returned invalid session data. Please try again.";
            userMessage = "Server configuration error. Please try again.";
          } else if (err.message.includes("No SDP answer")) {
            message =
              "Server did not respond with streaming data. Check if the camera is available.";
            userMessage =
              "Camera not responding. Please check if the camera is connected and active.";
          } else if (err.message.includes("ICE gathering timeout")) {
            message = "Network connection timeout";
            userMessage =
              "Network connection failed. Please check your internet connection.";
          } else {
            message = err.message;
            userMessage = "Connection failed. Please try again.";
          }
        }

        setError(message);
        setUserFriendlyStatus(userMessage);
        setCanManualRetry(true);
        console.error("Error starting streaming:", err);
        setConnectingState(false); // 🔥 Use helper
        setIsReconnecting(false);
        currentAmbulanceIdRef.current = null;
        currentCameraIdRef.current = null;

        // Note: Don't update session status - we're just a viewer, errors don't affect RPi session
      }
    },
    [
      // 🔥 Removed isConnecting and isConnected to prevent stale closure
      // Using refs (isConnectingRef, isConnectedRef) for guard checks instead
      setConnectingState,
      createPeerConnection,
      resetReconnectionState,
      findActiveSession,
      currentSession,
      updateSessionStatus,
      waitForRoomConnected,
    ]
  );

  const stopStreaming = useCallback(() => {
    isUserStoppedRef.current = true;
    currentAmbulanceIdRef.current = null;
    currentCameraIdRef.current = null;
    resetReconnectionState();

    // NEW: Clear video data timeout
    if (videoDataTimeoutRef.current) {
      clearTimeout(videoDataTimeoutRef.current);
      videoDataTimeoutRef.current = null;
    }
    setIsWaitingForData(false);

    // 🔥 CRITICAL: Clean up video event listeners
    if (videoEventCleanupRef.current) {
      console.log("🧹 [STOP] Cleaning up video event listeners");
      videoEventCleanupRef.current();
      videoEventCleanupRef.current = null;
    }

    // Don't end the session - it's managed by RPi device
    // Just disconnect the viewer and clear local state
    setCurrentSession(null);

    if (peerConnectionRef.current) {
      peerConnectionRef.current.close();
      peerConnectionRef.current = null;
    }

    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }

    setConnectedState(false); // 🔥 Use helper
    setConnectingState(false); // 🔥 Use helper
    setIsReconnecting(false);
    setConnectionQuality(null);
    setError(null);
    setUserFriendlyStatus("Disconnected from camera");

    console.log("Viewer disconnected from streaming");
  }, [resetReconnectionState, setConnectedState, setConnectingState]);

  const reconnect = useCallback(async (): Promise<void> => {
    if (!currentAmbulanceIdRef.current) {
      setError("No ambulance ID available for reconnection");
      return;
    }

    console.log("Manual ambulance reconnection initiated");
    setIsUserCancelledReconnection(false);
    resetReconnectionState();
    await startStreaming(
      currentAmbulanceIdRef.current,
      currentCameraIdRef.current || undefined
    );
  }, [startStreaming, resetReconnectionState]);

  const cancelReconnection = useCallback(() => {
    console.log("User cancelled reconnection");
    setIsUserCancelledReconnection(true);
    setIsReconnecting(false);
    setReconnectionCountdown(null);
    setUserFriendlyStatus(
      "Reconnection cancelled. You can try again manually."
    );
    setCanManualRetry(true);

    if (reconnectionTimeoutRef.current) {
      clearTimeout(reconnectionTimeoutRef.current);
      reconnectionTimeoutRef.current = null;
    }
  }, []);

  // Cleanup on unmount - CRITICAL for preventing duplicate viewer connections
  useEffect(() => {
    return () => {
      console.log("🧹 useStreaming unmounting - cleaning up connections");

      // Set user stopped flag
      isUserStoppedRef.current = true;

      // Clear all timeouts
      if (reconnectionTimeoutRef.current) {
        clearTimeout(reconnectionTimeoutRef.current);
        reconnectionTimeoutRef.current = null;
      }

      if (videoDataTimeoutRef.current) {
        clearTimeout(videoDataTimeoutRef.current);
        videoDataTimeoutRef.current = null;
      }

      // 🔥 CRITICAL: Clean up video event listeners
      if (videoEventCleanupRef.current) {
        console.log("🧹 [UNMOUNT] Cleaning up video event listeners");
        videoEventCleanupRef.current();
        videoEventCleanupRef.current = null;
      }

      // Close peer connection
      if (peerConnectionRef.current) {
        console.log("Closing peer connection on unmount");
        try {
          peerConnectionRef.current.close();
        } catch (err) {
          console.error("Error closing peer connection on unmount:", err);
        }
        peerConnectionRef.current = null;
      }

      // Clear video element
      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }

      // 🔥 CRITICAL: Reset state AND refs to allow reconnection after remount
      console.log("🔄 [CLEANUP] Resetting connection state and refs");

      // Reset refs first
      isConnectingRef.current = false;
      isConnectedRef.current = false;

      // Then reset state (using direct setters is fine here, but could use helpers for consistency)
      setIsConnecting(false);
      setIsConnected(false);
      setIsReconnecting(false);
      setIsWaitingForData(false);
      setError(null);
      setConnectionQuality(null);

      // Clear refs
      currentAmbulanceIdRef.current = null;
      currentCameraIdRef.current = null;

      console.log("✅ Cleanup completed - hook ready for remount");
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Empty deps - cleanup runs ONLY on unmount

  return {
    isConnected,
    isConnecting,
    isReconnecting,
    error,
    connectionQuality,
    reconnectionAttempts,
    maxReconnectionAttempts,

    // Enhanced UX properties
    reconnectionCountdown,
    reconnectionProgress,
    userFriendlyStatus,
    canManualRetry,
    isUserCancelledReconnection,
    isWaitingForData, // NEW: Add the waiting for data state

    currentSession,
    videoRef,
    peerConnectionRef,
    startStreaming,
    stopStreaming,
    clearError,
    toggleFullscreen,
    reconnect,
    cancelReconnection,
  };
}
