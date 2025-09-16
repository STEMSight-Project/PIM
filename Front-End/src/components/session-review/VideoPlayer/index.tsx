"use client";

import React, { useEffect, useRef, useState } from "react";

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
  const videoRef = useRef<HTMLVideoElement | null>(null);

  // store the actual src used by the <video> element (may be same as videoUrl or an object URL)
  const [internalSrc, setInternalSrc] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  // keep track of any created object URL so we can revoke it later
  const objectUrlRef = useRef<string | null>(null);

  // Keep a pending seek time if metadata hasn't loaded yet
  const pendingSeekRef = useRef<number | null>(null);

  // Resolve the incoming videoUrl to an actual usable src:
  // - If it's a full URL already (http(s)/blob/data) use it directly.
  // - Otherwise try to fetch it and create an object URL (useful when backend returns a path).
  useEffect(() => {
    let aborted = false;
    const controller = new AbortController();
    const signal = controller.signal;

    async function resolveSrc() {
      // cleanup previous object URL
      if (objectUrlRef.current) {
        URL.revokeObjectURL(objectUrlRef.current);
        objectUrlRef.current = null;
      }

      if (!videoUrl) {
        setInternalSrc(null);
        setLoading(false);
        return;
      }

      const lower = videoUrl.toLowerCase();
      if (lower.startsWith("http://") || lower.startsWith("https://") || lower.startsWith("blob:") || lower.startsWith("data:")) {
        setInternalSrc(videoUrl);
        setLoading(false);
        return;
      }

      // attempt to fetch (this may fail if CORS or auth is required)
      setLoading(true);
      try {
        const res = await fetch(videoUrl, { signal, cache: "no-cache", mode: "cors" });
        if (!res.ok) {
          console.warn("VideoPlayer: failed to fetch video at", videoUrl, "status:", res.status);
          setLoading(false);
          setInternalSrc(null);
          return;
        }
        const blob = await res.blob();
        if (aborted) {
          // if aborted after fetch completed, revoke and exit
          URL.revokeObjectURL(URL.createObjectURL(blob));
          return;
        }
        const objUrl = URL.createObjectURL(blob);
        objectUrlRef.current = objUrl;
        setInternalSrc(objUrl);
      } catch (err: any) {
        if (err.name === "AbortError") {
          // ignore
        } else {
          console.warn("VideoPlayer: error fetching video:", err);
        }
        setInternalSrc(null);
      } finally {
        if (!aborted) setLoading(false);
      }
    }

    resolveSrc();

    return () => {
      aborted = true;
      controller.abort();
      if (objectUrlRef.current) {
        URL.revokeObjectURL(objectUrlRef.current);
        objectUrlRef.current = null;
      }
    };
  }, [videoUrl]);

  // When internalSrc changes, force a reload of the <video> and clear pending seek
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;
    // force reload to pick up new src
    try {
      video.load();
    } catch (e) {
      // ignore
    }
    // clear any pending seek — we'll apply seeking via the timestamp effect below
    pendingSeekRef.current = null;
  }, [internalSrc]);

  // Seek to timestamp when updated — ensure metadata loaded first
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const attemptSeek = (target: number) => {
      try {
        // clamp target within duration if available
        if (!isNaN(video.duration) && isFinite(video.duration)) {
          const clamped = Math.min(target, Math.max(0, video.duration));
          video.currentTime = clamped;
        } else {
          video.currentTime = Math.max(0, target);
        }
      } catch (err) {
        console.warn("VideoPlayer: seek failed, will retry on loadedmetadata", err);
        pendingSeekRef.current = target;
      }
    };

    // If metadata is already available, seek immediately
    if (video.readyState >= 1) {
      attemptSeek(currentTimestamp);
    } else {
      // wait for loadedmetadata
      const onLoaded = () => {
        if (pendingSeekRef.current != null) {
          attemptSeek(pendingSeekRef.current);
          pendingSeekRef.current = null;
        } else {
          attemptSeek(currentTimestamp);
        }
        video.removeEventListener("loadedmetadata", onLoaded);
      };
      video.addEventListener("loadedmetadata", onLoaded);
      // also keep pending target in case loadedmetadata fires before the handler attaches
      pendingSeekRef.current = currentTimestamp;

      // cleanup
      return () => {
        video.removeEventListener("loadedmetadata", onLoaded);
      };
    }
  }, [currentTimestamp, internalSrc]);

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
      {loading ? (
        <p className="text-gray-500 text-sm">Loading video...</p>
      ) : internalSrc ? (
        <video
          // ensure the video reloads when internalSrc changes
          key={internalSrc}
          ref={videoRef}
          src={internalSrc}
          controls
          crossOrigin="anonymous"
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
