/**
 * HLSPlayer Component
 *
 * Reusable HLS video player with built-in controls, status indicators,
 * and error handling. Uses HLS.js for adaptive streaming.
 */

"use client";

import { useHLS } from "@/hooks/useHLS";
import { cn } from "@/utils/cn";
import {
  ArrowPathIcon,
  ExclamationCircleIcon,
  PauseIcon,
  PlayIcon,
  SignalIcon,
} from "@heroicons/react/24/outline";
import { useEffect, useState } from "react";

export interface HLSPlayerProps {
  /** Room ID for the recording (e.g., AMB-001-ROOM-001) */
  roomId: string | null;

  /** Auto-play when ready */
  autoPlay?: boolean;

  /** Show player controls */
  showControls?: boolean;

  /** Show status information */
  showStatus?: boolean;

  /** Show recording statistics */
  showStats?: boolean;

  /** Enable low latency mode for live streaming */
  lowLatencyMode?: boolean;

  /** Custom CSS classes */
  className?: string;

  /** Enable debug mode */
  debug?: boolean;

  /** Callback when player is ready */
  onReady?: () => void;

  /** Callback on error */
  onError?: (error: string) => void;
}

export function HLSPlayer({
  roomId,
  autoPlay = false,
  showControls = true,
  showStatus = true,
  showStats = false,
  lowLatencyMode = false,
  className,
  debug = false,
  onReady,
  onError,
}: HLSPlayerProps) {
  const {
    videoRef,
    isLoading,
    error,
    status,
    recordingStatus,
    isHLSReady,
    reload,
    play,
    pause,
  } = useHLS({
    roomId,
    autoPlay,
    lowLatencyMode,
    debug,
  });

  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  // Video event handlers
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);
    const handleTimeUpdate = () => setCurrentTime(video.currentTime);
    const handleDurationChange = () => setDuration(video.duration);

    video.addEventListener("play", handlePlay);
    video.addEventListener("pause", handlePause);
    video.addEventListener("timeupdate", handleTimeUpdate);
    video.addEventListener("durationchange", handleDurationChange);

    return () => {
      video.removeEventListener("play", handlePlay);
      video.removeEventListener("pause", handlePause);
      video.removeEventListener("timeupdate", handleTimeUpdate);
      video.removeEventListener("durationchange", handleDurationChange);
    };
  }, [videoRef]);

  // Callbacks
  useEffect(() => {
    if (isHLSReady && onReady) {
      onReady();
    }
  }, [isHLSReady, onReady]);

  useEffect(() => {
    if (error && onError) {
      onError(error);
    }
  }, [error, onError]);

  // Format time helper
  const formatTime = (seconds: number): string => {
    if (!isFinite(seconds)) return "0:00";

    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  // Handle play/pause toggle
  const handlePlayPause = async () => {
    if (isPlaying) {
      pause();
    } else {
      try {
        await play();
      } catch (err) {
        console.error("Play error:", err);
      }
    }
  };

  return (
    <div className={cn("hls-player relative", className)}>
      {/* Video Element */}
      <div className="relative bg-black rounded-lg overflow-hidden">
        <video
          ref={videoRef}
          className="w-full aspect-video object-contain"
          controls={showControls}
          playsInline
        />

        {/* Loading Overlay */}
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75">
            <div className="text-center text-white">
              <ArrowPathIcon className="w-12 h-12 animate-spin mx-auto mb-2" />
              <p className="text-sm">{status}</p>
            </div>
          </div>
        )}

        {/* Error Overlay */}
        {error && (
          <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75">
            <div className="text-center text-white max-w-md px-4">
              <ExclamationCircleIcon className="w-12 h-12 text-red-500 mx-auto mb-2" />
              <p className="text-sm mb-4">{error}</p>
              <button
                onClick={reload}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-sm font-medium"
              >
                Retry
              </button>
            </div>
          </div>
        )}

        {/* Live Indicator */}
        {recordingStatus?.is_active && (
          <div className="absolute top-4 left-4 flex items-center gap-2 bg-red-600 text-white px-3 py-1 rounded-full text-xs font-semibold">
            <SignalIcon className="w-4 h-4 animate-pulse" />
            LIVE
          </div>
        )}
      </div>

      {/* Status Bar */}
      {showStatus && !isLoading && !error && (
        <div className="mt-2 flex items-center justify-between text-sm text-gray-600">
          <div className="flex items-center gap-2">
            <span
              className={cn(
                "w-2 h-2 rounded-full",
                isHLSReady ? "bg-green-500" : "bg-yellow-500"
              )}
            />
            <span>{status}</span>
          </div>

          {duration > 0 && (
            <div className="text-xs">
              {formatTime(currentTime)} / {formatTime(duration)}
            </div>
          )}
        </div>
      )}

      {/* Statistics */}
      {showStats && recordingStatus && (
        <div className="mt-4 p-4 bg-gray-50 rounded-lg space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-gray-600">Room ID:</span>
            <span className="font-mono text-xs">{recordingStatus.room_id}</span>
          </div>

          {recordingStatus.session_id && (
            <div className="flex justify-between">
              <span className="text-gray-600">Session ID:</span>
              <span className="font-mono text-xs">
                {recordingStatus.session_id}
              </span>
            </div>
          )}

          {recordingStatus.segment_count !== undefined && (
            <div className="flex justify-between">
              <span className="text-gray-600">Segments:</span>
              <span className="font-semibold">
                {recordingStatus.segment_count}
              </span>
            </div>
          )}

          {recordingStatus.duration !== undefined && (
            <div className="flex justify-between">
              <span className="text-gray-600">Duration:</span>
              <span className="font-semibold">{recordingStatus.duration}s</span>
            </div>
          )}

          <div className="flex justify-between">
            <span className="text-gray-600">Status:</span>
            <span
              className={cn(
                "font-semibold capitalize",
                recordingStatus.is_active ? "text-red-600" : "text-green-600"
              )}
            >
              {recordingStatus.status}
            </span>
          </div>

          {recordingStatus.hls_ready !== undefined && (
            <div className="flex justify-between">
              <span className="text-gray-600">HLS Ready:</span>
              <span
                className={cn(
                  "font-semibold",
                  recordingStatus.hls_ready
                    ? "text-green-600"
                    : "text-yellow-600"
                )}
              >
                {recordingStatus.hls_ready ? "Yes" : "No"}
              </span>
            </div>
          )}
        </div>
      )}

      {/* Custom Controls (if native controls disabled) */}
      {!showControls && isHLSReady && (
        <div className="mt-4 flex items-center justify-center gap-4">
          <button
            onClick={handlePlayPause}
            className="p-3 bg-blue-600 hover:bg-blue-700 text-white rounded-full transition-colors"
            aria-label={isPlaying ? "Pause" : "Play"}
          >
            {isPlaying ? (
              <PauseIcon className="w-6 h-6" />
            ) : (
              <PlayIcon className="w-6 h-6" />
            )}
          </button>

          <button
            onClick={reload}
            className="p-3 bg-gray-600 hover:bg-gray-700 text-white rounded-full transition-colors"
            aria-label="Reload"
          >
            <ArrowPathIcon className="w-6 h-6" />
          </button>
        </div>
      )}
    </div>
  );
}

export default HLSPlayer;
