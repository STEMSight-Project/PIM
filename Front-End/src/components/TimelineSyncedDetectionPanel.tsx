/**
 * TimelineSyncedDetectionPanel Component
 * Displays AI detections synced to video playback timestamp
 * Shows detections that occurred at the current video time
 */

"use client";

import { useEffect, useState } from "react";
import { api } from "@/services/api";

interface MovementDetection {
  id: number;
  timestamp: number; // Timestamp in video (seconds)
  name: string; // Movement type (e.g., 'tremor', 'dystonia')
  confidence: number; // 0.0 to 1.0
  validation_status: "pending" | "confirmed" | "rejected";
  room_id: string;
  recording_id: string;
  created_at: string;
  updated_at: string;
  detection_data?: {
    pose_landmarks?: Array<{x: number; y: number; z: number; visibility: number}>;
    all_probabilities?: Record<string, number>;
  };
}

interface TimelineSyncedDetectionPanelProps {
  recordingId: string; // UUID of the recording
  currentTimestamp: number; // Current video time in seconds
  timeWindow?: number; // Show detections within ±X seconds (default: 2)
  maxDetections?: number;
  onLandmarksChange?: (landmarks: any[] | null) => void; // Callback for current landmarks
  onPredictionChange?: (prediction: any | null) => void; // Callback for current prediction
  onSeekToTime?: (timestamp: number) => void; // Callback to seek video to specific time
}

