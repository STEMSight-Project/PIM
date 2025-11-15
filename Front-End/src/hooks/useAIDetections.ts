/**
 * useAIDetections Hook
 * React hook for managing live AI detections from ai_detections table
 */

import { useState, useEffect, useCallback } from "react";
import {
  AIDetection,
  AIDetectionStats,
  aiDetectionService,
} from "@/services/aiDetectionService";

interface UseAIDetectionsOptions {
  roomId?: string;
  sessionId?: string;
  enableRealtime?: boolean;
  onNewDetection?: (detection: AIDetection) => void;
  maxDetections?: number;
}

interface UseAIDetectionsReturn {
  detections: AIDetection[];
  statistics: AIDetectionStats | null;
  loading: boolean;
  error: string | null;
  isRealtimeConnected: boolean;
  refresh: () => Promise<void>;
  clearDetections: () => void;
}

/**
 * Hook for managing live AI detections from streaming sessions
 *
 * @param options Configuration options
 * @returns Detection data, statistics, and control methods
 *
 * @example
 * ```tsx
 * const { detections, statistics, loading } = useAIDetections({
 *   roomId: "AMB-001-ROOM-001",
 *   enableRealtime: true,
 *   onNewDetection: (detection) => console.log("New:", detection)
 * });
 * ```
 */
export function useAIDetections(
  options: UseAIDetectionsOptions = {}
): UseAIDetectionsReturn {
  const {
    roomId,
    sessionId,
    enableRealtime = true,
    onNewDetection,
    maxDetections = 50,
  } = options;

  const [detections, setDetections] = useState<AIDetection[]>([]);
  const [statistics, setStatistics] = useState<AIDetectionStats | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isRealtimeConnected, setIsRealtimeConnected] = useState(false);

  /**
   * Fetch detections from API
   */
  const fetchDetections = useCallback(async () => {
    if (!roomId && !sessionId) {
      setError("Either roomId or sessionId is required");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      let fetchedDetections: AIDetection[] = [];

      if (roomId) {
        fetchedDetections = await aiDetectionService.fetchByRoom(
          roomId,
          maxDetections
        );
      } else if (sessionId) {
        fetchedDetections = await aiDetectionService.fetchBySession(
          sessionId,
          maxDetections
        );
      }

      setDetections(fetchedDetections);
      setError(null);
    } catch (err) {
      const errorMsg =
        err instanceof Error ? err.message : "Failed to fetch AI detections";
      console.error("❌ Error fetching AI detections:", err);
      setError(errorMsg);
    } finally {
      setLoading(false);
    }
  }, [roomId, sessionId, maxDetections]);

  /**
   * Fetch statistics
   */
  const fetchStatistics = useCallback(async () => {
    if (!roomId && !sessionId) return;

    try {
      const stats = await aiDetectionService.fetchStats(roomId, sessionId);
      setStatistics(stats);
    } catch (err) {
      console.error("❌ Error fetching AI detection stats:", err);
    }
  }, [roomId, sessionId]);

  /**
   * Initial fetch on mount or when IDs change
   */
  useEffect(() => {
    if (roomId || sessionId) {
      fetchDetections();
      fetchStatistics();
    }
  }, [roomId, sessionId, fetchDetections, fetchStatistics]);

  /**
   * Set up real-time subscription
   */
  useEffect(() => {
    if (!enableRealtime || !roomId) {
      setIsRealtimeConnected(false);
      return;
    }

    console.log("📡 Setting up real-time AI detection subscription...");
    setIsRealtimeConnected(true);

    const unsubscribe = aiDetectionService.subscribe(
      roomId,
      (newDetection) => {
        console.log("🆕 New AI detection received:", newDetection);

        // Add to detections list (limit to maxDetections)
        setDetections((prev) => {
          // Check if detection already exists (by ID)
          const exists = prev.some((d) => d.id === newDetection.id);
          if (exists) {
            console.log("⚠️ Detection already exists, skipping:", newDetection.id);
            return prev;
          }

          // Add to beginning and limit
          const updated = [newDetection, ...prev];
          console.log(`📊 Updated detections: ${updated.length} total (added ${newDetection.detection_type})`);
          return updated.slice(0, maxDetections);
        });

        // Update statistics
        fetchStatistics();

        // Call callback if provided
        if (onNewDetection) {
          onNewDetection(newDetection);
        }
      }
    );

    return () => {
      console.log("🔌 Unsubscribing from AI detections");
      setIsRealtimeConnected(false);
      unsubscribe();
    };
  }, [
    enableRealtime,
    roomId,
    maxDetections,
    onNewDetection,
    fetchStatistics,
  ]);

  /**
   * Manual refresh
   */
  const refresh = useCallback(async () => {
    await fetchDetections();
    await fetchStatistics();
  }, [fetchDetections, fetchStatistics]);

  /**
   * Clear all detections from state
   */
  const clearDetections = useCallback(() => {
    setDetections([]);
    setStatistics(null);
  }, []);

  return {
    detections,
    statistics,
    loading,
    error,
    isRealtimeConnected,
    refresh,
    clearDetections,
  };
}
