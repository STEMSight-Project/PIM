/**
 * HybridStreamPlayer - Live WebRTC + HLS Playback with DVR controls
 * Supports automatic streaming start and seamless mode switching
 */

"use client";

import { Button } from "@/components/ui/Button";
import { useHLS } from "@/hooks/useHLS";
import { useHLSSegmentEvents } from "@/hooks/useHLSSegmentEvents";
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
import React, { useCallback, useEffect, useMemo, useState } from "react";

interface HybridStreamPlayerProps {
  ambulanceId: string;
  roomId: string;
  className?: string;
  showAdvancedControls?: boolean;
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
  // State
  const [viewMode, setViewMode] = useState<ViewMode>("live");
  const [isPlaying, setIsPlaying] = useState(true);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [timeBehindLive, setTimeBehindLive] = useState(0);
  const [liveEdgeDuration, setLiveEdgeDuration] = useState(0);

  // Live streaming hook
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

  // HLS playback hook
  const {
    videoRef: hlsVideoRef,
    hls,
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
    statusPollingInterval: 10000,
  });

  // Real-time segment events
  useHLSSegmentEvents({
    roomId: viewMode === "playback" ? roomId : null,
    hls,
    autoReload: true,
    debug,
    onSegmentAdded: (event) => {
      if (debug) {
        console.log(`[HybridPlayer] New segment: ${event.segment_name}`);
      }
      if (hlsVideoRef.current) {
        setLiveEdgeDuration(hlsVideoRef.current.duration || 0);
      }
    },
  });

  // Computed values
  const isNearLive = useMemo(() => {
    if (viewMode === "live") return true;
    return timeBehindLive < 5;
  }, [viewMode, timeBehindLive]);
  const hasRecording = !!roomId && !!recordingStatus;

  // 🔥 CRITICAL: Auto-start live streaming on mount and mode changes
  useEffect(() => {
    console.log("[HybridPlayer] Auto-start effect triggered", {
      viewMode,
      isLiveConnected,
      isLiveConnecting,
      ambulanceId,
      roomId,
    });

    // Only auto-start in live mode
    if (viewMode !== "live") {
      console.log("[HybridPlayer] Not in live mode, skipping auto-start");
      return;
    }

    // Wait for roomId to be available (prevents race condition on initial load)
    if (!roomId) {
      console.log("[HybridPlayer] Room ID not ready yet, waiting...");
      return;
    }

    // If already connected or connecting, don't restart
    if (isLiveConnected || isLiveConnecting) {
      console.log("[HybridPlayer] Already connected/connecting, skipping");
      return;
    }

    // Start live streaming
    console.log("[HybridPlayer] Starting live stream");
    startStreaming(ambulanceId, roomId);

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [viewMode, ambulanceId, roomId]); // Don't include connection states to avoid loops

  // 🔥 CRITICAL: Cleanup on unmount or room change
  useEffect(() => {
    return () => {
      console.log(
        "[HybridPlayer] Component unmounting or room changed - cleanup"
      );
      stopStreaming();
      if (hlsVideoRef.current) {
        hlsVideoRef.current.pause();
        hlsVideoRef.current.src = "";
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [roomId, ambulanceId]); // Cleanup when room/ambulance changes

  // Video event listeners for playback mode

  // Video event listeners for playback mode
  useEffect(() => {
    const video = hlsVideoRef.current;
    if (!video || viewMode !== "playback") return;

    const handleTimeUpdate = () => {
      setCurrentTime(video.currentTime);
      setDuration(video.duration || 0);
    };
    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);
    const handleDurationChange = () => {
      const newDuration = video.duration || 0;
      if (newDuration !== duration) {
        setDuration(newDuration);
        if (debug)
          console.log(`[HybridPlayer] Duration: ${newDuration.toFixed(2)}s`);
      }
    };

    video.addEventListener("timeupdate", handleTimeUpdate);
    video.addEventListener("play", handlePlay);
    video.addEventListener("pause", handlePause);
    video.addEventListener("loadedmetadata", handleTimeUpdate);
    video.addEventListener("durationchange", handleDurationChange);

    return () => {
      video.removeEventListener("timeupdate", handleTimeUpdate);
      video.removeEventListener("play", handlePlay);
      video.removeEventListener("pause", handlePause);
      video.removeEventListener("loadedmetadata", handleTimeUpdate);
      video.removeEventListener("durationchange", handleDurationChange);
    };
  }, [hlsVideoRef, viewMode, duration, debug]);

  // Update live edge duration from recording status
  useEffect(() => {
    if (!recordingStatus || viewMode !== "playback") return;

    if (recordingStatus.is_active && recordingStatus.duration) {
      setLiveEdgeDuration(recordingStatus.duration || 0);
    } else if (!recordingStatus.is_active && recordingStatus.segment_count) {
      setLiveEdgeDuration(recordingStatus.segment_count * 10);
    }
  }, [recordingStatus, viewMode]);

  // Calculate time behind live
  useEffect(() => {
    if (viewMode === "playback" && liveEdgeDuration > 0) {
      setTimeBehindLive(Math.max(0, liveEdgeDuration - currentTime));
    } else {
      setTimeBehindLive(0);
    }
  }, [viewMode, currentTime, liveEdgeDuration]);

  // Mode switching actions

  // Mode switching actions
  const switchToPlayback = useCallback(() => {
    if (debug) console.log("[HybridPlayer] Switching to playback");
    setViewMode("playback");
    setIsPlaying(true);
    if (isLiveConnected) stopStreaming();

    setTimeout(() => {
      if (hlsVideoRef.current?.paused) {
        playHLS().catch((err) => console.warn("Auto-play failed:", err));
      }
    }, 100);
  }, [isLiveConnected, stopStreaming, hlsVideoRef, playHLS, debug]);

  const switchToLive = useCallback(() => {
    if (debug) console.log("[HybridPlayer] Switching to live");
    setViewMode("live");
    setTimeBehindLive(0);
    if (hlsVideoRef.current && !hlsVideoRef.current.paused) pauseHLS();
  }, [hlsVideoRef, pauseHLS, debug]);

  // Playback controls
  const handlePlayPause = useCallback(() => {
    if (viewMode === "live") {
      if (!hasRecording) {
        alert("Recording not available yet. Please wait a few seconds.");
        return;
      }
      switchToPlayback();
    } else {
      isPlaying ? pauseHLS() : playHLS();
    }
  }, [viewMode, isPlaying, hasRecording, switchToPlayback, pauseHLS, playHLS]);

  const handleSeek = useCallback(
    (time: number) => {
      if (viewMode === "live") {
        switchToPlayback();
        setTimeout(() => seekHLS(time), 100);
      } else {
        seekHLS(time);
      }
    },
    [viewMode, switchToPlayback, seekHLS]
  );

  const handleSkipBackward = useCallback(() => {
    handleSeek(Math.max(0, currentTime - 10));
  }, [currentTime, handleSeek]);

  const handleSkipForward = useCallback(() => {
    handleSeek(Math.min(duration, currentTime + 10));
  }, [currentTime, duration, handleSeek]);

  // Utilities
  const formatTime = useCallback((seconds: number): string => {
    if (!isFinite(seconds) || seconds < 0) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  }, []);

  // Timeline interaction state
  const [isHoveringTimeline, setIsHoveringTimeline] = useState(false);
  const [hoverTime, setHoverTime] = useState(0);
  const [hoverPosition, setHoverPosition] = useState(0);

  // Timeline click handler

  // Timeline click handler
  const handleTimelineClick = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      const rect = e.currentTarget.getBoundingClientRect();
      const percentage = (e.clientX - rect.left) / rect.width;
      const targetDuration = viewMode === "live" ? liveEdgeDuration : duration;
      const newTime = Math.max(
        0,
        Math.min(targetDuration, percentage * targetDuration)
      );

      if (viewMode === "live") {
        if (!hasRecording) {
          alert("Recording not available yet. Please wait a few seconds.");
          return;
        }
        switchToPlayback();
        setTimeout(() => {
          seekHLS(newTime);
          setIsPlaying(true);
        }, 150);
      } else {
        seekHLS(newTime);
        setIsPlaying(true);
        if (hlsVideoRef.current?.paused) {
          playHLS().catch((err) =>
            console.warn("Play after seek failed:", err)
          );
        }
      }
    },
    [
      viewMode,
      liveEdgeDuration,
      duration,
      hasRecording,
      switchToPlayback,
      seekHLS,
      hlsVideoRef,
      playHLS,
    ]
  );

  const handleTimelineMouseMove = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      const rect = e.currentTarget.getBoundingClientRect();
      const percentage = Math.max(
        0,
        Math.min(1, (e.clientX - rect.left) / rect.width)
      );
      const targetDuration = viewMode === "live" ? liveEdgeDuration : duration;
      setHoverPosition(percentage * 100);
      setHoverTime(percentage * targetDuration);
    },
    [viewMode, liveEdgeDuration, duration]
  );

  // Render
  return (
    <div className={cn("hybrid-stream-player relative", className)}>
      {/* Video Container */}
      <div className="relative bg-black rounded-xl overflow-hidden shadow-2xl">
        {/* Live Video (WebRTC) */}
        <video
          ref={liveVideoRef}
          className={cn(
            "w-full h-full object-contain aspect-video",
            viewMode !== "live" && "hidden"
          )}
          autoPlay
          playsInline
          muted={false}
        />

        {/* HLS Video (Playback) */}
        <video
          ref={hlsVideoRef}
          className={cn(
            "w-full h-full object-contain aspect-video",
            viewMode !== "playback" && "hidden"
          )}
          playsInline
          muted={false}
        />

        {/* LIVE Badge */}
        {viewMode === "live" && isLiveConnected && (
          <div className="absolute top-3 right-3 z-10">
            <div className="flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md text-sm font-bold shadow-lg backdrop-blur-sm">
              <span className="relative flex h-3 w-3">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
              </span>
              LIVE
            </div>
          </div>
        )}

        {/* Time Behind Live Badge */}
        {viewMode === "playback" && !isNearLive && timeBehindLive > 0 && (
          <div className="absolute top-3 right-3 z-10">
            <div className="flex items-center gap-2 bg-black/80 backdrop-blur-md text-white px-4 py-2 rounded-md text-sm font-medium shadow-lg border border-white/10">
              <ArrowPathIcon className="w-4 h-4 text-blue-400" />
              <span className="text-gray-300">
                -{formatTime(timeBehindLive)}
              </span>
            </div>
          </div>
        )}

        {/* Loading Overlay */}
        {(isLiveConnecting ||
          isHLSLoading ||
          (viewMode === "live" && isWaitingForData && !isLiveConnected)) && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/80 backdrop-blur-sm z-20">
            <div className="text-center text-white">
              <div className="relative w-16 h-16 mx-auto mb-4">
                <div className="absolute inset-0 border-4 border-gray-700 rounded-full"></div>
                <div className="absolute inset-0 border-4 border-t-blue-500 border-r-transparent border-b-transparent border-l-transparent rounded-full animate-spin"></div>
              </div>
              <p className="text-lg font-semibold mb-1">
                {viewMode === "live"
                  ? isWaitingForData
                    ? "Waiting for video data..."
                    : "Connecting to live stream..."
                  : "Loading playback..."}
              </p>
              {liveStatus && viewMode === "live" && (
                <p className="text-sm text-gray-400">{liveStatus}</p>
              )}
            </div>
          </div>
        )}

        {/* Error Overlay */}
        {liveError && hlsError && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/90 backdrop-blur-sm z-20">
            <div className="text-center text-white p-8 max-w-md">
              <div className="w-20 h-20 mx-auto mb-5 bg-red-500/20 rounded-full flex items-center justify-center border-2 border-red-500/30">
                <SignalIcon className="w-10 h-10 text-red-400" />
              </div>
              <p className="text-red-400 font-semibold text-xl mb-3">
                Connection Error
              </p>
              <p className="text-sm text-gray-300 leading-relaxed">
                {viewMode === "live" ? liveError : hlsError}
              </p>
              <Button
                onClick={() => window.location.reload()}
                className="mt-6 bg-red-600 hover:bg-red-700"
              >
                Retry Connection
              </Button>
            </div>
          </div>
        )}

        {/* No Recording Available */}
        {viewMode === "playback" && !roomId && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/90 backdrop-blur-sm z-20">
            <div className="text-center text-white p-8">
              <div className="w-20 h-20 mx-auto mb-5 bg-gray-700/30 rounded-full flex items-center justify-center border-2 border-gray-600/30">
                <SignalIcon className="w-10 h-10 text-gray-400" />
              </div>
              <p className="text-gray-300 text-lg font-medium mb-4">
                No recording available yet
              </p>
              <Button
                onClick={switchToLive}
                className="bg-red-600 hover:bg-red-700 shadow-lg"
              >
                <SignalIcon className="w-5 h-5 mr-2 animate-pulse" />
                Go to Live Stream
              </Button>
            </div>
          </div>
        )}

        {/* Bottom Controls Bar */}
        <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/90 via-black/60 to-transparent pt-20 pb-4 px-4 z-10">
          {/* Timeline Progress Bar (YouTube-style clickable) */}
          {hasRecording && (
            <div
              className="relative mb-4 group cursor-pointer"
              onClick={handleTimelineClick}
              onMouseMove={handleTimelineMouseMove}
              onMouseEnter={() => setIsHoveringTimeline(true)}
              onMouseLeave={() => setIsHoveringTimeline(false)}
            >
              {/* Hover Timestamp Tooltip */}
              {isHoveringTimeline && (
                <div
                  className="absolute bottom-full mb-2 transform -translate-x-1/2 pointer-events-none"
                  style={{ left: `${hoverPosition}%` }}
                >
                  <div className="bg-black/90 text-white text-xs font-medium px-2 py-1 rounded shadow-lg backdrop-blur-sm">
                    {formatTime(hoverTime)}
                  </div>
                  <div className="w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-black/90 mx-auto"></div>
                </div>
              )}

              {/* Timeline Track */}
              <div className="relative h-1 group-hover:h-1.5 transition-all bg-white/20 rounded-full overflow-hidden">
                {/* Buffered/Loaded Progress (lighter gray) */}
                <div
                  className="absolute top-0 left-0 h-full bg-white/30 transition-all"
                  style={{
                    width: `${
                      viewMode === "live"
                        ? 100
                        : (liveEdgeDuration / (duration || 1)) * 100
                    }%`,
                  }}
                />

                {/* Played Progress (red, YouTube-style) */}
                <div
                  className="absolute top-0 left-0 h-full bg-red-600 transition-all"
                  style={{
                    width: `${
                      viewMode === "live"
                        ? 100
                        : (currentTime / (duration || 1)) * 100
                    }%`,
                  }}
                />

                {/* Scrubber Handle (appears on hover) */}
                <div
                  className="absolute top-1/2 transform -translate-y-1/2 -translate-x-1/2 w-0 h-0 group-hover:w-3 group-hover:h-3 bg-red-600 rounded-full shadow-lg transition-all opacity-0 group-hover:opacity-100"
                  style={{
                    left: `${
                      viewMode === "live"
                        ? 100
                        : (currentTime / (duration || 1)) * 100
                    }%`,
                  }}
                />
              </div>
            </div>
          )}

          {/* Control Buttons Row */}
          <div className="flex items-center justify-between">
            {/* Left: Playback Controls */}
            <div className="flex items-center gap-1">
              {/* Play/Pause Button (prominent) */}
              <button
                onClick={handlePlayPause}
                className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors text-white"
                title={
                  viewMode === "live"
                    ? "Pause (switch to playback)"
                    : isPlaying
                    ? "Pause"
                    : "Play"
                }
              >
                {viewMode === "live" && isLiveConnected ? (
                  <PauseIcon className="w-6 h-6" />
                ) : isPlaying ? (
                  <PauseIcon className="w-6 h-6" />
                ) : (
                  <PlayIcon className="w-6 h-6" />
                )}
              </button>

              {/* Skip Backward */}
              {showAdvancedControls && viewMode === "playback" && (
                <button
                  onClick={handleSkipBackward}
                  className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors text-white"
                  title="Skip backward 10 seconds"
                >
                  <BackwardIcon className="w-5 h-5" />
                </button>
              )}

              {/* Skip Forward */}
              {showAdvancedControls && viewMode === "playback" && (
                <button
                  onClick={handleSkipForward}
                  className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors text-white"
                  title="Skip forward 10 seconds"
                >
                  <ForwardIcon className="w-5 h-5" />
                </button>
              )}

              {/* Current Time / Duration */}
              <div className="ml-2 text-white text-sm font-medium tabular-nums">
                {viewMode === "live" ? (
                  <span className="flex items-center gap-2">
                    <span className="text-gray-300">
                      {formatTime(liveEdgeDuration)}
                    </span>
                  </span>
                ) : (
                  <span className="text-gray-300">
                    {formatTime(currentTime)} / {formatTime(duration)}
                  </span>
                )}
              </div>
            </div>

            {/* Right: Mode Indicator & Go Live Button */}
            <div className="flex items-center gap-3">
              {/* Mode Badge */}
              {viewMode === "live" ? (
                <div className="flex items-center gap-2 bg-red-600/20 text-white px-3 py-1.5 rounded-full text-xs font-semibold backdrop-blur-sm border border-red-500/30">
                  <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse shadow-lg shadow-red-500/50" />
                  STREAMING
                </div>
              ) : (
                <div className="flex items-center gap-2 bg-blue-600/20 text-white px-3 py-1.5 rounded-full text-xs font-semibold backdrop-blur-sm border border-blue-500/30">
                  PLAYBACK
                </div>
              )}

              {/* Go Live Button (when in playback and behind) */}
              {viewMode === "playback" && !isNearLive && (
                <button
                  onClick={switchToLive}
                  className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-lg transition-all hover:scale-105"
                >
                  <SignalIcon className="w-4 h-4 animate-pulse" />
                  <span>GO LIVE</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Debug Info (if enabled) - cleaner design */}
      {debug && (
        <div className="mt-4 p-4 bg-gray-900 rounded-lg text-xs font-mono text-gray-300 space-y-1 border border-gray-700">
          <div className="grid grid-cols-2 gap-2">
            <div>
              Mode: <span className="text-blue-400">{viewMode}</span>
            </div>
            <div>
              Playing:{" "}
              <span className="text-green-400">{isPlaying ? "Yes" : "No"}</span>
            </div>
            <div>
              Current:{" "}
              <span className="text-yellow-400">{currentTime.toFixed(2)}s</span>
            </div>
            <div>
              Duration:{" "}
              <span className="text-yellow-400">{duration.toFixed(2)}s</span>
            </div>
            <div>
              Live Edge:{" "}
              <span className="text-red-400">
                {liveEdgeDuration.toFixed(2)}s
              </span>
            </div>
            <div>
              Behind:{" "}
              <span className="text-orange-400">
                {timeBehindLive.toFixed(2)}s
              </span>
            </div>
            <div>
              Live:{" "}
              <span className="text-green-400">
                {isLiveConnected ? "Yes" : "No"}
              </span>
            </div>
            <div>
              HLS:{" "}
              <span className="text-green-400">
                {isHLSReady ? "Yes" : "No"}
              </span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default HybridStreamPlayer;
