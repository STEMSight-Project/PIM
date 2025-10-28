/**
 * HybridStreamPlayer Component
 *
 * Unified video player supporting:
 * - Live WebRTC streaming (low latency)
 * - HLS playback (for time-shifting/DVR)
 * - Seamless switching between modes
 * - Timeline scrubbing with live edge indicator
 * - "Go Live" button to jump to current time
 *
 * Usage:
 * <HybridStreamPlayer
 *   ambulanceId="AMB-001"
 *   roomId="AMB-001-ROOM-001"
 * />
 */

"use client";

import { Button } from "@/components/ui/Button";
import { useHLS } from "@/hooks/useHLS";
import { useStreaming } from "@/hooks/useStreaming";
import { cn } from "@/utils/cn";
import {
  ArrowPathIcon,
  BackwardIcon,
  ForwardIcon,
  PauseIcon,
  PlayIcon,
  SignalIcon,
} from "@heroicons/react/24/outline";
import { useCallback, useEffect, useMemo, useState } from "react";

interface HybridStreamPlayerProps {
  /** Ambulance ID for live streaming */
  ambulanceId: string;

  /** Camera room ID for both live streaming and HLS playback */
  roomId: string;

  /** Custom CSS classes */
  className?: string;

  /** Show advanced controls */
  showAdvancedControls?: boolean;

  /** Debug mode */
  debug?: boolean;
}

type ViewMode = "live" | "playback";

