/**
 * TimelineSyncedDetectionPanel Component
 * Displays AI detections synced to video playback timestamp
 * Shows detections that occurred at the current video time
 */

"use client";

import React, { useEffect, useState } from "react";
import { api } from "@/services/api";

interface PoseLandmark {
  x: number;
  y: number;
  z: number;
  visibility: number;
}

interface DetectionProbabilities {
  pose_landmarks?: PoseLandmark[];
  all_probabilities?: Record<string, number>;
}

export interface TimelineDetection {
  id: number | string;
  timestamp: number;
  name: string;
  confidence: number;
  validation_status: "pending" | "confirmed" | "rejected";
  room_id?: string;
  recording_id: string;
  created_at: string;
  updated_at: string;
  detection_data?: DetectionProbabilities;
}

interface PredictionSummary {
  predicted_class: string;
  confidence: number;
  top3: Array<{ class: string; confidence: number }>;
}

interface RecordingDetails {
  id: string;
  session_id?: string;
  session_start?: string;
  session_end?: string;
  duration?: number | null;
  created_at: string;
}

interface AIDetection {
  id: number;
  detection_type: string;
  confidence_score?: number;
  room_id?: string;
  recording_id?: string;
  session_id?: string;
  created_at: string;
  frame_timestamp?: string;
  detection_data?: DetectionProbabilities;
}

interface TimelineSyncedDetectionPanelProps {
  recordingId: string; // UUID of the recording
  currentTimestamp: number; // Current video time in seconds
  timeWindow?: number; // Show detections within ±X seconds (default: 2)
  maxDetections?: number;
  onLandmarksChange?: (landmarks: PoseLandmark[] | null) => void; // Callback for current landmarks
  onPredictionChange?: (prediction: PredictionSummary | null) => void; // Callback for current prediction
  onSeekToTime?: (timestamp: number) => void; // Callback to seek video to specific time
  onDetectionsReady?: (detections: TimelineDetection[]) => void; // Callback when detections load for sharing elsewhere
  showPanel?: boolean; // Allows running logic without rendering UI
}