export default function TimelineSyncedDetectionPanel({
  recordingId,
  currentTimestamp,
  timeWindow = 2,
  maxDetections = 5,
  onLandmarksChange,
  onPredictionChange,
  onSeekToTime,
}: TimelineSyncedDetectionPanelProps) {
  const [allDetections, setAllDetections] = useState<MovementDetection[]>([]);
  const [visibleDetections, setVisibleDetections] = useState<MovementDetection[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recordingStartTime, setRecordingStartTime] = useState<Date | null>(null);

  // Fetch ALL detections for the recording (once)
  useEffect(() => {
    if (!recordingId) return;

    const fetchDetections = async () => {
      setLoading(true);
      setError(null);

      try {
        // Fetch recording metadata directly by ID to get session_id for querying detections
        const recordingResponse = await api.get<any>(
          `/videos/recordings/${recordingId}`
        );
        
        const recording = recordingResponse.data;
        
        if (!recording) {
          setError(`Recording ${recordingId} not found`);
          setLoading(false);
          return;
        }
        
        console.log("📋 [Timeline] Fetched recording:", recording.id, "session:", recording.session_id);
        const sessionId = recording.session_id;
        
        // Set recording start time for timestamp conversion
        const startTime = new Date(recording.session_start || recording.created_at);
        setRecordingStartTime(startTime);
        console.log(`⏱️ [Timeline] Recording starts at: ${startTime.toISOString()}`);
        
        console.log(`🔍 [Timeline] Querying detections for session_id: ${sessionId}`);

        // Fetch movement_detections using session_id as recording_id
        // (Broadcaster stores detections with session_id in the recording_id field)
        const movementResponse = await api.get<MovementDetection[]>(
          `/api/movement-detections/recording/${sessionId}?limit=500`
        );

        // Fetch ai_detections using session_id
        const aiResponse = await api.get<any[]>(
          `/ai-detections?session_id=${sessionId}&limit=500`
        );

        if (movementResponse.error) {
          setError(movementResponse.error);
          return;
        }

        const movementDetections: MovementDetection[] = movementResponse.data || [];
        const rawAIDetections = aiResponse.data || [];
        
        // Filter out session_summary detections (they don't have pose_landmarks)
        const aiDetections = rawAIDetections.filter((ai: any) => 
          ai.detection_type !== 'session_summary' && 
          ai.detection_data?.pose_landmarks
        );
        
        console.log(`🔍 [Timeline] Fetched data for recording ${recordingId}:`);
        console.log(`  - Movement detections: ${movementDetections.length}`);
        console.log(`  - AI detections: ${aiDetections.length} (filtered from ${rawAIDetections.length})`);
        console.log(`  - Recording start time: ${startTime.toISOString()}`);
        
        if (aiDetections.length > 0) {
          console.log(`  - First AI detection:`, {
            frame_timestamp: aiDetections[0].frame_timestamp,
            detection_type: aiDetections[0].detection_type,
            landmark_count: aiDetections[0].detection_data?.pose_landmarks?.length,
          });
        }
        
        // Convert AI detections to MovementDetection format
        // Use AI detections directly since movement_detections might be empty
        const convertedDetections: MovementDetection[] = aiDetections.map((ai: any) => {
          // Use created_at (UTC) instead of frame_timestamp (local time with timezone issues)
          // The created_at timestamp is when detection was stored in DB and aligns with session time
          const aiAbsoluteTime = new Date(ai.created_at).getTime();
          const recordingStartMs = startTime.getTime();
          const relativeSeconds = (aiAbsoluteTime - recordingStartMs) / 1000;
          
          return {
            id: ai.id,
            timestamp: relativeSeconds,
            name: ai.detection_type,
            confidence: ai.confidence_score || 0,
            detection_data: ai.detection_data,
            validation_status: "pending" as const,
            room_id: ai.room_id || "",
            recording_id: sessionId,
            created_at: ai.created_at,
            updated_at: ai.created_at,
          };
        });

        console.log(`📊 [Timeline] Converted ${convertedDetections.length} AI detections to MovementDetection format`);
        console.log(`  - Detections with landmarks: ${convertedDetections.filter(d => d.detection_data?.pose_landmarks).length}`);
        console.log(`  - Timestamp range: ${Math.min(...convertedDetections.map(d => d.timestamp)).toFixed(2)}s - ${Math.max(...convertedDetections.map(d => d.timestamp)).toFixed(2)}s`);
        
        if (convertedDetections.length > 0 && convertedDetections[0].detection_data?.pose_landmarks) {
          console.log(`  - Sample landmarks (first 3):`, convertedDetections[0].detection_data.pose_landmarks.slice(0, 3));
        }
        
        setAllDetections(convertedDetections);
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : "Failed to fetch detections";
        console.error("❌ [Timeline] Error:", err);
        setError(errorMsg);
      } finally {
        setLoading(false);
      }
    };

    fetchDetections();
  }, [recordingId]);

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

    setVisibleDetections(relevant.slice(0, maxDetections));

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
        onPredictionChange({
          predicted_class: closest.name,
          confidence: closest.confidence,
          top3: closest.detection_data?.all_probabilities
            ? Object.entries(closest.detection_data.all_probabilities)
                .map(([cls, conf]) => ({ class: cls, confidence: conf }))
                .sort((a, b) => b.confidence - a.confidence)
                .slice(0, 3)
            : []
        });
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
            📊 {allDetections.length} total detections • {visibleDetections.length} at current time
          </p>
        </div>
      )}

      {/* Detections List */}
      <div className="space-y-2 max-h-80 overflow-y-auto">
        {!loading && visibleDetections.length === 0 ? (
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
            <p className="text-gray-500 text-xs">
              No detections at this timestamp
            </p>
          </div>
        ) : (
          visibleDetections.map((detection) => (
            <div
              key={detection.id}
              onClick={() => onSeekToTime?.(detection.timestamp)}
              className={`p-3 rounded-lg border-2 transition-all cursor-pointer hover:shadow-md hover:scale-[1.02] ${getConfidenceBg(
                detection.confidence
              )}`}
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
                    <span className="px-1.5 py-0.5 rounded text-[9px] font-medium ${
                      detection.validation_status === 'confirmed' ? 'bg-green-100 text-green-700' :
                      detection.validation_status === 'rejected' ? 'bg-red-100 text-red-700' :
                      'bg-gray-100 text-gray-600'
                    }">
                      {detection.validation_status}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
