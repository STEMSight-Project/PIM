'use client';

import React, { useRef, useEffect, useState } from "react";

interface VideoPlayerProps {
    currentTimestamp: number;
    onTimeUpdate?: (time: number) => void;
}
const VideoPlayer: React.FC<VideoPlayerProps> = ({ currentTimestamp, onTimeUpdate }) => {
    const videoRef = useRef<HTMLVideoElement>(null);

    // When a timestamp button is clicked, move to that timestamp in the video player
    useEffect(() => {
        if (videoRef.current) {
            console.log("VideoPlayer: Seeking to timestamp:", currentTimestamp);
            videoRef.current.currentTime = currentTimestamp;
        }
    }, [currentTimestamp]); // only depend on currentTimestamp

    // tracks the current video playback time (when user wants to link the timestamp to a note)
    useEffect(() => {
        const videoElement = videoRef.current;

        const handleTimeUpdate = () => {
            if (videoElement && onTimeUpdate) {
                onTimeUpdate(videoElement.currentTime);
            }
        };

        if (videoElement) {
            videoElement.addEventListener('timeupdate', handleTimeUpdate);
        }

        return () => {
            if (videoElement) {
                videoElement.removeEventListener('timeupdate', handleTimeUpdate);
            }
        };
    }, [onTimeUpdate]);

    return (

        <div className="video-container">
            <video
                ref={videoRef}
                src="/videos/count_up.mp4"
                controls
                className="w-full max-w-3xl"
            />
            {/* Display last clicked timestamp (for debugging) */}
            <div className="mt-2 text-xs text-gray-500">
                Current timestamp: {currentTimestamp.toFixed(2)} seconds
            </div>
        </div>
    );
};

export default VideoPlayer;