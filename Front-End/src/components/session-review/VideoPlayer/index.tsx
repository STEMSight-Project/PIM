"use client";

import React, { useRef, useEffect } from "react";

interface VideoPlayerProps {
  videoUrl: string | null;
  currentTimestamp: number;
  onTimeUpdate?: (time: number) => void;
}

const DEFAULT_TEST_URL =
  process.env.NEXT_PUBLIC_TEST_VIDEO_URL ?? "/test-video.mp4";

export default function VideoPlayer({
  videoUrl,
  currentTimestamp,
  onTimeUpdate,
}: VideoPlayerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const src = videoUrl ?? DEFAULT_TEST_URL;

  // Seek robustly (works even if metadata isn't ready yet)
  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;

    const seek = () => {
      try {
        v.currentTime = Number.isFinite(currentTimestamp)
          ? currentTimestamp
          : 0;
      } catch (err) {
        console.warn("Failed to set currentTime:", err);
      }
    };

    if (v.readyState >= 1) {
      seek();
    } else {
      v.addEventListener("loadedmetadata", seek, { once: true });
      return () => v.removeEventListener("loadedmetadata", seek);
    }
  }, [currentTimestamp, src]);

  // Emit time updates & log errors
  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;

    const handleTimeUpdate = () => onTimeUpdate?.(v.currentTime);
    const handleError = () => {
      console.error("Video error:", {
        src: v.currentSrc,
        error: v.error,
        readyState: v.readyState,
        networkState: v.networkState,
      });
    };

    v.addEventListener("timeupdate", handleTimeUpdate);
    v.addEventListener("error", handleError);
    return () => {
      v.removeEventListener("timeupdate", handleTimeUpdate);
      v.removeEventListener("error", handleError);
    };
  }, [onTimeUpdate, src]);

  return (
    <>
      <div className="relative aspect-video bg-gray-900 rounded-xl overflow-hidden">
        {src ? (
          <video
            ref={videoRef}
            src={src}
            controls
            preload="metadata"
            playsInline
            className="absolute inset-0 w-full h-full object-contain"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center bg-gray-100">
            <div className="text-center">
              <svg
                className="w-12 h-12 mx-auto mb-3 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                />
              </svg>
              <p className="text-gray-500">No video available</p>
            </div>
          </div>
        )}
      </div>

      <div className="mt-2 text-xs text-gray-500">
        Current timestamp: {currentTimestamp.toFixed(2)} seconds
      </div>
    </>
  );
}