export default function TimelineSyncedDetectionPanel({
  recordingId,
  currentTimestamp,
  timeWindow = 2,
  maxDetections = 5,
  onLandmarksChange,
  onPredictionChange,
  onSeekToTime,
  onDetectionsReady,
  showPanel = true,
}: TimelineSyncedDetectionPanelProps) {
  const [allDetections, setAllDetections] = useState<TimelineDetection[]>([]);
  const [windowDetections, setWindowDetections] = useState<TimelineDetection[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Fetch ALL detections for the recording (once)
  useEffect(() => {
    if (!recordingId) return;

    // Reset state when recording changes to avoid stale UI
    setAllDetections([]);
    if (onDetectionsReady) {
      onDetectionsReady([]);
    }

    const fetchDetections = async () => {
      setLoading(true);
      setError(null);

      try {
        // Fetch recording metadata directly by ID to get session_id for querying detections
        const recordingResponse = await api.get<RecordingDetails>(
          `/videos/recordings/${recordingId}`
        );

        if (recordingResponse.error || !recordingResponse.data) {
          setError(`Recording ${recordingId} not found`);
          setLoading(false);
          return;
        }
        
        const recording = recordingResponse.data;
        console.log(
          "📋 [Timeline] Fetched recording: %s (session: %s)",
          recording.id,
          recording.session_id
        );
        const sessionId = recording.session_id;

        // Determine recording start time for timestamp conversion
        const startTime = new Date(recording.session_start || recording.created_at);
        const recordingStartMs = startTime.getTime();

        const recordingDurationSeconds = (() => {
          const candidates: number[] = [];
          if (
            typeof recording.duration === "number" &&
            !Number.isNaN(recording.duration) &&
            recording.duration > 0
          ) {
            candidates.push(recording.duration);
          }

          if (recording.session_end) {
            const sessionEndMs = new Date(recording.session_end).getTime();
            if (!Number.isNaN(sessionEndMs)) {
              const diffSeconds = (sessionEndMs - startTime.getTime()) / 1000;
              if (diffSeconds > 0) {
                candidates.push(diffSeconds);
              }
            }
          }

          if (candidates.length === 0) {
            return null;
          }

          return Math.max(...candidates);
        })();

        console.log(`⏱️ [Timeline] Recording starts at: ${startTime.toISOString()}`);
        
        console.log(
          `🔍 [Timeline] Querying detections for recording_id: ${recordingId} (session_id: ${sessionId || "n/a"})`
        );

        // Fetch movement_detections using the actual recording ID (timestamps already relative to recording start)
        const movementResponse = await api.get<TimelineDetection[]>(
          `/api/movement-detections/recording/${recordingId}?limit=500`
        );

        // Fetch ai_detections primarily by recording_id (new API filter)
        const aiByRecordingResponse = await api.get<AIDetection[]>(
          `/ai-detections?recording_id=${recordingId}&limit=500`
        );

        if (movementResponse.error) {
          setError(movementResponse.error);
          return;
        }

        let rawAIDetections = aiByRecordingResponse.data || [];

        if (aiByRecordingResponse.error) {
          console.warn("⚠️ [Timeline] AI detection request error:", aiByRecordingResponse.error);
        }

        // Fallback: some historical detections only stored session_id
        if (rawAIDetections.length === 0 && sessionId) {
          console.log(
            "⚠️ [Timeline] No AI detections found by recording_id. Falling back to session_id query."
          );
          const aiBySessionResponse = await api.get<AIDetection[]>(
            `/ai-detections?session_id=${sessionId}&limit=500`
          );
          rawAIDetections = aiBySessionResponse.data || [];

          if (aiBySessionResponse.error) {
            console.warn("⚠️ [Timeline] Session fallback request error:", aiBySessionResponse.error);
          }
        }

        const movementDetections: TimelineDetection[] = movementResponse.data || [];
        
        // Filter out session_summary detections (they don't have pose_landmarks)
        const aiDetections = rawAIDetections.filter((ai) => 
          ai.detection_type !== 'session_summary' && 
          ai.detection_data?.pose_landmarks
        );
        
        console.log(`🔍 [Timeline] Fetched data for recording ${recordingId}:`);
        console.log(`  - Movement detections: ${movementDetections.length}`);
        console.log(`  - AI detections: ${aiDetections.length} (filtered from ${rawAIDetections.length})`);
        console.log(`  - Recording start time: ${startTime.toISOString()}`);
        if (recordingDurationSeconds !== null) {
          console.log(`  - Recording duration: ${recordingDurationSeconds.toFixed(1)}s`);
        }
        
        if (aiDetections.length > 0) {
          console.log(`  - First AI detection:`, {
            frame_timestamp: aiDetections[0].frame_timestamp,
            detection_type: aiDetections[0].detection_type,
            landmark_count: aiDetections[0].detection_data?.pose_landmarks?.length,
          });
        }
        
        // Convert AI detections to MovementDetection format using the actual recording start time
        // Use AI detections directly since movement_detections might be empty
        const convertedDetections: Array<TimelineDetection | null> = aiDetections.map((ai) => {
          let relativeSeconds: number | null = null;

          // Prefer explicit frame_timestamp if present (already relative seconds)
          if (ai.frame_timestamp) {
            const numericFrame = Number(ai.frame_timestamp);
            if (
              !Number.isNaN(numericFrame) &&
              Number.isFinite(numericFrame) &&
              numericFrame >= 0
            ) {
              relativeSeconds = numericFrame;
            } else {
              const frameTime = new Date(ai.frame_timestamp).getTime();
              if (!Number.isNaN(frameTime) && frameTime >= recordingStartMs) {
                relativeSeconds = (frameTime - recordingStartMs) / 1000;
              }
            }
          }

          // Fallback to created_at delta
          if (relativeSeconds === null) {
            const aiAbsoluteTime = new Date(ai.created_at).getTime();
            if (Number.isNaN(aiAbsoluteTime)) {
              return null;
            }
            relativeSeconds = (aiAbsoluteTime - recordingStartMs) / 1000;
          }

          // Normalize negatives caused by timestamp jitter or bogus values
          if (relativeSeconds < -5) {
            return null;
          } else if (relativeSeconds < 0) {
            relativeSeconds = 0;
          }

          if (
            recordingDurationSeconds !== null &&
            relativeSeconds > recordingDurationSeconds + 5 // keep 5s tolerance for trailing detections
          ) {
            return null;
          }
          
          return {
            id: ai.id,
            timestamp: Number(relativeSeconds.toFixed(3)),
            name: ai.detection_type,
            confidence: ai.confidence_score ?? 0,
            detection_data: ai.detection_data,
            validation_status: "pending" as const,
            room_id: ai.room_id || "",
            recording_id: recordingId,
            created_at: ai.created_at,
            updated_at: ai.created_at,
          };
        });

        const boundedDetections: TimelineDetection[] = convertedDetections.filter(
          (detection): detection is TimelineDetection => detection !== null
        );

        console.log(`📊 [Timeline] Converted ${boundedDetections.length} AI detections to MovementDetection format`);
        console.log(`  - Detections with landmarks: ${boundedDetections.filter(d => d.detection_data?.pose_landmarks).length}`);
        if (boundedDetections.length > 0) {
          const timestamps = boundedDetections.map((d) => d.timestamp);
          console.log(
            `  - Timestamp range: ${Math.min(...timestamps).toFixed(2)}s - ${Math.max(...timestamps).toFixed(2)}s`
          );
        }
        
        if (boundedDetections.length > 0 && boundedDetections[0].detection_data?.pose_landmarks) {
          console.log(`  - Sample landmarks (first 3):`, boundedDetections[0].detection_data.pose_landmarks.slice(0, 3));
        }
        
        setAllDetections(boundedDetections);
        if (onDetectionsReady) {
          onDetectionsReady(boundedDetections);
        }
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : "Failed to fetch detections";
        console.error("❌ [Timeline] Error:", err);
        setError(errorMsg);
      } finally {
        setLoading(false);
      }
    };

    fetchDetections();
  }, [recordingId, onDetectionsReady]);

  // Filter detections based on current video timestamp
  useEffect(() => {
    if (allDetections.length === 0) return;

    // Find detections within the time window using simple timestamp comparison
    const relevant = allDetections.filter((detection) => {
      const diffSeconds = Math.abs(detection.timestamp - currentTimestamp);
      return diffSeconds <= timeWindow;
    });

    // Sort by proximity to current time (closest first)
    relevant.sort((a, b) => {
      const diffA = Math.abs(a.timestamp - currentTimestamp);
      const diffB = Math.abs(b.timestamp - currentTimestamp);
      return diffA - diffB;
    });

    const windowSlice = relevant.slice(0, maxDetections);
    setWindowDetections(windowSlice);

    // Notify parent of current landmarks and prediction (from closest detection)
    if (relevant.length > 0) {
      const closest = relevant[0];
      const landmarks = closest.detection_data?.pose_landmarks || null;
      
      console.log(`🎬 Playback sync at ${currentTimestamp.toFixed(2)}s:`, {
        detectionName: closest.name,
        confidence: closest.confidence,
        hasLandmarks: !!landmarks,
        landmarkCount: landmarks?.length || 0,
        detectionDataKeys: closest.detection_data ? Object.keys(closest.detection_data) : []
      });
      
      if (onLandmarksChange) {
        onLandmarksChange(landmarks);
      }
      if (onPredictionChange) {
        const probabilities = closest.detection_data?.all_probabilities ?? null;
        const top3 = probabilities
          ? Object.entries(probabilities)
              .map(([cls, conf]) => ({ class: cls, confidence: typeof conf === "number" ? conf : Number(conf) }))
              .sort((a, b) => b.confidence - a.confidence)
              .slice(0, 3)
          : [];

        const prediction: PredictionSummary = {
          predicted_class: closest.name,
          confidence: closest.confidence,
          top3,
        };

        onPredictionChange(prediction);
      }
      console.log(
        `⏱️ [Timeline] At ${currentTimestamp.toFixed(1)}s: Found ${relevant.length} detections`
      );
    } else {
      // Clear landmarks/predictions when no detections nearby
      if (onLandmarksChange) onLandmarksChange(null);
      if (onPredictionChange) onPredictionChange(null);
    }
  }, [currentTimestamp, allDetections, timeWindow, maxDetections, onLandmarksChange, onPredictionChange]);

  /**
   * Get confidence color based on score (0.0 to 1.0)
   */
  const getConfidenceColor = (confidence: number): string => {
    if (confidence >= 0.8) return "text-green-600";
    if (confidence >= 0.6) return "text-yellow-600";
    return "text-red-600";
  };

  /**
   * Get confidence background color
   */
  const getConfidenceBg = (confidence: number): string => {
    if (confidence >= 0.8) return "bg-green-50 border-green-200";
    if (confidence >= 0.6) return "bg-yellow-50 border-yellow-200";
    return "bg-red-50 border-red-200";
  };

  if (!showPanel) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow-lg p-4">
      {/* Header */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center space-x-2">
          <div className="bg-purple-100 p-1.5 rounded-lg">
            <svg
              className="w-5 h-5 text-purple-600"
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
          <div>
            <h3 className="text-sm font-bold text-gray-900">Timeline Detections</h3>
            <p className="text-xs text-gray-500">At {currentTimestamp.toFixed(1)}s</p>
          </div>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="mb-3 p-2 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-xs text-red-800">❌ {error}</p>
        </div>
      )}

      {/* Loading State */}
      {loading && (
        <div className="flex items-center justify-center py-6">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
          <p className="text-xs text-gray-500 ml-2">Loading detections...</p>
        </div>
      )}

      {/* Stats */}
      {!loading && allDetections.length > 0 && (
        <div className="mb-3 p-2 bg-purple-50 border border-purple-200 rounded-lg">
          <p className="text-xs text-purple-700">
            📊 {allDetections.length} total detections • {windowDetections.length} near current time
          </p>
        </div>
      )}

      {/* Detections List */}
      <div className="space-y-2 max-h-80 overflow-y-auto">
        {!loading && allDetections.length === 0 ? (
          <div className="text-center py-6">
            <svg
              className="w-12 h-12 text-gray-300 mx-auto mb-2"
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
            <p className="text-gray-500 text-xs">No detections available yet</p>
          </div>
        ) : (
          [...allDetections]
            .sort((a, b) => a.timestamp - b.timestamp)
            .map((detection) => {
              const isActive = Math.abs(detection.timestamp - currentTimestamp) <= timeWindow;
              return (
                <div
                  key={detection.id}
                  onClick={() => onSeekToTime?.(detection.timestamp)}
                  className={`p-3 rounded-lg border-2 transition-all cursor-pointer hover:shadow-md hover:scale-[1.02] ${
                    isActive ? "ring-2 ring-purple-200" : ""
                  } ${getConfidenceBg(detection.confidence)}`}
                  title="Click to jump to this detection"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <span className="px-2 py-0.5 bg-white rounded-full text-xs font-semibold text-gray-800 border">
                          {detection.name}
                        </span>
                        <span
                          className={`text-xs font-bold ${getConfidenceColor(
                            detection.confidence
                          )}`}
                        >
                          {(detection.confidence * 100).toFixed(1)}%
                        </span>
                      </div>

                      <div className="flex items-center space-x-3 text-[10px] text-gray-600">
                        <span>⏱️ {detection.timestamp.toFixed(1)}s</span>
                        <span className={`px-1.5 py-0.5 rounded text-[9px] font-medium ${
                          detection.validation_status === "confirmed"
                            ? "bg-green-100 text-green-700"
                            : detection.validation_status === "rejected"
                            ? "bg-red-100 text-red-700"
                            : "bg-gray-100 text-gray-600"
                        }`}>
                          {detection.validation_status}
                        </span>
                      </div>
                    </div>
                    {isActive && (
                      <span className="text-[10px] font-semibold text-purple-700 bg-purple-100 px-2 py-0.5 rounded-full">
                        Now
                      </span>
                    )}
                  </div>
                </div>
              );
            })
        )}
      </div>
    </div>
  );
}
