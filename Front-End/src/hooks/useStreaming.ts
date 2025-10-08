"use client";

import { ambulanceStreamingService } from "@/services/streamingService";
import type { AmbulanceSession } from "@/types";
import { useCallback, useEffect, useRef, useState } from "react";

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

export function useStreaming(): UseStreamingReturn {
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

  const videoRef = useRef<HTMLVideoElement>(null);
  const peerConnectionRef = useRef<RTCPeerConnection | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const currentAmbulanceIdRef = useRef<string | null>(null);
  const currentCameraIdRef = useRef<string | null>(null);
  const reconnectionTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isUserStoppedRef = useRef(false);
  const videoDataTimeoutRef = useRef<NodeJS.Timeout | null>(null); // NEW: Timeout for video data

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
        return;
      }

      try {
        console.log(`Executing reconnection attempt ${nextAttempt}`);
        setError(`Reconnecting... (${nextAttempt}/${maxReconnectionAttempts})`);

        // Clean up existing connection
        if (peerConnectionRef.current) {
          peerConnectionRef.current.close();
        }

        const pc = await createPeerConnection(currentCameraIdRef.current!);
        peerConnectionRef.current = pc;

        console.log(`Reconnection attempt ${nextAttempt} successful`);
      } catch (err) {
        console.error(`Reconnection attempt ${nextAttempt} failed:`, err);

        // Schedule next attempt if we haven't reached the limit
        if (nextAttempt < maxReconnectionAttempts) {
          handleAutoReconnection();
        } else {
          setError(
            `Failed to reconnect after ${maxReconnectionAttempts} attempts. Please restart the stream manually.`
          );
          setIsReconnecting(false);
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
    async (cameraId: string): Promise<RTCPeerConnection> => {
      const pc = new RTCPeerConnection({
        iceServers: [
          { urls: "stun:stun.l.google.com:19302" },
          { urls: "stun:stun1.l.google.com:19302" },
        ],
      });

      // Set up event handlers
      pc.ontrack = (event) => {
        console.log("Received remote stream");
        if (videoRef.current && event.streams[0]) {
          videoRef.current.srcObject = event.streams[0];
          videoRef.current.play().catch((err) => {
            console.error("Video autoplay failed:", err);
          });

          // NEW: Set up video data timeout monitoring
          setIsWaitingForData(true);

          // Clear any existing timeout
          if (videoDataTimeoutRef.current) {
            clearTimeout(videoDataTimeoutRef.current);
          }

          // Set 2-second timeout for receiving video data
          videoDataTimeoutRef.current = setTimeout(() => {
            // Check if video is actually playing (has received data)
            if (
              videoRef.current &&
              (videoRef.current.readyState < 2 || videoRef.current.paused)
            ) {
              console.warn("No video data received within 2 seconds");
              setIsWaitingForData(true);
              setUserFriendlyStatus("Waiting for video data from camera...");
            }
          }, 2000);

          // Monitor video metadata to detect when data is actually flowing
          const handleVideoData = () => {
            if (videoDataTimeoutRef.current) {
              clearTimeout(videoDataTimeoutRef.current);
              videoDataTimeoutRef.current = null;
            }
            setIsWaitingForData(false);
            setUserFriendlyStatus("Receiving live video stream");
            videoRef.current?.removeEventListener(
              "loadeddata",
              handleVideoData
            );
            videoRef.current?.removeEventListener("playing", handleVideoData);
          };

          videoRef.current.addEventListener("loadeddata", handleVideoData);
          videoRef.current.addEventListener("playing", handleVideoData);
        }
      };

      pc.onconnectionstatechange = () => {
        console.log("Connection state:", pc.connectionState);

        switch (pc.connectionState) {
          case "connected":
            setIsConnected(true);
            setIsConnecting(false);
            setIsReconnecting(false);
            setError(null);
            setUserFriendlyStatus("Live stream connected");
            resetReconnectionState();
            // Note: Don't update session status - we're just a viewer, RPi manages the session
            break;
          case "connecting":
            setIsConnecting(true);
            setUserFriendlyStatus("Establishing connection...");
            break;
          case "disconnected":
            setIsConnected(false);
            setIsConnecting(false);
            // Note: Don't update session status - viewer disconnection doesn't affect RPi session
            if (!isUserStoppedRef.current) {
              handleAutoReconnection();
            }
            break;
          case "failed":
            setIsConnected(false);
            setIsConnecting(false);
            // Note: Don't update session status - viewer connection failure doesn't affect RPi session
            if (!isUserStoppedRef.current) {
              handleAutoReconnection();
            }
            break;
          case "closed":
            setIsConnected(false);
            setIsConnecting(false);
            setConnectionQuality(null);
            // Note: Don't update session status - viewer disconnection doesn't end RPi session
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
            monitorConnectionQuality(pc);
            break;
          case "failed":
            setError(
              "Network connection failed - please check your internet connection"
            );
            break;
          case "disconnected":
            setError("Network connection lost - trying to reconnect...");
            break;
        }
      };

      // Add transceivers for receiving media
      pc.addTransceiver("video", { direction: "recvonly" });
      pc.addTransceiver("audio", { direction: "recvonly" });

      // Create offer
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      console.log("Created offer:", offer.type);

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
      try {
        const response = await ambulanceStreamingService.connectCameraViewer(
          cameraId,
          {
            sdp: pc.localDescription!.sdp,
            type: pc.localDescription!.type as any,
          }
        );

        if (response.data && response.data.sdp && response.data.type) {
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

          await pc.setRemoteDescription(
            new RTCSessionDescription({
              sdp: response.data.sdp,
              type: responseType,
            })
          );
          console.log(
            "Remote description set successfully for ambulance camera"
          );
        } else {
          const errorMessage =
            response.error || "No SDP answer received from server";
          throw new Error(errorMessage);
        }
      } catch (err) {
        console.error("Failed to set remote description:", err);
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
    async (ambulanceId: string, cameraId?: string): Promise<void> => {
      if (isConnecting || isConnected) {
        console.warn("Streaming already in progress");
        return;
      }

      if (!ambulanceId) {
        setError("Ambulance ID is required for streaming");
        return;
      }

      try {
        setIsConnecting(true);
        setError(null);
        setUserFriendlyStatus("Looking for active ambulance camera...");
        isUserStoppedRef.current = false;
        currentAmbulanceIdRef.current = ambulanceId;
        resetReconnectionState();

        // Look for existing active session (started by RPi device)
        const session = await findActiveSession(ambulanceId);
        if (!session) {
          throw new Error(
            "No active ambulance session found. Please ensure the ambulance camera device is connected and streaming."
          );
        }

        // If no specific camera ID provided, get cameras for this ambulance
        let targetCameraId = cameraId;
        if (!targetCameraId) {
          const camerasResponse =
            await ambulanceStreamingService.getAmbulanceCameras(ambulanceId);
          if (camerasResponse.data && camerasResponse.data.length > 0) {
            targetCameraId = camerasResponse.data[0].id; // Use first available camera
          } else {
            throw new Error("No cameras found for this ambulance");
          }
        }

        // Store the camera ID after it's determined
        currentCameraIdRef.current = targetCameraId;

        // Clean up any existing connection
        if (peerConnectionRef.current) {
          peerConnectionRef.current.close();
        }

        if (!targetCameraId) {
          throw new Error("Camera ID is required for streaming");
        }
        const pc = await createPeerConnection(targetCameraId);
        peerConnectionRef.current = pc;

        console.log(
          "Ambulance streaming connection established with session:",
          session.id,
          "camera:",
          targetCameraId
        );
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
        setIsConnecting(false);
        setIsReconnecting(false);
        currentAmbulanceIdRef.current = null;
        currentCameraIdRef.current = null;

        // Note: Don't update session status - we're just a viewer, errors don't affect RPi session
      }
    },
    [
      isConnecting,
      isConnected,
      createPeerConnection,
      resetReconnectionState,
      findActiveSession,
      currentSession,
      updateSessionStatus,
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

    setIsConnected(false);
    setIsConnecting(false);
    setIsReconnecting(false);
    setConnectionQuality(null);
    setError(null);
    setUserFriendlyStatus("Disconnected from camera");

    console.log("Viewer disconnected from streaming");
  }, [resetReconnectionState]);

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

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopStreaming();
    };
  }, [stopStreaming]);

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
