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
  });

  // ============================================================================
  // HOOKS - HLS SEGMENT EVENTS (Real-time segment updates)
  // ============================================================================

  const {
    isConnected: segmentEventsConnected,
    error: segmentEventsError,
    lastSegment,
    segmentCount,
    status: segmentStatus,
  } = useHLSSegmentEvents({
    roomId: viewMode === "playback" ? roomId : null, // Only connect in playback mode
    hls,
    autoReload: true, // Automatically reload HLS when new segments arrive
    debug,
    onSegmentAdded: (event) => {
      if (debug) {
        console.log(
          `[HybridPlayer] New segment added: ${event.segment_name} (${event.file_size} bytes)`
        );
      }
      // Update live edge duration when new segment arrives
      if (hlsVideoRef.current) {
        const newDuration = hlsVideoRef.current.duration || 0;
        setLiveEdgeDuration(newDuration);
      }
    },
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

    // Handler for duration change (when new segments are added)
    const handleDurationChange = () => {
      const newDuration = video.duration || 0;
      if (newDuration !== duration) {
        setDuration(newDuration);
        if (debug) {
          console.log(
            `[HybridPlayer] Video duration updated: ${newDuration.toFixed(2)}s`
          );
        }
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

  // ============================================================================
  // EFFECTS - POLL DVR INFO (Update live edge during playback)
  // ============================================================================

  useEffect(() => {
    if (!roomId || viewMode !== "playback") return;

    const updateLiveEdge = async () => {
      try {
        // Use correct backend API endpoint: /videos/hls/{room_id}/status
        const response = await fetch(
          `${
            process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000"
          }/videos/hls/${roomId}/status`
        );

        if (!response.ok) {
          console.warn(
            `[HybridPlayer] Recording status fetch failed: ${response.status}`
          );
          return;
        }

        const data = await response.json();

        // Backend returns status directly (not wrapped in {data: ...})
        if (data) {
          // For active recordings, use duration
          if (data.is_active && data.duration) {
            const newDuration = data.duration || 0;
            setLiveEdgeDuration(newDuration);

            if (debug) {
              console.log(
                `[HybridPlayer] Live edge: ${newDuration}s, Current: ${currentTime}s, Status: ${data.status}`
              );
            }
          }
          // For completed recordings, use segment count * segment duration estimate
          else if (!data.is_active && data.segment_count) {
            // Estimate duration (assuming 30-second segments)
            const estimatedDuration = data.segment_count * 30;
            setLiveEdgeDuration(estimatedDuration);

            if (debug) {
              console.log(
                `[HybridPlayer] Completed recording: ${data.segment_count} segments, ~${estimatedDuration}s`
              );
            }
          }
        }
      } catch (error) {
        console.error(
          "[HybridPlayer] Failed to fetch recording status:",
          error
        );
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
    setIsPlaying(true); // Mark as playing when switching to playback

    // Stop live stream
    if (isLiveConnected) {
      stopStreaming();
    }

    // Start playing HLS after mode switch
    setTimeout(() => {
      if (hlsVideoRef.current && hlsVideoRef.current.paused) {
        playHLS().catch((err) => {
          console.warn(
            "[HybridPlayer] Failed to auto-play after mode switch:",
            err
          );
        });
      }
    }, 100);
  }, [isLiveConnected, stopStreaming, hlsVideoRef, playHLS, debug]);

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
        // Need to wait for mode switch, then seek
        setTimeout(() => {
          seekHLS(time);
        }, 100);
      } else {
        // Already in playback mode, just seek
        seekHLS(time);
      }
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
  // TIMELINE INTERACTION STATE
  // ============================================================================

  const [isHoveringTimeline, setIsHoveringTimeline] = useState(false);
  const [hoverTime, setHoverTime] = useState(0);
  const [hoverPosition, setHoverPosition] = useState(0);

  // ============================================================================
  // TIMELINE CLICK HANDLER (YouTube-style)
  // ============================================================================

  const handleTimelineClick = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      const rect = e.currentTarget.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const percentage = x / rect.width;
      const targetDuration = viewMode === "live" ? liveEdgeDuration : duration;
      const newTime = Math.max(
        0,
        Math.min(targetDuration, percentage * targetDuration)
      );

      if (debug) {
        console.log(
          `[HybridPlayer] Timeline clicked at ${percentage.toFixed(
            2
          )}% → ${newTime.toFixed(2)}s`
        );
      }

      // If in live mode, switch to playback first
      if (viewMode === "live") {
        if (!hasRecording) {
          alert("Recording not available yet. Please wait a few seconds.");
          return;
        }
        switchToPlayback();
        // Wait for mode switch, then seek and play
        setTimeout(() => {
          seekHLS(newTime);
          setIsPlaying(true);
        }, 150);
      } else {
        // Already in playback mode, seek and ensure playing
        seekHLS(newTime);
        setIsPlaying(true);

        // Make sure video starts playing
        if (hlsVideoRef.current && hlsVideoRef.current.paused) {
          playHLS().catch((err) => {
            console.warn(
              "[HybridPlayer] Failed to play after timeline click:",
              err
            );
          });
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
      debug,
    ]
  );

  const handleTimelineMouseMove = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      const rect = e.currentTarget.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const percentage = Math.max(0, Math.min(1, x / rect.width));
      const targetDuration = viewMode === "live" ? liveEdgeDuration : duration;
      const time = percentage * targetDuration;

      setHoverPosition(percentage * 100);
      setHoverTime(time);
    },
    [viewMode, liveEdgeDuration, duration]
  );

  // ============================================================================
  // RENDER
  // ============================================================================

  return (
    <div className={cn("hybrid-stream-player relative", className)}>
      {/* ====================================================================
          VIDEO CONTAINER (YouTube-style with rounded corners)
          ==================================================================== */}
      <div className="relative bg-black rounded-xl overflow-hidden shadow-2xl">
        {/* Live Video Element (WebRTC) */}
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

        {/* HLS Video Element (Playback) */}
        <video
          ref={hlsVideoRef}
          className={cn(
            "w-full h-full object-contain aspect-video",
            viewMode !== "playback" && "hidden"
          )}
          playsInline
          muted={false}
        />

        {/* ==================================================================
            OVERLAYS - Modern YouTube-style badges
            ================================================================== */}

        {/* LIVE Badge (top-right, vibrant design) */}
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

        {/* Time Behind Live Badge (top-right, sleek design) */}
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

        {/* Loading Overlay (modern spinner) */}
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

        {/* Error Overlay (refined design) */}
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

        {/* ==================================================================
            BOTTOM CONTROLS BAR (YouTube-style integrated controls)
            ================================================================== */}
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
