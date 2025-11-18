"use client";

import { useMovementDetections } from "@/hooks";
import type { MovementDetection, ValidationStatus } from "@/types";
import {
  CheckCircleIcon,
  ClockIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";
import { useEffect, useState } from "react";

interface MovementDetectionPanelProps {
  roomId: string;
  recordingId?: string;
  showValidationButtons?: boolean;
  maxDetections?: number;
}

export function MovementDetectionPanel({
  roomId,
  recordingId,
  showValidationButtons = false,
  maxDetections = 10,
}: MovementDetectionPanelProps) {
  const [showNotification, setShowNotification] = useState(false);
  const [latestDetection, setLatestDetection] =
    useState<MovementDetection | null>(null);

  const {
    detections,
    statistics,
    isLoading,
    error,
    isRealtimeConnected,
    updateValidationStatus,
    fetchStatistics,
  } = useMovementDetections({
    enableRealtime: true,
    roomId,
    recordingId,
    autoFetch: true,
    onRealtimeDetection: (detection) => {
      // Show notification for new detection
      setLatestDetection(detection);
      setShowNotification(true);
      setTimeout(() => setShowNotification(false), 5000);

      // Play notification sound
      try {
        const audio = new Audio("/notification.mp3");
        audio.volume = 0.3;
        audio.play().catch(() => {
          // Ignore autoplay errors
        });
      } catch {
        // Ignore audio errors
      }
    },
  });

  // Refresh statistics periodically
  useEffect(() => {
    if (roomId) {
      fetchStatistics(roomId, recordingId);
      const interval = setInterval(() => {
        fetchStatistics(roomId, recordingId);
      }, 30000); // Every 30 seconds
      return () => clearInterval(interval);
    }
  }, [roomId, recordingId, fetchStatistics]);

  const normalizeDetectionId = (id: string | number): number | null => {
    if (typeof id === "number") {
      return id;
    }
    const parsed = Number(id);
    return Number.isFinite(parsed) ? parsed : null;
  };

  const handleValidate = async (
    detectionId: string | number,
    status: ValidationStatus
  ) => {
    const normalizedId = normalizeDetectionId(detectionId);
    if (normalizedId === null) {
      console.warn("Skipping validation update for non-numeric id", detectionId);
      return;
    }
    await updateValidationStatus(normalizedId, status);
  };

  const getMovementColor = (name: string) => {
    const colors: Record<string, string> = {
      tremor: "bg-red-100 text-red-700 border-red-200",
      chorea: "bg-orange-100 text-orange-700 border-orange-200",
      myoclonus: "bg-yellow-100 text-yellow-700 border-yellow-200",
      dystonia: "bg-purple-100 text-purple-700 border-purple-200",
      ballistic: "bg-pink-100 text-pink-700 border-pink-200",
      normal: "bg-green-100 text-green-700 border-green-200",
    };
    return colors[name] || "bg-gray-100 text-gray-700 border-gray-200";
  };

  const getValidationBadge = (status: ValidationStatus) => {
    switch (status) {
      case "confirmed":
        return (
          <div className="flex items-center gap-1 px-2 py-1 bg-green-100 text-green-700 rounded-md text-xs font-medium">
            <CheckCircleIcon className="h-3 w-3" />
            Confirmed
          </div>
        );
      case "rejected":
        return (
          <div className="flex items-center gap-1 px-2 py-1 bg-red-100 text-red-700 rounded-md text-xs font-medium">
            <XCircleIcon className="h-3 w-3" />
            Rejected
          </div>
        );
      default:
        return (
          <div className="flex items-center gap-1 px-2 py-1 bg-yellow-100 text-yellow-700 rounded-md text-xs font-medium">
            <ClockIcon className="h-3 w-3" />
            Pending
          </div>
        );
    }
  };

  return (
    <div className="space-y-4">
      {/* Notification Banner */}
      {showNotification && latestDetection && (
        <div className="animate-slide-down bg-gradient-to-r from-red-500 to-orange-500 text-white p-4 rounded-xl shadow-lg">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center animate-pulse">
              <span className="text-2xl">🚨</span>
            </div>
            <div className="flex-1">
              <p className="font-bold text-sm uppercase tracking-wide">
                New Detection
              </p>
              <p className="text-lg font-semibold capitalize">
                {latestDetection.name.replace("_", " ")}
              </p>
              <p className="text-xs opacity-90">
                Confidence: {(latestDetection.confidence * 100).toFixed(1)}% •{" "}
                {latestDetection.timestamp}s
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Connection Status */}
      <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
        <div className="flex items-center gap-2">
          <div
            className={`w-2 h-2 rounded-full ${
              isRealtimeConnected ? "bg-green-500 animate-pulse" : "bg-red-500"
            }`}
          />
          <span className="text-sm font-medium text-slate-700">
            {isRealtimeConnected ? "Live Detection" : "Disconnected"}
          </span>
        </div>
        {statistics && (
          <span className="text-xs text-slate-500">
            {statistics.total_detections} total
          </span>
        )}
      </div>

      {/* Statistics Cards */}
      {statistics && (
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-gradient-to-br from-blue-50 to-blue-100 p-3 rounded-lg border border-blue-200">
            <p className="text-xs text-blue-600 font-medium mb-1">Total</p>
            <p className="text-2xl font-bold text-blue-700">
              {statistics.total_detections}
            </p>
          </div>
          <div className="bg-gradient-to-br from-green-50 to-green-100 p-3 rounded-lg border border-green-200">
            <p className="text-xs text-green-600 font-medium mb-1">Confirmed</p>
            <p className="text-2xl font-bold text-green-700">
              {statistics.by_validation_status.confirmed || 0}
            </p>
          </div>
          <div className="bg-gradient-to-br from-yellow-50 to-yellow-100 p-3 rounded-lg border border-yellow-200">
            <p className="text-xs text-yellow-600 font-medium mb-1">Pending</p>
            <p className="text-2xl font-bold text-yellow-700">
              {statistics.by_validation_status.pending || 0}
            </p>
          </div>
          <div className="bg-gradient-to-br from-purple-50 to-purple-100 p-3 rounded-lg border border-purple-200">
            <p className="text-xs text-purple-600 font-medium mb-1">
              Avg Conf.
            </p>
            <p className="text-2xl font-bold text-purple-700">
              {(statistics.average_confidence * 100).toFixed(0)}%
            </p>
          </div>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-red-700">{error}</p>
        </div>
      )}

      {/* Loading State */}
      {isLoading && detections.length === 0 && (
        <div className="text-center py-8">
          <div className="w-8 h-8 mx-auto mb-2 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-sm text-slate-500">Loading detections...</p>
        </div>
      )}

      {/* Detections List */}
      <div className="space-y-2 max-h-[600px] overflow-y-auto">
        {detections.slice(0, maxDetections).map((detection, index) => (
          <div
            key={detection.id}
            className="bg-white border border-slate-200 rounded-lg p-3 hover:shadow-md transition-all animate-fade-in"
            style={{ animationDelay: `${index * 50}ms` }}
          >
            <div className="flex items-start justify-between mb-2">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span
                    className={`px-2 py-1 rounded-md text-xs font-semibold capitalize border ${getMovementColor(
                      detection.name
                    )}`}
                  >
                    {detection.name.replace("_", " ")}
                  </span>
                  {getValidationBadge(detection.validation_status)}
                </div>
                <div className="space-y-1 text-xs text-slate-600">
                  <p>
                    <span className="font-medium">Confidence:</span>{" "}
                    <span className="font-semibold text-slate-900">
                      {(detection.confidence * 100).toFixed(1)}%
                    </span>
                  </p>
                  <p>
                    <span className="font-medium">Time:</span>{" "}
                    {detection.timestamp}s
                  </p>
                  <p className="text-slate-400">
                    {new Date(detection.created_at).toLocaleTimeString()}
                  </p>
                </div>
              </div>
            </div>

            {/* Validation Buttons */}
            {showValidationButtons &&
              detection.validation_status === "pending" && (
                <div className="flex gap-2 mt-3 pt-3 border-t border-slate-100">
                  <button
                    onClick={() => handleValidate(detection.id, "confirmed")}
                    className="flex-1 px-3 py-1.5 bg-green-500 hover:bg-green-600 text-white text-xs font-medium rounded-md transition-colors flex items-center justify-center gap-1"
                  >
                    <CheckCircleIcon className="h-4 w-4" />
                    Confirm
                  </button>
                  <button
                    onClick={() => handleValidate(detection.id, "rejected")}
                    className="flex-1 px-3 py-1.5 bg-red-500 hover:bg-red-600 text-white text-xs font-medium rounded-md transition-colors flex items-center justify-center gap-1"
                  >
                    <XCircleIcon className="h-4 w-4" />
                    Reject
                  </button>
                </div>
              )}
          </div>
        ))}

        {detections.length === 0 && !isLoading && (
          <div className="text-center py-8">
            <div className="w-16 h-16 mx-auto mb-3 bg-slate-100 rounded-full flex items-center justify-center">
              <span className="text-3xl">🎯</span>
            </div>
            <p className="text-slate-600 font-medium mb-1">No Detections Yet</p>
            <p className="text-xs text-slate-500">
              Movement detections will appear here in real-time
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
