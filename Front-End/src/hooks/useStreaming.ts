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
          case "disconnected":
          case "failed":
            setIsConnected(false);
            setIsConnecting(false);
            setError("Connection failed or disconnected");
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

        if (pc.iceConnectionState === "connected") {
          monitorConnectionQuality(pc);
        }
      };

      // Add transceivers for receiving media
      pc.addTransceiver("video", { direction: "recvonly" });
      pc.addTransceiver("audio", { direction: "recvonly" });

      // Create offer
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      // Wait for ICE gathering to complete
      await new Promise<void>((resolve) => {
        if (pc.iceGatheringState === "complete") {
          resolve();
          return;
        }

        const handleICEGatheringStateChange = () => {
          if (pc.iceGatheringState === "complete") {
            pc.removeEventListener(
              "icegatheringstatechange",
              handleICEGatheringStateChange
            );
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

        if (response.data) {
          await pc.setRemoteDescription(
            new RTCSessionDescription({
              sdp: response.data.sdp,
              type: response.data.type as RTCSdpType,
            })
          );
          console.log("Remote description set successfully");
        } else {
          throw new Error("No SDP answer received from server");
        }
      } catch (err) {
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
        const message =
          err instanceof Error ? err.message : "Failed to start streaming";
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
