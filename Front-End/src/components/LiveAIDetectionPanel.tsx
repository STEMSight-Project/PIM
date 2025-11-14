/**
 * LiveAIDetectionPanel Component
 * Displays real-time AI detections from live streaming sessions
 */

"use client";

import { useEffect, useRef, useState } from "react";
import { useAIDetections } from "@/hooks/useAIDetections";
import { AIDetection } from "@/services/aiDetectionService";
import { api } from "@/services/api";

interface LiveAIDetectionPanelProps {
  roomId?: string;
  sessionId?: string;
  showStatistics?: boolean;
  maxDetections?: number;
  enableSound?: boolean;
}

export default function LiveAIDetectionPanel({
  roomId,
  sessionId,
  showStatistics = true,
  maxDetections = 15,
  enableSound = true,
}: LiveAIDetectionPanelProps) {
  const [roomName, setRoomName] = useState<string | null>(null);
  const [fetchingRoomName, setFetchingRoomName] = useState(false);

  // Fetch room_name from UUID if roomId is provided
  useEffect(() => {
    if (!roomId || roomName) return;

    const fetchRoomName = async () => {
      setFetchingRoomName(true);
      try {
        // Query camera_streaming_rooms table to get room_name
        const response = await api.get<any[]>(
          `/ambulance-streaming/camera-rooms?id=${roomId}`
        );

        if (response.data && response.data.length > 0) {
          const fetchedRoomName = response.data[0].room_name;
          console.log(`📍 Fetched room_name: ${fetchedRoomName} for UUID: ${roomId}`);
          setRoomName(fetchedRoomName);
        } else {
          console.warn(`⚠️ No room found for UUID: ${roomId}`);
        }
      } catch (err) {
        console.error(`❌ Failed to fetch room_name for UUID ${roomId}:`, err);
      } finally {
        setFetchingRoomName(false);
      }
    };

    fetchRoomName();
  }, [roomId, roomName]);

  const { detections, statistics, loading, error, isRealtimeConnected } =
    useAIDetections({
      roomId: roomName || undefined, // Use room_name string, not UUID
      sessionId,
      enableRealtime: true,
      maxDetections,
      onNewDetection: handleNewDetection,
    });

  const [showNotification, setShowNotification] = useState(false);
  const [latestDetection, setLatestDetection] = useState<AIDetection | null>(
    null
  );
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const previousDetectionCount = useRef(0);

  /**
   * Handle new detection callback
   */
  function handleNewDetection(detection: AIDetection) {
    console.log("🆕 New AI detection:", detection);

    // Show notification
    setLatestDetection(detection);
    setShowNotification(true);

    // Play sound if enabled
    if (enableSound && audioRef.current) {
      audioRef.current.play().catch((err) => {
        console.warn("Failed to play detection sound:", err);
      });
    }

    // Hide notification after 3 seconds
    setTimeout(() => {
      setShowNotification(false);
    }, 3000);
  }

  /**
   * Initialize audio element
   */
  useEffect(() => {
    if (enableSound && typeof window !== "undefined") {
      audioRef.current = new Audio("/sounds/detection-alert.mp3");
      audioRef.current.volume = 0.3;
    }
  }, [enableSound]);

  /**
   * Track detection count changes
   */
  useEffect(() => {
    if (detections.length > previousDetectionCount.current) {
      console.log(
        `📊 Detection count increased: ${previousDetectionCount.current} → ${detections.length}`
      );
    }
    previousDetectionCount.current = detections.length;
  }, [detections.length]);

  /**
   * Get confidence color based on score
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
    if (confidence >= 0.8) return "bg-green-50";
    if (confidence >= 0.6) return "bg-yellow-50";
    return "bg-red-50";
  };

  /**
   * Format timestamp to relative time
   */
  const formatRelativeTime = (timestamp: string): string => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.floor(diffMs / 1000);

    if (diffSec < 10) return "just now";
    if (diffSec < 60) return `${diffSec}s ago`;
    if (diffSec < 3600) return `${Math.floor(diffSec / 60)}m ago`;
    return `${Math.floor(diffSec / 3600)}h ago`;
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="bg-blue-100 p-2 rounded-lg">
            <svg
              className="w-6 h-6 text-blue-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
              />
            </svg>
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-900">
              Live AI Detections
            </h2>
            <p className="text-sm text-gray-500">Real-time movement analysis</p>
          </div>
        </div>

        {/* Real-time Status */}
        <div className="flex items-center space-x-2">
          {isRealtimeConnected ? (
            <>
              <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-green-600 font-medium">Live</span>
            </>
          ) : (
            <>
              <div className="w-3 h-3 bg-gray-400 rounded-full"></div>
              <span className="text-sm text-gray-500">Offline</span>
            </>
          )}
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-red-800">❌ {error}</p>
        </div>
      )}

      {/* Debug: Show room info */}
      {roomName && (
        <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
          <p className="text-xs text-blue-700">
            🔍 Querying room: <span className="font-mono font-semibold">{roomName}</span>
          </p>
        </div>
      )}

      {/* New Detection Notification */}
      {showNotification && latestDetection && (
        <div className="mb-4 p-4 bg-blue-50 border-2 border-blue-500 rounded-lg animate-pulse">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-semibold text-blue-900">
                🆕 New Detection!
              </p>
              <p className="text-xs text-blue-700 mt-1">
                {latestDetection.detection_type} (
                {(latestDetection.confidence_score * 100).toFixed(1)}%)
              </p>
            </div>
            <button
              onClick={() => setShowNotification(false)}
              className="text-blue-600 hover:text-blue-800"
            >
              <svg
                className="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      )}

      {/* Statistics Cards */}
      {showStatistics && statistics && (
        <div className="grid grid-cols-2 gap-4 mb-6">
          <div className="bg-blue-50 p-4 rounded-lg">
            <p className="text-sm text-blue-600 font-medium">Total</p>
            <p className="text-2xl font-bold text-blue-900">
              {statistics.total_detections}
            </p>
          </div>
          <div className="bg-green-50 p-4 rounded-lg">
            <p className="text-sm text-green-600 font-medium">Avg Confidence</p>
            <p className="text-2xl font-bold text-green-900">
              {(statistics.average_confidence * 100).toFixed(1)}%
            </p>
          </div>
          <div className="bg-purple-50 p-4 rounded-lg">
            <p className="text-sm text-purple-600 font-medium">Recent (5m)</p>
            <p className="text-2xl font-bold text-purple-900">
              {statistics.recent_detections}
            </p>
          </div>
          <div className="bg-orange-50 p-4 rounded-lg">
            <p className="text-sm text-orange-600 font-medium">
              Unique Classes
            </p>
            <p className="text-2xl font-bold text-orange-900">
              {Object.keys(statistics.by_detection_type || {}).length}
            </p>
          </div>
        </div>
      )}

      {/* Loading State */}
      {(loading || fetchingRoomName) && (
        <div className="flex items-center justify-center py-8">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600"></div>
          <p className="text-sm text-gray-500 ml-3">
            {fetchingRoomName ? "Loading room info..." : "Loading detections..."}
          </p>
        </div>
      )}

      {/* Detections List */}
      <div className="space-y-3 max-h-96 overflow-y-auto">
        {!loading && detections.length === 0 ? (
          <div className="text-center py-8">
            <svg
              className="w-16 h-16 text-gray-300 mx-auto mb-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
              />
            </svg>
            <p className="text-gray-500 text-sm">
              {isRealtimeConnected
                ? "Waiting for detections..."
                : "No detections yet"}
            </p>
          </div>
        ) : (
          detections.map((detection) => (
            <div
              key={detection.id}
              className={`p-4 rounded-lg border-2 transition-all hover:shadow-md ${getConfidenceBg(
                detection.confidence_score
              )}`}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center space-x-2 mb-2">
                    <span className="px-3 py-1 bg-white rounded-full text-sm font-semibold text-gray-800 border">
                      {detection.detection_type}
                    </span>
                    <span
                      className={`text-sm font-bold ${getConfidenceColor(
                        detection.confidence_score
                      )}`}
                    >
                      {(detection.confidence_score * 100).toFixed(1)}%
                    </span>
                  </div>

                  <div className="flex items-center space-x-4 text-xs text-gray-600">
                    <span>⏱️ {formatRelativeTime(detection.created_at)}</span>
                    <span>📹 {detection.model_used}</span>
                    <span>
                      ⚡ {detection.processing_time_ms}ms (
                      {detection.processed_on})
                    </span>
                  </div>

                  {/* Additional metadata */}
                  {detection.detection_data && (
                    <div className="mt-2 text-xs text-gray-500">
                      <details className="cursor-pointer">
                        <summary className="font-medium">
                          View probabilities
                        </summary>
                        <div className="mt-2 space-y-1 pl-4">
                          {Object.entries(
                            detection.detection_data.all_probabilities || {}
                          )
                            .sort(([, a], [, b]) => (b as number) - (a as number))
                            .slice(0, 5)
                            .map(([className, prob]) => (
                              <div
                                key={className}
                                className="flex justify-between"
                              >
                                <span>{className}</span>
                                <span className="font-mono">
                                  {((prob as number) * 100).toFixed(1)}%
                                </span>
                              </div>
                            ))}
                        </div>
                      </details>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
