"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Card, CardContent, CardHeader } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { SkeletonOverlay } from "@/components/SkeletonOverlay";
import TimelineSyncedDetectionPanel from "@/components/TimelineSyncedDetectionPanel";
import { useRecordings, useMovementDetections } from "@/hooks";
import {
  formatDate,
  formatDuration,
  formatFileSize,
  formatTime,
} from "@/lib/utils";
import type { RecordingResponse } from "@/services/videoService";
import type { MovementDetection } from "@/types/movementDetection";
import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { movementDetectionService } from "@/services/movementDetectionService";
import { cn } from "@/utils/cn";
import type { TimelineDetection } from "@/components/TimelineSyncedDetectionPanel";

interface PoseLandmark {
  x: number;
  y: number;
  z: number;
  visibility?: number;
}

interface DetectionProbabilities {
  pose_landmarks?: PoseLandmark[];
  all_probabilities?: Record<string, number>;
}

interface PredictionSummary {
  predicted_class: string;
  confidence: number;
  top3: Array<{ class: string; confidence: number }>;
}

export default function SessionDetailPage() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;

  const { recordings, isLoading, error, fetchRecordingsBySession, clearError } =
    useRecordings();

  const [selectedRecording, setSelectedRecording] =
    useState<RecordingResponse | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  // Detection state
  const [totalSessionDetections, setTotalSessionDetections] = useState(0);
  // Polling state: when a recording has no detections we keep retrying for a while
  const [isPollingDetections, setIsPollingDetections] = useState(false);
  const [timelineDetections, setTimelineDetections] = useState<MovementDetection[]>([]);

  // Playback state for skeleton overlay and predictions
  const [currentTime, setCurrentTime] = useState(0);
  const [playbackLandmarks, setPlaybackLandmarks] = useState<PoseLandmark[] | null>(null);
  const [playbackPrediction, setPlaybackPrediction] = useState<PredictionSummary | null>(null);

  const handleTimelineDetections = useCallback(
    (detections: TimelineDetection[]) => {
      const converted: MovementDetection[] = detections.map((detection) => ({
        id: detection.id,
        timestamp: detection.timestamp,
        name: detection.name as MovementDetection["name"],
        confidence: detection.confidence,
        validation_status: detection.validation_status,
        room_id: detection.room_id || "",
        recording_id: detection.recording_id,
        created_at: detection.created_at,
        updated_at: detection.updated_at,
        detection_data: detection.detection_data
          ? (detection.detection_data as Record<string, unknown>)
          : null,
      }));
      setTimelineDetections(converted);
    },
    []
  );

  // Initialize movement detections hook BEFORE using recordingDetections
  const {
    detections: recordingDetections,
    isLoading: detectionsLoading,
    fetchDetectionsByRecording,
  } = useMovementDetections({
    enableRealtime: false, // No realtime for playback
  });

  const normalizedDetections = useMemo(() => {
    if (!selectedRecording || recordingDetections.length === 0) {
      return [] as MovementDetection[];
    }

    const parseTimestamp = (value?: string | null): number | null => {
      if (!value) return null;
      const parsed = new Date(value);
      const ms = parsed.getTime();
      return Number.isNaN(ms) ? null : ms;
    };

    const filtered = recordingDetections.filter((detection) => {
      if (!selectedRecording.session_id || !detection.session_id) {
        return true;
      }
      return detection.session_id === selectedRecording.session_id;
    });

    if (filtered.length === 0) {
      return [] as MovementDetection[];
    }

    const baselineSource =
      selectedRecording.session_start || selectedRecording.created_at;
    let baselineMs = parseTimestamp(baselineSource);

    const detectionsWithAbsolute = filtered.map((detection) => {
      const absoluteMs =
        parseTimestamp(detection.created_at) ||
        parseTimestamp(detection.frame_timestamp);

      const fallbackSeconds =
        typeof detection.timestamp === "number" &&
        Number.isFinite(detection.timestamp)
          ? detection.timestamp
          : null;

      return { detection, absoluteMs, fallbackSeconds };
    });

    const absoluteCandidates = detectionsWithAbsolute
      .map(({ absoluteMs }) => absoluteMs)
      .filter((value): value is number => typeof value === "number");

    if (baselineMs === null && absoluteCandidates.length > 0) {
      baselineMs = Math.min(...absoluteCandidates);
    }

    // If there is a large gap (e.g., timezone mismatch) prefer earliest detection
    if (
      baselineMs !== null &&
      absoluteCandidates.length > 0 &&
      baselineMs - Math.min(...absoluteCandidates) > 2 * 60 * 60 * 1000
    ) {
      baselineMs = Math.min(...absoluteCandidates);
    }

    return detectionsWithAbsolute
      .map(({ detection, absoluteMs, fallbackSeconds }) => {
        let relativeSeconds: number;
        if (baselineMs !== null && absoluteMs !== null) {
          relativeSeconds = (absoluteMs - baselineMs) / 1000;
        } else if (fallbackSeconds !== null) {
          relativeSeconds = fallbackSeconds;
        } else {
          relativeSeconds = 0;
        }

        const normalized = Math.max(0, relativeSeconds);
        return {
          ...detection,
          timestamp: normalized,
        };
      })
      .sort((a, b) => a.timestamp - b.timestamp);
  }, [selectedRecording, recordingDetections]);

  const parseDetectionData = (
    data: MovementDetection["detection_data"]
  ): DetectionProbabilities | null => {
    if (!data || typeof data !== "object") {
      return null;
    }
    return data as DetectionProbabilities;
  };

  // Handler to seek video to specific timestamp
  const handleSeekToTime = (timestamp: number) => {
    if (videoRef.current) {
      videoRef.current.currentTime = timestamp;
      // Optionally play the video after seeking
      videoRef.current.play().catch((err) => {
        console.log("Autoplay prevented:", err);
      });
    }
  };

  // Sync landmarks and predictions with current playback time
  useEffect(() => {
    if (normalizedDetections.length === 0) return;

    // Find detections within 2 seconds of current time
    const timeWindow = 2;
    const relevant = normalizedDetections.filter(
      (d) => Math.abs(d.timestamp - currentTime) < timeWindow
    );

    if (relevant.length > 0) {
      // Use the closest detection
      const closest = relevant.reduce((prev, curr) =>
        Math.abs(curr.timestamp - currentTime) < Math.abs(prev.timestamp - currentTime)
          ? curr
          : prev
      );

      const detectionData = parseDetectionData(closest.detection_data);
      const landmarks = detectionData?.pose_landmarks || null;
      setPlaybackLandmarks(landmarks);
      
      // Set prediction if available
      if (detectionData?.all_probabilities) {
        const top3 = Object.entries(detectionData.all_probabilities)
          .map(([cls, conf]) => ({ class: cls, confidence: Number(conf) }))
          .sort((a, b) => b.confidence - a.confidence)
          .slice(0, 3);

        setPlaybackPrediction({
          predicted_class: closest.name,
          confidence: closest.confidence,
          top3,
        });
      } else {
        setPlaybackPrediction({
          predicted_class: closest.name,
          confidence: closest.confidence,
          top3: [],
        });
      }
    } else {
      // Clear when no detections nearby
      setPlaybackLandmarks(null);
      setPlaybackPrediction(null);
    }
  }, [currentTime, normalizedDetections]);

  useEffect(() => {
    if (sessionId) {
      fetchRecordingsBySession(sessionId);
    }
  }, [sessionId, fetchRecordingsBySession]);

  // Filter recordings to only show those with videos available
  const recordingsWithVideos = recordings.filter(rec => rec.public_video_url);
  const recordingsWithoutVideos = recordings.filter(rec => !rec.public_video_url);

  useEffect(() => {
    // Auto-select first recording WITH video when data loads
    if (recordingsWithVideos.length > 0 && !selectedRecording) {
      setSelectedRecording(recordingsWithVideos[0]);
    }
  }, [recordings, selectedRecording, recordingsWithVideos]);

  // Fetch detections for all recordings when recordings load
  useEffect(() => {
    const fetchAllDetections = async () => {
      if (recordings.length === 0) return;

      let totalCount = 0;

      for (const recording of recordings) {
        try {
          const resp = await movementDetectionService.getDetectionsByRecording(
            recording.id
          );
          if (resp && resp.data) {
            totalCount += resp.data.length;
          }
        } catch (err) {
          console.error(
            `Failed to fetch detections for recording ${recording.id}:`,
            err
          );
        }
      }

      setTotalSessionDetections(totalCount);
    };

    fetchAllDetections();
  }, [recordings]);

  // Fetch detections for selected recording
  useEffect(() => {
    if (selectedRecording) {
      console.log("🔍 Fetching detections for recording:", selectedRecording.id);
      fetchDetectionsByRecording(selectedRecording.id);
      setTimelineDetections([]); // reset fallback when switching recordings
    }
  }, [selectedRecording, fetchDetectionsByRecording]);

  useEffect(() => {
    if (normalizedDetections.length > 0 && timelineDetections.length > 0) {
      setTimelineDetections([]);
    }
  }, [normalizedDetections.length, timelineDetections.length]);

  // Debug log when recordingDetections changes
  useEffect(() => {
    console.log("📊 Recording detections updated:", {
      count: normalizedDetections.length,
      detections: normalizedDetections.slice(0, 3).map((d) => {
        const data = parseDetectionData(d.detection_data);
        return {
          id: d.id,
          timestamp: d.timestamp,
          hasLandmarks: !!data?.pose_landmarks,
          landmarkCount: data?.pose_landmarks?.length || 0,
        };
      }),
    });
  }, [normalizedDetections]);

  // no direct mutation of hook state; timestamps normalized via useMemo

  // Update current time from video element
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const handleTimeUpdate = () => {
      setCurrentTime(video.currentTime);
    };

    video.addEventListener('timeupdate', handleTimeUpdate);
    return () => video.removeEventListener('timeupdate', handleTimeUpdate);
  }, [selectedRecording]);

  // If there are no detections for the selected recording, keep polling for a short time
  useEffect(() => {
    const POLLING_INTERVAL = 5000; // ms
    const MAX_POLLING_ATTEMPTS = 12; // ~1 minute
    let cancelled = false;

    const isUsingDevMock =
      process.env.NODE_ENV === "development" && normalizedDetections.length === 0;

    // If we're showing dev mock data, don't start polling for real detections
    if (isUsingDevMock) {
      setIsPollingDetections(false);
      return;
    }

    const startPolling = async (attempt = 0) => {
      if (cancelled) return;
      if (!selectedRecording) return;
      // If detections have appeared, stop polling
      if (normalizedDetections.length > 0) {
        setIsPollingDetections(false);
        return;
      }
      // If already loading from the hook, wait for that to finish before calling
      if (detectionsLoading) {
        // schedule next check
        setTimeout(() => startPolling(attempt), POLLING_INTERVAL);
        return;
      }
      if (attempt >= MAX_POLLING_ATTEMPTS) {
        setIsPollingDetections(false);
        return;
      }

      setIsPollingDetections(true);

      try {
        await fetchDetectionsByRecording(selectedRecording.id);
      } catch (err) {
        console.error("Polling detections failed:", err);
      }

      // schedule next poll
      setTimeout(() => startPolling(attempt + 1), POLLING_INTERVAL);
    };

    // Only start polling when a recording is selected and there are no detections
    if (selectedRecording && normalizedDetections.length === 0) {
      startPolling(0);
    }

    return () => {
      cancelled = true;
      setIsPollingDetections(false);
    };
  }, [selectedRecording, normalizedDetections.length, detectionsLoading, fetchDetectionsByRecording]);

  const handleRecordingSelect = (recording: RecordingResponse) => {
    setSelectedRecording(recording);
    // Scroll video player into view on mobile
    if (videoRef.current) {
      videoRef.current.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const handleBackToSessions = () => {
    router.push("/video-playback");
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-20">
          <Loading size="lg" text="Loading session recordings..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <div className="px-4">
          <Card className="max-w-md mx-auto">
            <CardContent className="pt-6">
              <div className="text-center">
                <div className="w-16 h-16 mx-auto mb-4 bg-red-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-8 h-8 text-red-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z"
                    />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  Error Loading Recordings
                </h3>
                <p className="text-gray-600 mb-4">{error}</p>
                <div className="flex gap-3 justify-center">
                  <button
                    onClick={handleBackToSessions}
                    className="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
                  >
                    Back to Sessions
                  </button>
                  <button
                    onClick={() => {
                      clearError();
                      fetchRecordingsBySession(sessionId);
                    }}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Try Again
                  </button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  if (recordings.length === 0) {
    return (
      <DashboardLayout>
        <div className="px-4 py-8">
          <Card className="max-w-2xl mx-auto">
            <CardContent className="pt-6">
              <div className="text-center py-12">
                <div className="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-10 h-10 text-gray-400"
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
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  No Recordings Yet
                </h3>
                <p className="text-gray-600 mb-6">
                  This session doesn't have any recordings. Start the camera broadcaster to create recordings.
                </p>
                <button
                  onClick={handleBackToSessions}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Back to Sessions
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  // If all recordings are pending (no videos available yet)
  if (recordingsWithVideos.length === 0 && recordingsWithoutVideos.length > 0) {
    return (
      <DashboardLayout>
        <div className="px-4 py-8">
          <Card className="max-w-2xl mx-auto">
            <CardContent className="pt-6">
              <div className="text-center py-12">
                <div className="w-20 h-20 mx-auto mb-4 bg-yellow-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-10 h-10 text-yellow-600 animate-pulse"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  Videos Being Processed
                </h3>
                <p className="text-gray-600 mb-2">
                  {recordingsWithoutVideos.length} {recordingsWithoutVideos.length === 1 ? "recording is" : "recordings are"} waiting for video upload.
                </p>
                <p className="text-sm text-gray-500 mb-6">
                  Video files are being uploaded to storage. This usually completes within a few minutes after the camera session ends.
                </p>
                <div className="flex gap-3 justify-center">
                  <button
                    onClick={handleBackToSessions}
                    className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
                  >
                    Back to Sessions
                  </button>
                  <button
                    onClick={() => fetchRecordingsBySession(sessionId)}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Refresh
                  </button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  const sessionInfo = recordings[0];
  const totalDuration = recordings.reduce(
    (sum, rec) => sum + (rec.duration || 0),
    0
  );

  const detectionsToDisplay =
    normalizedDetections.length > 0 ? normalizedDetections : timelineDetections;
  const showingTimelineFallback =
    normalizedDetections.length === 0 && timelineDetections.length > 0;
  const detectionsNearCurrent = detectionsToDisplay.filter(
    (detection) => Math.abs(detection.timestamp - currentTime) < 2
  );
  const displayedSessionDetections = (() => {
    if (totalSessionDetections > 0) {
      return totalSessionDetections;
    }
    if (normalizedDetections.length > 0) {
      return normalizedDetections.length;
    }
    return timelineDetections.length;
  })();
  const detectionHeaderMessage = (() => {
    if (!selectedRecording) {
      return "Select a recording to review detections.";
    }
    if (detectionsLoading) {
      return "Loading detections...";
    }
    if (showingTimelineFallback) {
      return "Showing AI timeline detections while movement service catches up.";
    }
    if (normalizedDetections.length > 0) {
      return "Showing detections stored with this recording.";
    }
    if (timelineDetections.length > 0) {
      return "Timeline detections ready for playback review.";
    }
    if (isPollingDetections) {
      return "Waiting for detections to sync from the ambulance.";
    }
    return "No detections captured yet for this recording.";
  })();
  return (
    <DashboardLayout>
      <div className="px-4 py-8">
        <div className="max-w-7xl mx-auto">
          {/* Back Button */}
          <button
            onClick={handleBackToSessions}
            className="mb-6 flex items-center text-gray-600 hover:text-gray-900 transition-colors"
          >
            <svg
              className="w-5 h-5 mr-2"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Sessions
          </button>

          {/* Session Header */}
          <div className="mb-8">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                  {sessionInfo.session_name || "Session Recordings"}
                </h1>
                <p className="text-gray-600">
                  Ambulance {sessionInfo.ambulance_number}
                </p>
              </div>
              <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                <svg
                  className="w-4 h-4 mr-1"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clipRule="evenodd"
                  />
                </svg>
                Archived
              </span>
            </div>

            {/* Session Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-blue-600 mr-3"
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
                <div>
                  <p className="text-sm text-gray-600">Available Recordings</p>
                  <p className="text-xl font-bold text-gray-900">
                    {recordingsWithVideos.length}
                    {recordingsWithoutVideos.length > 0 && (
                      <span className="text-sm text-yellow-600 font-normal ml-1">
                        (+{recordingsWithoutVideos.length} pending)
                      </span>
                    )}
                  </p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-purple-600 mr-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                <div>
                  <p className="text-sm text-gray-600">Total Duration</p>
                  <p className="text-xl font-bold text-gray-900">
                    {formatDuration(totalDuration)}
                  </p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-green-600 mr-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
                <div>
                  <p className="text-sm text-gray-600">Recorded On</p>
                  <p className="text-xl font-bold text-gray-900">
                    {formatDate(sessionInfo.created_at)
                      .split(" ")
                      .slice(0, 3)
                      .join(" ")}
                  </p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-orange-600 mr-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                  />
                </svg>
                <div>
                  <p className="text-sm text-gray-600">Total Detections</p>
                  <p className="text-xl font-bold text-gray-900">
                    {displayedSessionDetections}
                  </p>
                  {totalSessionDetections === 0 && displayedSessionDetections > 0 && (
                    <p className="text-xs text-purple-600 mt-1">
                      Showing available timeline data
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Video Player - Takes 2/3 width on large screens */}
            <div className="lg:col-span-2">
              <Card>
                <CardHeader>
                  <h2 className="text-xl font-semibold text-gray-900">
                    {selectedRecording
                      ? `Recording ${recordings.indexOf(selectedRecording) + 1}`
                      : "Select a Recording"}
                  </h2>
                  {selectedRecording && (
                    <p className="text-sm text-gray-600">
                      {formatDate(selectedRecording.created_at)}
                    </p>
                  )}
                </CardHeader>
                <CardContent>
                  {!selectedRecording ? (
                    <div className="flex items-center justify-center h-64 bg-gray-50 rounded-lg">
                      <p className="text-gray-500">Select a recording to view</p>
                    </div>
                  ) : selectedRecording.public_video_url ? (
                    <div className="space-y-4">
                      {/* Video Player with Skeleton Overlay */}
                      <div className="relative">
                        <video
                          ref={videoRef}
                          key={selectedRecording.id}
                          controls
                          className="w-full rounded-lg bg-black"
                          src={selectedRecording.public_video_url}
                        >
                          Your browser does not support the video tag.
                        </video>
                        
                        {/* Skeleton Overlay */}
                        <SkeletonOverlay
                          videoRef={videoRef}
                          landmarks={playbackLandmarks}
                          enabled={!!(playbackLandmarks && playbackLandmarks.length > 0)}
                        />
                        
                        {/* Prediction Badge */}
                        {playbackPrediction && (
                          <div className="absolute top-3 left-3 z-10">
                            <div className={cn(
                              "px-4 py-3 rounded-lg shadow-xl backdrop-blur-md border-2 transition-all",
                              playbackPrediction.confidence >= 0.7
                                ? "bg-emerald-600/90 border-emerald-400/50"
                                : playbackPrediction.confidence >= 0.5
                                ? "bg-amber-600/90 border-amber-400/50"
                                : "bg-red-600/90 border-red-400/50"
                            )}>
                              <div className="text-white">
                                <p className="text-xs font-semibold uppercase tracking-wider opacity-75 mb-1">
                                  Movement Detected (Playback)
                                </p>
                                <p className="text-lg font-bold leading-tight">
                                  {playbackPrediction.predicted_class}
                                </p>
                                <p className="text-sm mt-1 font-medium opacity-90">
                                  {(playbackPrediction.confidence * 100).toFixed(1)}% confidence
                                </p>
                                {playbackPrediction.top3 && playbackPrediction.top3.length > 1 && (
                                  <div className="mt-2 pt-2 border-t border-white/20">
                                    <p className="text-xs opacity-75 mb-1">Top predictions:</p>
                                    {playbackPrediction.top3.slice(0, 3).map((item, idx) => (
                                      <p key={idx} className="text-xs opacity-90">
                                        {idx + 1}. {item.class} ({(item.confidence * 100).toFixed(1)}%)
                                      </p>
                                    ))}
                                  </div>
                                )}
                              </div>
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Timeline-synced detections */}
                      {selectedRecording && (
                        <TimelineSyncedDetectionPanel
                          recordingId={selectedRecording.id}
                          currentTimestamp={currentTime}
                          onLandmarksChange={setPlaybackLandmarks}
                          onPredictionChange={setPlaybackPrediction}
                          onSeekToTime={handleSeekToTime}
                          onDetectionsReady={handleTimelineDetections}
                          showPanel={false}
                        />
                      )}

                      {/* Recording Info */}
                      <div className="grid grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm text-gray-600">Duration</p>
                          <p className="text-lg font-semibold text-gray-900">
                            {formatDuration(selectedRecording.duration)}
                          </p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">File Size</p>
                          <p className="text-lg font-semibold text-gray-900">
                            {formatFileSize(selectedRecording.file_size)}
                          </p>
                        </div>
                        {selectedRecording.session_start && (
                          <div>
                            <p className="text-sm text-gray-600">Started</p>
                            <p className="text-lg font-semibold text-gray-900">
                              {formatTime(selectedRecording.session_start)}
                            </p>
                          </div>
                        )}
                        {selectedRecording.session_end && (
                          <div>
                            <p className="text-sm text-gray-600">Ended</p>
                            <p className="text-lg font-semibold text-gray-900">
                              {formatTime(selectedRecording.session_end)}
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center justify-center h-64 bg-gray-50 rounded-lg space-y-3 px-4">
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                      <p className="text-gray-700 font-medium text-lg">Video Not Yet Available</p>
                      <p className="text-sm text-gray-500 text-center max-w-md">
                        This recording exists but the video file hasn't been uploaded yet.<br />
                        The camera may have disconnected before the upload completed.
                      </p>
                      <p className="text-xs text-gray-400 mt-2 font-mono">
                        Recording ID: {selectedRecording.id}
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Recording List and Detections - Takes 1/3 width on large screens */}
            <div className="lg:col-span-1 space-y-6">
              {/* Detections Card */}
              <Card>
                <CardHeader>
                  <h2 className="text-xl font-semibold text-gray-900">
                    Movement Detections
                  </h2>
                  <p className="text-sm text-gray-600">{detectionHeaderMessage}</p>
                </CardHeader>
                <CardContent>
                  {!detectionsLoading && detectionsNearCurrent.length > 0 && (
                    <div className="mb-3 p-2 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-700">
                      🎯 {detectionsNearCurrent.length === 1 ? "Detection" : "Detections"} near current playback position
                    </div>
                  )}
                  {detectionsLoading && normalizedDetections.length > 0 ? (
                    <div className="flex items-center justify-center py-8">
                      <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                      <span className="ml-2 text-sm text-gray-600">Loading detections...</span>
                    </div>
                  ) : detectionsToDisplay.length > 0 ? (
                    <div className="space-y-3 max-h-[400px] overflow-y-auto">
                      {showingTimelineFallback && (
                        <div className="px-3 py-2 text-xs text-purple-700 bg-purple-50 border border-purple-200 rounded flex items-center gap-2">
                          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20 10 10 0 000-20z"
                            />
                          </svg>
                          Showing AI timeline detections while movement service catches up.
                        </div>
                      )}
                      {detectionsToDisplay.map((detection) => {
                        // Check if detection is near current playback time (within 2 seconds)
                        const isActive = Math.abs(detection.timestamp - currentTime) < 2;
                        const detectionData = parseDetectionData(detection.detection_data);
                        const hasLandmarks = detectionData?.pose_landmarks;
                        
                        return (
                          <div
                            key={detection.id}
                            onClick={() => handleSeekToTime(detection.timestamp)}
                            className={`p-3 rounded-lg border-2 transition-all cursor-pointer hover:shadow-md hover:scale-[1.02] ${
                              isActive ? 'bg-blue-50 border-blue-400 ring-2 ring-blue-200' : 'bg-gray-50 border-gray-200'
                            }`}
                            title="Click to jump to this detection"
                          >
                            <div className="flex items-center justify-between mb-2">
                              <div className="flex items-center gap-2">
                                {isActive && (
                                  <span className="flex h-2 w-2">
                                    <span className="animate-ping absolute h-2 w-2 rounded-full bg-blue-400 opacity-75"></span>
                                    <span className="relative rounded-full h-2 w-2 bg-blue-500"></span>
                                  </span>
                                )}
                                <span className="text-sm font-medium text-gray-900 capitalize">
                                  {detection.name.replace("_", " ")}
                                </span>
                              </div>
                              <span className={`px-2 py-1 rounded text-xs font-medium ${
                                detection.validation_status === "confirmed"
                                  ? "bg-green-100 text-green-800"
                                  : detection.validation_status === "rejected"
                                  ? "bg-red-100 text-red-800"
                                  : "bg-yellow-100 text-yellow-800"
                              }`}>
                                {detection.validation_status}
                              </span>
                            </div>
                            <div className="flex items-center justify-between text-xs text-gray-600">
                              <span>Confidence: {(detection.confidence * 100).toFixed(1)}%</span>
                              <span className="font-mono">{detection.timestamp.toFixed(1)}s</span>
                            </div>
                            {hasLandmarks && (
                              <div className="mt-2 text-xs text-blue-600 flex items-center gap-1">
                                <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                                Skeleton data available
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  ) : isPollingDetections ? (
                    <div className="flex items-center justify-center py-8">
                      <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                      <span className="ml-2 text-sm text-gray-600">Searching for detections...</span>
                    </div>
                  ) : (
                    <div className="text-center py-8">
                      <svg
                        className="w-8 h-8 mx-auto mb-2 text-gray-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                        />
                      </svg>
                      <p className="text-sm text-gray-500">
                        {selectedRecording
                          ? "No detections found for this recording"
                          : "Select a recording to view detections"}
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Recordings Card */}
              <Card>
                <CardHeader>
                  <h2 className="text-xl font-semibold text-gray-900">
                    Available Recordings
                  </h2>
                  <p className="text-sm text-gray-600">
                    {recordingsWithVideos.length}{" "}
                    {recordingsWithVideos.length === 1 ? "recording" : "recordings"} with video
                    {recordingsWithoutVideos.length > 0 && (
                      <span className="text-yellow-600">
                        {" "}• {recordingsWithoutVideos.length} pending
                      </span>
                    )}
                  </p>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3 max-h-[400px] overflow-y-auto">
                    {/* Recordings with videos */}
                    {recordingsWithVideos.map((recording, index) => (
                      <button
                        key={recording.id}
                        onClick={() => handleRecordingSelect(recording)}
                        className={`w-full text-left p-4 rounded-lg border-2 transition-all ${
                          selectedRecording?.id === recording.id
                            ? "border-blue-500 bg-blue-50"
                            : "border-gray-200 hover:border-gray-300 bg-white"
                        }`}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <p className="font-semibold text-gray-900 mb-1">
                              Recording {index + 1}
                            </p>
                            <p className="text-xs text-gray-500 mb-2">
                              {formatDate(recording.created_at)}
                            </p>
                            <div className="flex items-center text-xs text-gray-600">
                              <svg
                                className="w-3 h-3 mr-1"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                                />
                              </svg>
                              {formatDuration(recording.duration)}
                            </div>
                          </div>
                          {selectedRecording?.id === recording.id && (
                            <div className="flex-shrink-0">
                              <svg
                                className="w-5 h-5 text-blue-600"
                                fill="currentColor"
                                viewBox="0 0 20 20"
                              >
                                <path
                                  fillRule="evenodd"
                                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                                  clipRule="evenodd"
                                />
                              </svg>
                            </div>
                          )}
                        </div>
                      </button>
                    ))}

                    {/* Recordings without videos (pending upload) */}
                    {recordingsWithoutVideos.length > 0 && (
                      <>
                        <div className="pt-3 border-t border-gray-200 mt-3">
                          <p className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-2">
                            Pending Upload
                          </p>
                        </div>
                        {recordingsWithoutVideos.map((recording, index) => (
                          <div
                            key={recording.id}
                            className="w-full p-4 rounded-lg border-2 border-yellow-200 bg-yellow-50 opacity-60"
                          >
                            <div className="flex items-start justify-between">
                              <div className="flex-1">
                                <div className="flex items-center gap-2">
                                  <p className="font-semibold text-gray-700 text-sm">
                                    Recording {recordingsWithVideos.length + index + 1}
                                  </p>
                                  <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-200 text-yellow-800">
                                    Processing
                                  </span>
                                </div>
                                <p className="text-xs text-gray-500 mt-1">
                                  {formatDate(recording.created_at)}
                                </p>
                                <p className="text-xs text-gray-600 mt-2">
                                  Video file not yet available
                                </p>
                              </div>
                              <svg
                                className="w-5 h-5 text-yellow-600 animate-pulse"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                                />
                              </svg>
                            </div>
                          </div>
                        ))}
                      </>
                    )}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
