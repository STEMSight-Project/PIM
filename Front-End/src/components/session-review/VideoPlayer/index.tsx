"use client";

import React, { useRef, useEffect } from "react";

interface VideoPlayerProps {
  videoUrl: string | null; 
  currentTimestamp: number;
  onTimeUpdate?: (time: number) => void;
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({
  videoUrl,
  currentTimestamp,
  onTimeUpdate,
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);

  // Seek to timestamp when updated
  useEffect(() => {
    if (videoRef.current) {
      console.log("VideoPlayer: Seeking to timestamp:", currentTimestamp);
      videoRef.current.currentTime = currentTimestamp;
    }
  }, [currentTimestamp]);

  // Track current time updates
  useEffect(() => {
    const videoElement = videoRef.current;

    const handleTimeUpdate = () => {
      if (videoElement && onTimeUpdate) {
        onTimeUpdate(videoElement.currentTime);
      }
    };

    if (videoElement) {
      videoElement.addEventListener("timeupdate", handleTimeUpdate);
    }

    return () => {
      if (videoElement) {
        videoElement.removeEventListener("timeupdate", handleTimeUpdate);
      }
    };
  }, [onTimeUpdate]);

  return (
    <div className="video-container">
      {videoUrl ? (
        <video
          ref={videoRef}
          src={videoUrl}
          controls
          className="w-full max-w-3xl"
        />
      ) : (
        <p className="text-gray-500 text-sm">No video loaded</p>
      )}

      <div className="mt-2 text-xs text-gray-500">
        Current timestamp: {currentTimestamp.toFixed(2)} seconds
      </div>
    </div>
  );
};

export default VideoPlayer;
