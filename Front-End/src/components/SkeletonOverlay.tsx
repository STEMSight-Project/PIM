/**
 * SkeletonOverlay Component
 * 
 * Draws MediaPipe pose skeleton on top of video stream
 * Receives landmark data via WebRTC data channel
 */

"use client";

import React, { useEffect, useRef } from "react";

interface Landmark {
  x: number;
  y: number;
  z: number;
  visibility?: number;
}

interface SkeletonOverlayProps {
  videoRef: React.RefObject<HTMLVideoElement | null>;
  landmarks: Landmark[] | null;
  enabled: boolean;
  className?: string;
}

// MediaPipe Pose connections (33 landmarks)
const POSE_CONNECTIONS = [
  // Face
  [0, 1], [1, 2], [2, 3], [3, 7], [0, 4], [4, 5], [5, 6], [6, 8],
  // Torso
  [9, 10], [11, 12], [11, 13], [13, 15], [15, 17], [15, 19], [15, 21],
  [12, 14], [14, 16], [16, 18], [16, 20], [16, 22],
  [11, 23], [12, 24], [23, 24],
  // Legs
  [23, 25], [25, 27], [27, 29], [29, 31], [27, 31],
  [24, 26], [26, 28], [28, 30], [30, 32], [28, 32],
];

export function SkeletonOverlay({
  videoRef,
  landmarks,
  enabled,
  className = "",
}: SkeletonOverlayProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const state = {
      enabled,
      hasLandmarks: !!landmarks,
      landmarkCount: landmarks?.length || 0,
      hasVideo: !!videoRef.current,
      hasCanvas: !!canvasRef.current,
      videoSize: videoRef.current
        ? `${videoRef.current.videoWidth}x${videoRef.current.videoHeight}`
        : "N/A",
      canvasSize: canvasRef.current
        ? `${canvasRef.current.width}x${canvasRef.current.height}`
        : "N/A",
    };
    console.log("🎨 [SkeletonOverlay] State update:", state);
    
    if (enabled && landmarks && landmarks.length > 0) {
      console.log(
        "✅ [SkeletonOverlay] READY TO DRAW - All conditions met!"
      );
    } else if (!enabled) {
      console.log("❌ [SkeletonOverlay] Disabled");
    } else if (!landmarks || landmarks.length === 0) {
      console.log("❌ [SkeletonOverlay] No landmarks available");
    }
    
    if (!enabled || !landmarks || !videoRef.current || !canvasRef.current) {
      // Clear canvas when disabled
      const canvas = canvasRef.current;
      if (canvas) {
        const ctx = canvas.getContext("2d");
        if (ctx) {
          ctx.clearRect(0, 0, canvas.width, canvas.height);
        }
      }
      return;
    }

    const video = videoRef.current;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d");

    if (!ctx) return;

    // Match canvas size to video display size
    const rect = video.getBoundingClientRect();
    canvas.width = rect.width;
    canvas.height = rect.height;

    console.log("🎨 [SkeletonOverlay] Drawing skeleton:", {
      landmarks: landmarks.length,
      canvasSize: `${canvas.width}x${canvas.height}`,
    });

    // Clear previous frame
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw skeleton
    drawSkeleton(ctx, landmarks, canvas.width, canvas.height);
  }, [landmarks, enabled, videoRef]);

  // Resize canvas when video size changes
  useEffect(() => {
    if (!videoRef.current || !canvasRef.current) return;

    const video = videoRef.current;
    const canvas = canvasRef.current;

    const resizeObserver = new ResizeObserver(() => {
      const rect = video.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
    });

    resizeObserver.observe(video);

    return () => resizeObserver.disconnect();
  }, [videoRef]);

  return (
    <canvas
      ref={canvasRef}
      className={`absolute inset-0 pointer-events-none z-10 ${className}`}
      style={{
        width: "100%",
        height: "100%",
      }}
    />
  );
}

function drawSkeleton(
  ctx: CanvasRenderingContext2D,
  landmarks: Landmark[],
  width: number,
  height: number
) {
  if (landmarks.length !== 33) return;

  // Draw connections
  ctx.strokeStyle = "rgba(0, 255, 0, 0.8)";
  ctx.lineWidth = 3;

  for (const [start, end] of POSE_CONNECTIONS) {
    const startLandmark = landmarks[start];
    const endLandmark = landmarks[end];

    // Skip if visibility is too low
    if (
      (startLandmark.visibility && startLandmark.visibility < 0.5) ||
      (endLandmark.visibility && endLandmark.visibility < 0.5)
    ) {
      continue;
    }

    const startX = startLandmark.x * width;
    const startY = startLandmark.y * height;
    const endX = endLandmark.x * width;
    const endY = endLandmark.y * height;

    ctx.beginPath();
    ctx.moveTo(startX, startY);
    ctx.lineTo(endX, endY);
    ctx.stroke();
  }

  // Draw landmarks (joints)
  ctx.fillStyle = "rgba(255, 0, 0, 0.9)";

  for (const landmark of landmarks) {
    // Skip if visibility is too low
    if (landmark.visibility && landmark.visibility < 0.5) {
      continue;
    }

    const x = landmark.x * width;
    const y = landmark.y * height;

    ctx.beginPath();
    ctx.arc(x, y, 5, 0, 2 * Math.PI);
    ctx.fill();
  }
}
