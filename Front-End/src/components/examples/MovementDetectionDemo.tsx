// Example usage of useMovementDetections hook
// This component demonstrates how to use movement detection with realtime updates

"use client";

import { useMovementDetections } from "@/hooks";
import type { ValidationStatus } from "@/types/movementDetection";
import { useState } from "react";

export default function MovementDetectionDemo() {
  const [recordingId] = useState("1bce4928-82fe-4252-99ce-789e2783d1bc");

  const {
    detections,
    statistics,
    isLoading,
    error,
    isRealtimeConnected,
    fetchDetectionsByRecording,
    fetchStatistics,
    updateValidationStatus,
  } = useMovementDetections({
    enableRealtime: true,
    recordingId: recordingId,
    autoFetch: true,
    onRealtimeDetection: (detection) => {
      console.log("🆕 New detection received:", detection);
      // Show notification, play sound, etc.
    },
    onRealtimeUpdate: (detection) => {
      console.log("🔄 Detection updated:", detection);
    },
    onRealtimeDelete: (detectionId) => {
      console.log("🗑️ Detection deleted:", detectionId);
    },
  });

  const handleValidate = async (
    detectionId: number,
    status: ValidationStatus
  ) => {
    const success = await updateValidationStatus(detectionId, status);
    if (success) {
      console.log(`✅ Detection ${detectionId} ${status}`);
    }
  };

  const handleRefresh = async () => {
    await fetchDetectionsByRecording(recordingId);
    await fetchStatistics(undefined, recordingId);
  };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <div className="bg-white rounded-lg shadow-lg p-6">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-800">
              Movement Detections
            </h1>
            <p className="text-gray-600">Recording: {recordingId}</p>
          </div>

          {/* Status indicators */}
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <div
                className={`w-3 h-3 rounded-full ${
                  isRealtimeConnected ? "bg-green-500" : "bg-red-500"
                }`}
              />
              <span className="text-sm text-gray-600">
                {isRealtimeConnected ? "Live" : "Disconnected"}
              </span>
            </div>
            <button
              onClick={handleRefresh}
              disabled={isLoading}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50"
            >
              {isLoading ? "Loading..." : "Refresh"}
            </button>
          </div>
        </div>

        {/* Error message */}
        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        {/* Statistics */}
        {statistics && (
          <div className="mb-6 grid grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded">
              <p className="text-sm text-gray-600">Total</p>
              <p className="text-2xl font-bold text-blue-600">
                {statistics.total_detections}
              </p>
            </div>
            <div className="bg-green-50 p-4 rounded">
              <p className="text-sm text-gray-600">Confirmed</p>
              <p className="text-2xl font-bold text-green-600">
                {statistics.by_validation_status.confirmed || 0}
              </p>
            </div>
            <div className="bg-yellow-50 p-4 rounded">
              <p className="text-sm text-gray-600">Pending</p>
              <p className="text-2xl font-bold text-yellow-600">
                {statistics.by_validation_status.pending || 0}
              </p>
            </div>
            <div className="bg-purple-50 p-4 rounded">
              <p className="text-sm text-gray-600">Avg Confidence</p>
              <p className="text-2xl font-bold text-purple-600">
                {(statistics.average_confidence * 100).toFixed(1)}%
              </p>
            </div>
          </div>
        )}

        {/* Detections list */}
        <div className="space-y-4">
          {detections.length === 0 ? (
            <p className="text-center text-gray-500 py-8">
              No detections found
            </p>
          ) : (
            detections.map((detection) => (
              <div
                key={detection.id}
                className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
              >
                <div className="flex justify-between items-start">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="text-lg font-semibold text-gray-800 capitalize">
                        {detection.name.replace("_", " ")}
                      </h3>
                      <span
                        className={`px-2 py-1 text-xs rounded-full ${
                          detection.validation_status === "confirmed"
                            ? "bg-green-100 text-green-800"
                            : detection.validation_status === "rejected"
                            ? "bg-red-100 text-red-800"
                            : "bg-yellow-100 text-yellow-800"
                        }`}
                      >
                        {detection.validation_status}
                      </span>
                    </div>
                    <div className="text-sm text-gray-600 space-y-1">
                      <p>
                        <span className="font-medium">Confidence:</span>{" "}
                        {(detection.confidence * 100).toFixed(1)}%
                      </p>
                      <p>
                        <span className="font-medium">Timestamp:</span>{" "}
                        {detection.timestamp}s
                      </p>
                      <p>
                        <span className="font-medium">Detected:</span>{" "}
                        {new Date(detection.created_at).toLocaleString()}
                      </p>
                    </div>
                  </div>

                  {/* Validation buttons */}
                  {detection.validation_status === "pending" && (
                    <div className="flex gap-2">
                      <button
                        onClick={() =>
                          handleValidate(detection.id, "confirmed")
                        }
                        className="px-3 py-1 bg-green-500 text-white text-sm rounded hover:bg-green-600"
                      >
                        ✓ Confirm
                      </button>
                      <button
                        onClick={() => handleValidate(detection.id, "rejected")}
                        className="px-3 py-1 bg-red-500 text-white text-sm rounded hover:bg-red-600"
                      >
                        ✗ Reject
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
