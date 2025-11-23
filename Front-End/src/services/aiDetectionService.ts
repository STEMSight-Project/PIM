/**
 * AI Detection Service
 * Service for fetching live AI detections from ai_detections table
 */

import { api } from "./api";

export interface AIDetection {
  id: string;
  session_id: string;
  camera_id: string;
  room_id: string;
  detection_type: string;
  confidence_score: number;
  detection_data: {
    all_probabilities?: Record<string, number>;
    temperature?: number;
    frame_count?: number;
    model_architecture?: string;
  };
  frame_timestamp: string;
  sequence_number: number;
  model_used: string;
  processing_time_ms: number;
  processed_on: "edge" | "cloud";
  created_at: string;
  validation_status?: "pending" | "confirmed" | "rejected";
}

export interface AIDetectionStats {
  total_detections: number;
  by_detection_type: Record<string, number>;
  average_confidence: number;
  recent_detections: number;
}

/**
 * Fetch AI detections by room ID
 */
export async function fetchAIDetectionsByRoom(
  roomId: string,
  limit = 50
): Promise<AIDetection[]> {
  try {
    const response = await api.get<AIDetection[]>(
      `/ai-detections?room_id=${roomId}&limit=${limit}`
    );

    if (response.error) {
      console.error("❌ Failed to fetch AI detections:", response.error);
      return [];
    }

    return response.data || [];
  } catch (error) {
    console.error("❌ Error fetching AI detections:", error);
    return [];
  }
}

/**
 * Fetch AI detections by session ID
 */
export async function fetchAIDetectionsBySession(
  sessionId: string,
  limit = 100
): Promise<AIDetection[]> {
  try {
    const response = await api.get<AIDetection[]>(
      `/ai-detections?session_id=${sessionId}&limit=${limit}`
    );

    if (response.error) {
      console.error("❌ Failed to fetch AI detections:", response.error);
      return [];
    }

    return response.data || [];
  } catch (error) {
    console.error("❌ Error fetching AI detections:", error);
    return [];
  }
}

/**
 * Fetch AI detection statistics for a room or session
 */
export async function fetchAIDetectionStats(
  roomId?: string,
  sessionId?: string
): Promise<AIDetectionStats | null> {
  try {
    const params = new URLSearchParams();
    if (roomId) params.append("room_id", roomId);
    if (sessionId) params.append("session_id", sessionId);

    const response = await api.get<AIDetectionStats>(
      `/ai-detections/stats?${params.toString()}`
    );

    if (response.error || !response.data) {
      return null;
    }

    return response.data;
  } catch (error) {
    console.error("❌ Error fetching AI detection stats:", error);
    return null;
  }
}

/**
 * Subscribe to real-time AI detections via Supabase Realtime
 */
export function subscribeToAIDetections(
  roomId: string,
  onDetection: (detection: AIDetection) => void,
  onDelete?: (detectionId: string) => void
): () => void {
  // TODO: Implement Supabase Realtime subscription
  // For now, use polling as fallback
  console.log("📡 Setting up AI detection subscription for room:", roomId);

  let lastSeenId: string | null = null;

  const pollInterval = setInterval(async () => {
    const detections = await fetchAIDetectionsByRoom(roomId, 1);
    if (detections.length > 0) {
      const latestDetection = detections[0];
      // Only notify if this is a new detection (different ID)
      if (latestDetection.id !== lastSeenId) {
        console.log(`🆕 New detection found: ${latestDetection.id} (previous: ${lastSeenId})`);
        lastSeenId = latestDetection.id;
        onDetection(latestDetection);
      }
    }
  }, 2000); // Poll every 2 seconds

  return () => {
    clearInterval(pollInterval);
  };
}
/**
 * Update validation status for an AI detection
 */
export async function updateAIDetectionValidationStatus(
  detectionId: string | number,
  validationStatus: "pending" | "confirmed" | "rejected"
) {
  try {
    const response = await api.patch(
      `/ai-detections/${detectionId}/validation?validation_status=${validationStatus}`
    );

    if (response.error) {
      console.error("❌ Failed to update AI detection validation:", response.error);
      return { success: false, data: null, error: response.error };
    }

    console.log(`✅ Updated AI detection ${detectionId} to ${validationStatus}`);
    return { success: true, data: response.data, error: null };
  } catch (error) {
    console.error("❌ Error updating AI detection validation:", error);
    return {
      success: false,
      data: null,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}
export const aiDetectionService = {
  fetchByRoom: fetchAIDetectionsByRoom,
  fetchBySession: fetchAIDetectionsBySession,
  fetchStats: fetchAIDetectionStats,
  subscribe: subscribeToAIDetections,
  updateValidationStatus: updateAIDetectionValidationStatus,
};
