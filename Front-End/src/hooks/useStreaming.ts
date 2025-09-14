"use client";

import { streamingService } from "@/services";
import { useCallback, useEffect, useRef, useState } from "react";

interface UseStreamingReturn {
  // State
  isConnected: boolean;
  isConnecting: boolean;
  error: string | null;
  connectionQuality: "poor" | "fair" | "good" | "excellent" | null;

  // Refs for external access
  videoRef: React.RefObject<HTMLVideoElement | null>;
  peerConnectionRef: React.RefObject<RTCPeerConnection | null>;

  // Actions
  startStreaming: (patientId: string) => Promise<void>;
  stopStreaming: () => void;
  clearError: () => void;
  toggleFullscreen: () => void;
}

export function useStreaming(): UseStreamingReturn {
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [connectionQuality, setConnectionQuality] = useState<
    "poor" | "fair" | "good" | "excellent" | null
  >(null);

  const videoRef = useRef<HTMLVideoElement>(null);
  const peerConnectionRef = useRef<RTCPeerConnection | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

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
    async (patientId: string): Promise<RTCPeerConnection> => {
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
        }
      };

      pc.onconnectionstatechange = () => {
        console.log("Connection state:", pc.connectionState);

        switch (pc.connectionState) {
          case "connected":
            setIsConnected(true);
            setIsConnecting(false);
            setError(null);
            break;
          case "connecting":
            setIsConnecting(true);
            break;
          case "disconnected":
            setIsConnected(false);
            setIsConnecting(false);
            setError("Connection lost - attempting to reconnect...");
            break;
          case "failed":
            setIsConnected(false);
            setIsConnecting(false);
            setError("Connection failed - please check your network and try again");
            break;
          case "closed":
            setIsConnected(false);
            setIsConnecting(false);
            setConnectionQuality(null);
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
            setError("Network connection failed - please check your internet connection");
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

      // Send offer to server and get answer
      try {
        const response = await streamingService.publishViewer(patientId, {
          sdp: pc.localDescription!.sdp,
          type: pc.localDescription!.type,
        });

        if (response.data && response.data.sdp && response.data.type) {
          // Validate that the type is a valid RTCSdpType
          const validTypes: RTCSdpType[] = ["answer", "offer", "pranswer", "rollback"];
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
          console.log("Remote description set successfully");
        } else {
          const errorMessage = response.error || "No SDP answer received from server";
          throw new Error(errorMessage);
        }
      } catch (err) {
        console.error("Failed to set remote description:", err);
        pc.close();
        throw err;
      }

      return pc;
    },
    [monitorConnectionQuality]
  );

  const startStreaming = useCallback(
    async (patientId: string): Promise<void> => {
      if (isConnecting || isConnected) {
        console.warn("Streaming already in progress");
        return;
      }

      if (!patientId) {
        setError("Patient ID is required for streaming");
        return;
      }

      try {
        setIsConnecting(true);
        setError(null);

        // Clean up any existing connection
        if (peerConnectionRef.current) {
          peerConnectionRef.current.close();
        }

        const pc = await createPeerConnection(patientId);
        peerConnectionRef.current = pc;

        console.log("Streaming connection established");
      } catch (err) {
        let message = "Failed to start streaming";
        
        if (err instanceof Error) {
          if (err.message.includes("Invalid SDP type")) {
            message = "Server returned invalid session data. Please try again.";
          } else if (err.message.includes("No SDP answer")) {
            message = "Server did not respond with streaming data. Check if the camera is available.";
          } else {
            message = err.message;
          }
        }
        
        setError(message);
        console.error("Error starting streaming:", err);
        setIsConnecting(false);
      }
    },
    [isConnecting, isConnected, createPeerConnection]
  );

  const stopStreaming = useCallback(() => {
    if (peerConnectionRef.current) {
      peerConnectionRef.current.close();
      peerConnectionRef.current = null;
    }

    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }

    setIsConnected(false);
    setIsConnecting(false);
    setConnectionQuality(null);
    setError(null);

    console.log("Streaming stopped");
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
    error,
    connectionQuality,
    videoRef,
    peerConnectionRef,
    startStreaming,
    stopStreaming,
    clearError,
    toggleFullscreen,
  };
}
