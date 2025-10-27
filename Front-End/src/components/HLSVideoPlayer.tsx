/**
 * HLSVideoPlayer Component
 *
 * Simple, lightweight HLS video player component.
 * Use this for basic playback needs without extra UI.
 */

"use client";

import { useHLS } from "@/hooks/useHLS";
import { cn } from "@/utils/cn";

export interface HLSVideoPlayerProps {
  /** Session ID for the recording */
  sessionId: string | null;

  /** Auto-play when ready */
  autoPlay?: boolean;

  /** Show native video controls */
  controls?: boolean;

  /** Enable low latency mode */
  lowLatencyMode?: boolean;

  /** Custom CSS classes */
  className?: string;

  /** Video aspect ratio class (default: aspect-video) */
  aspectRatio?: string;

  /** Callback when ready */
  onReady?: () => void;

  /** Callback on error */
  onError?: (error: string) => void;
}

/**
 * Simple HLS video player with minimal UI
 */
export function HLSVideoPlayer({
  sessionId,
  autoPlay = false,
  controls = true,
  lowLatencyMode = false,
  className,
  aspectRatio = "aspect-video",
  onReady,
  onError,
}: HLSVideoPlayerProps) {
  const { videoRef, isLoading, error } = useHLS({
    sessionId,
    autoPlay,
    lowLatencyMode,
  });

  // Trigger callbacks
  if (error && onError) onError(error);
  if (!isLoading && !error && onReady) onReady();

  return (
    <div className={cn("relative", className)}>
      <video
        ref={videoRef}
        className={cn("w-full bg-black rounded-lg", aspectRatio)}
        controls={controls}
        playsInline
      />

      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 rounded-lg">
          <div className="text-white text-sm">Loading...</div>
        </div>
      )}

      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 rounded-lg">
          <div className="text-red-400 text-sm text-center px-4">{error}</div>
        </div>
      )}
    </div>
  );
}

export default HLSVideoPlayer;