export function HybridStreamPlayer({
  ambulanceId,
  roomId,
  className,
  showAdvancedControls = false,
  debug = false,
}: HybridStreamPlayerProps) {
  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  const [viewMode, setViewMode] = useState<ViewMode>("live");
  const [isPlaying, setIsPlaying] = useState(true);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [timeBehindLive, setTimeBehindLive] = useState(0);
  const [liveEdgeDuration, setLiveEdgeDuration] = useState(0); // Total recording duration

  // ============================================================================
  // HOOKS - LIVE STREAMING (WebRTC)
  // ============================================================================

  const {
    videoRef: liveVideoRef,
    isConnected: isLiveConnected,
    isConnecting: isLiveConnecting,
    startStreaming,
    stopStreaming,
    error: liveError,
    userFriendlyStatus: liveStatus,
    isWaitingForData,
  } = useStreaming();

  // ============================================================================
  // HOOKS - HLS PLAYBACK
  // ============================================================================

  const {
    videoRef: hlsVideoRef,
    isLoading: isHLSLoading,
    isHLSReady,
    play: playHLS,
    pause: pauseHLS,
    seek: seekHLS,
    error: hlsError,
    recordingStatus,
  } = useHLS({
    roomId,
    autoPlay: false,
    lowLatencyMode: false,
    debug,
  });

  // ============================================================================
  // COMPUTED VALUES
  // ============================================================================

  // Active video ref based on mode
  const activeVideoRef = viewMode === "live" ? liveVideoRef : hlsVideoRef;

  // Check if near live edge (within 5 seconds)
  const isNearLive = useMemo(() => {
    if (viewMode === "live") return true;
    return timeBehindLive < 5;
  }, [viewMode, timeBehindLive]);

  // Check if recording is available
  const hasRecording = !!roomId && !!recordingStatus;

  // ============================================================================
  // EFFECTS - AUTO-START LIVE STREAMING
  // ============================================================================

  useEffect(() => {
    if (viewMode === "live" && !isLiveConnected && !isLiveConnecting) {
      if (debug) console.log("[HybridPlayer] Auto-starting live stream");
      startStreaming(ambulanceId, roomId);
    }
  }, [
    viewMode,
    ambulanceId,
    roomId,
    isLiveConnected,
    isLiveConnecting,
    startStreaming,
    debug,
  ]);

  // ============================================================================
  // EFFECTS - VIDEO EVENT LISTENERS (PLAYBACK MODE)
  // ============================================================================

  useEffect(() => {
    const video = hlsVideoRef.current;
    if (!video || viewMode !== "playback") return;

    const handleTimeUpdate = () => {
      setCurrentTime(video.currentTime);
      setDuration(video.duration || 0);
    };

    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);

    video.addEventListener("timeupdate", handleTimeUpdate);
    video.addEventListener("play", handlePlay);
    video.addEventListener("pause", handlePause);
    video.addEventListener("loadedmetadata", handleTimeUpdate);

    return () => {
      video.removeEventListener("timeupdate", handleTimeUpdate);
      video.removeEventListener("play", handlePlay);
      video.removeEventListener("pause", handlePause);
      video.removeEventListener("loadedmetadata", handleTimeUpdate);
    };
  }, [hlsVideoRef, viewMode]);

  // ============================================================================
  // EFFECTS - POLL DVR INFO (Update live edge during playback)
  // ============================================================================

  useEffect(() => {
    if (!roomId || viewMode !== "playback") return;

    const updateLiveEdge = async () => {
      try {
        // Use room-based status endpoint
        const response = await fetch(
          `/api/videos/hls/${roomId}/status`
        );
        const data = await response.json();

        if (data && data.is_active) {
          // For active recordings, use duration
          const newDuration = data.duration || 0;
          setLiveEdgeDuration(newDuration);

          if (debug) {
            console.log(
              `[HybridPlayer] Live edge: ${newDuration}s, Current: ${currentTime}s`
            );
          }
        }
      } catch (error) {
        console.error("[HybridPlayer] Failed to fetch recording status:", error);
      }
    };

    // Initial fetch
    updateLiveEdge();

    // Poll every 5 seconds
    const interval = setInterval(updateLiveEdge, 5000);

    return () => clearInterval(interval);
  }, [roomId, viewMode, currentTime, debug]);

  // ============================================================================
  // EFFECTS - CALCULATE TIME BEHIND LIVE
  // ============================================================================

  useEffect(() => {
    if (viewMode === "playback" && liveEdgeDuration > 0) {
      const behind = liveEdgeDuration - currentTime;
      setTimeBehindLive(Math.max(0, behind));
    } else {
      setTimeBehindLive(0);
    }
  }, [viewMode, currentTime, liveEdgeDuration]);

  // ============================================================================
  // ACTIONS - MODE SWITCHING
  // ============================================================================

  const switchToPlayback = useCallback(() => {
    if (debug) console.log("[HybridPlayer] Switching to playback mode");
    setViewMode("playback");

    // Stop live stream
    if (isLiveConnected) {
      stopStreaming();
    }
  }, [isLiveConnected, stopStreaming, debug]);

  const switchToLive = useCallback(() => {
    if (debug) console.log("[HybridPlayer] Switching to live mode");
    setViewMode("live");
    setTimeBehindLive(0);

    // Pause HLS if playing
    if (hlsVideoRef.current && !hlsVideoRef.current.paused) {
      pauseHLS();
    }
  }, [hlsVideoRef, pauseHLS, debug]);

  // ============================================================================
  // ACTIONS - PLAYBACK CONTROLS
  // ============================================================================

  const handlePlayPause = useCallback(() => {
    if (viewMode === "live") {
      // Pause in live mode = switch to playback
      if (!hasRecording) {
        alert("Recording not available yet. Please wait a few seconds.");
        return;
      }
      switchToPlayback();
    } else {
      // Normal play/pause in playback mode
      if (isPlaying) {
        pauseHLS();
      } else {
        playHLS();
      }
    }
  }, [viewMode, isPlaying, hasRecording, switchToPlayback, pauseHLS, playHLS]);

  const handleSeek = useCallback(
    (time: number) => {
      if (viewMode === "live") {
        // Auto-switch to playback when scrubbing from live
        switchToPlayback();
      }
      seekHLS(time);
    },
    [viewMode, switchToPlayback, seekHLS]
  );

  const handleSkipBackward = useCallback(() => {
    const newTime = Math.max(0, currentTime - 10);
    handleSeek(newTime);
  }, [currentTime, handleSeek]);

  const handleSkipForward = useCallback(() => {
    const newTime = Math.min(duration, currentTime + 10);
    handleSeek(newTime);
  }, [currentTime, duration, handleSeek]);

  // ============================================================================
  // UTILITIES
  // ============================================================================

  const formatTime = useCallback((seconds: number): string => {
    if (!isFinite(seconds) || seconds < 0) return "0:00";

    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  }, []);

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <div className={cn("hybrid-stream-player relative", className)}>
      {/* ====================================================================
          VIDEO CONTAINER
          ==================================================================== */}
      <div className="relative bg-black rounded-lg overflow-hidden aspect-video">
        {/* Live Video Element (WebRTC) */}
        <video
          ref={liveVideoRef}
          className={cn(
            "w-full h-full object-contain",
            viewMode !== "live" && "hidden"
          )}
          autoPlay
          playsInline
          muted={false}
        />

        {/* HLS Video Element (Playback) */}
        <video
          ref={hlsVideoRef}
          className={cn(
            "w-full h-full object-contain",
            viewMode !== "playback" && "hidden"
          )}
          playsInline
          muted={false}
        />

        {/* ==================================================================
            OVERLAYS
            ================================================================== */}

        {/* LIVE Indicator (top-left) */}
        {viewMode === "live" && isLiveConnected && (
          <div className="absolute top-4 left-4 flex items-center gap-2 bg-red-600 text-white px-3 py-1.5 rounded-full text-sm font-semibold shadow-lg z-10">
            <SignalIcon className="w-4 h-4 animate-pulse" />
            LIVE
          </div>
        )}

        {/* Time Behind Live Indicator (top-left, playback mode) */}
        {viewMode === "playback" && !isNearLive && timeBehindLive > 0 && (
          <div className="absolute top-4 left-4 flex items-center gap-2 bg-gray-900 bg-opacity-90 text-white px-3 py-1.5 rounded-lg text-sm font-medium shadow-lg z-10">
            <ArrowPathIcon className="w-4 h-4" />-{formatTime(timeBehindLive)}{" "}
            behind live
          </div>
        )}

        {/* Loading Overlay */}
        {(isLiveConnecting ||
          isHLSLoading ||
          (viewMode === "live" && isWaitingForData)) && (
          <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 z-20">
            <div className="text-center text-white">
              <ArrowPathIcon className="w-12 h-12 animate-spin mx-auto mb-3" />
              <p className="text-lg font-medium">
                {viewMode === "live"
                  ? isWaitingForData
                    ? "Waiting for video data..."
                    : "Connecting to live stream..."
                  : "Loading playback..."}
              </p>
              {liveStatus && viewMode === "live" && (
                <p className="text-sm text-gray-300 mt-2">{liveStatus}</p>
              )}
            </div>
          </div>
        )}

        {/* Error Overlay */}
        {(liveError || hlsError) && (
          <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-90 z-20">
            <div className="text-center text-white p-6 max-w-md">
              <div className="w-16 h-16 mx-auto mb-4 bg-red-500 bg-opacity-20 rounded-full flex items-center justify-center">
                <SignalIcon className="w-8 h-8 text-red-400" />
              </div>
              <p className="text-red-400 font-medium text-lg mb-2">
                Connection Error
              </p>
              <p className="text-sm text-gray-300">
                {viewMode === "live" ? liveError : hlsError}
              </p>
            </div>
          </div>
        )}

        {/* No Recording Available (playback mode) */}
        {viewMode === "playback" && !roomId && (
          <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-90 z-20">
            <div className="text-center text-white p-6">
              <p className="text-gray-400 text-lg">
                No recording available yet
              </p>
              <Button
                onClick={switchToLive}
                className="mt-4 bg-red-600 hover:bg-red-700"
              >
                <SignalIcon className="w-5 h-5 mr-2 animate-pulse" />
                Go to Live Stream
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* ====================================================================
          CUSTOM CONTROLS
          ==================================================================== */}
      <div className="mt-4 space-y-3 bg-gray-50 rounded-lg p-4">
        {/* Timeline Scrubber (show when recording available) */}
        {hasRecording && (
          <div className="flex items-center gap-3">
            <span className="text-sm text-gray-700 font-medium min-w-[50px] tabular-nums">
              {formatTime(viewMode === "live" ? 0 : currentTime)}
            </span>

            {/* Timeline Slider */}
            <div className="flex-1 relative">
              <input
                type="range"
                min={0}
                max={viewMode === "live" ? liveEdgeDuration : duration}
                value={viewMode === "live" ? liveEdgeDuration : currentTime}
                onChange={(e) => handleSeek(Number(e.target.value))}
                className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer slider"
                disabled={viewMode === "live"}
                title={
                  viewMode === "live"
                    ? "Click to pause and enable scrubbing"
                    : "Drag to seek"
                }
              />

              {/* Live Edge Marker (when in playback) */}
              {viewMode === "playback" && liveEdgeDuration > 0 && (
                <div
                  className="absolute top-0 h-2 w-1 bg-red-500 pointer-events-none"
                  style={{
                    left: `${(liveEdgeDuration / (duration || 1)) * 100}%`,
                  }}
                  title="Live edge"
                />
              )}
            </div>

            <span className="text-sm text-gray-700 font-medium min-w-[50px] tabular-nums">
              {viewMode === "live"
                ? "LIVE"
                : formatTime(liveEdgeDuration || duration)}
            </span>
          </div>
        )}

        {/* Control Buttons */}
        <div className="flex items-center justify-between">
          {/* Left: Playback Controls */}
          <div className="flex items-center gap-2">
            {/* Skip Backward (only in playback) */}
            {showAdvancedControls && viewMode === "playback" && (
              <Button
                onClick={handleSkipBackward}
                variant="outline"
                size="sm"
                title="Skip backward 10 seconds"
              >
                <BackwardIcon className="w-5 h-5" />
              </Button>
            )}

            {/* Play/Pause Button */}
            <Button
              onClick={handlePlayPause}
              className={cn(
                "flex items-center gap-2",
                viewMode === "live" && isLiveConnected
                  ? "bg-blue-600 hover:bg-blue-700"
                  : ""
              )}
            >
              {viewMode === "live" && isLiveConnected ? (
                <>
                  <PauseIcon className="w-5 h-5" />
                  <span className="hidden sm:inline">Pause</span>
                </>
              ) : isPlaying ? (
                <>
                  <PauseIcon className="w-5 h-5" />
                  <span className="hidden sm:inline">Pause</span>
                </>
              ) : (
                <>
                  <PlayIcon className="w-5 h-5" />
                  <span className="hidden sm:inline">Play</span>
                </>
              )}
            </Button>

            {/* Skip Forward (only in playback) */}
            {showAdvancedControls && viewMode === "playback" && (
              <Button
                onClick={handleSkipForward}
                variant="outline"
                size="sm"
                title="Skip forward 10 seconds"
              >
                <ForwardIcon className="w-5 h-5" />
              </Button>
            )}

            {/* Mode Indicator */}
            <span className="text-sm text-gray-600 font-medium ml-2">
              {viewMode === "live" ? (
                <span className="flex items-center gap-1.5">
                  <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
                  Live Streaming
                </span>
              ) : (
                "Playback"
              )}
            </span>
          </div>

          {/* Right: Go Live Button (show when in playback and behind live) */}
          {viewMode === "playback" && !isNearLive && (
            <Button
              onClick={switchToLive}
              className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white"
            >
              <SignalIcon className="w-5 h-5 animate-pulse" />
              <span className="hidden sm:inline">Go Live</span>
            </Button>
          )}
        </div>

        {/* Debug Info (if enabled) */}
        {debug && (
          <div className="mt-3 p-3 bg-gray-100 rounded text-xs font-mono space-y-1">
            <div>Mode: {viewMode}</div>
            <div>Current Time: {currentTime.toFixed(2)}s</div>
            <div>Duration: {duration.toFixed(2)}s</div>
            <div>Live Edge: {liveEdgeDuration.toFixed(2)}s</div>
            <div>Behind Live: {timeBehindLive.toFixed(2)}s</div>
            <div>Is Playing: {isPlaying ? "Yes" : "No"}</div>
            <div>Live Connected: {isLiveConnected ? "Yes" : "No"}</div>
            <div>HLS Ready: {isHLSReady ? "Yes" : "No"}</div>
          </div>
        )}
      </div>

      {/* ====================================================================
          CUSTOM SLIDER STYLES
          ==================================================================== */}
      <style jsx>{`
        .slider::-webkit-slider-thumb {
          appearance: none;
          width: 16px;
          height: 16px;
          border-radius: 50%;
          background: #3b82f6;
          cursor: pointer;
          transition: all 0.2s;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .slider::-webkit-slider-thumb:hover {
          width: 20px;
          height: 20px;
          background: #2563eb;
          box-shadow: 0 3px 6px rgba(0, 0, 0, 0.3);
        }

        .slider::-moz-range-thumb {
          width: 16px;
          height: 16px;
          border-radius: 50%;
          background: #3b82f6;
          cursor: pointer;
          border: none;
          transition: all 0.2s;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .slider::-moz-range-thumb:hover {
          width: 20px;
          height: 20px;
          background: #2563eb;
          box-shadow: 0 3px 6px rgba(0, 0, 0, 0.3);
        }

        .slider:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .slider:disabled::-webkit-slider-thumb {
          cursor: not-allowed;
        }

        .slider:disabled::-moz-range-thumb {
          cursor: not-allowed;
        }
      `}</style>
    </div>
  );
}

export default HybridStreamPlayer;
