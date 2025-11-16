// services/movementDetectionService.ts
import type {
  CreateMovementDetection,
  MovementDetection,
  MovementDetectionResponse,
  MovementDetectionStats,
  MovementType,
  UpdateMovementDetection,
  UpdateValidationStatus,
  ValidationStatus,
} from "@/types/movementDetection";
import { api } from "./api";

class MovementDetectionService {
  private readonly baseUrl = "/api/movement-detections";

  /**
   * Create a new movement detection
   */
  async createDetection(
    data: CreateMovementDetection
  ): Promise<MovementDetectionResponse<MovementDetection>> {
    try {
      const response = await api.post<MovementDetection>(this.baseUrl, data);

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception creating detection:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Bulk create multiple detections
   */
  async bulkCreateDetections(
    detections: CreateMovementDetection[]
  ): Promise<MovementDetectionResponse<MovementDetection[]>> {
    try {
      const response = await api.post<MovementDetection[]>(
        `${this.baseUrl}/bulk`,
        { detections }
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception bulk creating detections:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get a single detection by ID
   */
  async getDetectionById(
    detectionId: number
  ): Promise<MovementDetectionResponse<MovementDetection>> {
    try {
      const response = await api.get<MovementDetection>(
        `${this.baseUrl}/${detectionId}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "Detection not found" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception fetching detection:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get all detections for a recording
   */
  async getDetectionsByRecording(
    recordingId: string
  ): Promise<MovementDetectionResponse<MovementDetection[]>> {
    try {
      // Fetch from AI detections endpoint instead of movement-detections
      const response = await api.get<any[]>(
        `/ai-detections?recording_id=${recordingId}&limit=500`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      // Filter out session_summary detections and convert to MovementDetection format
      const detections: MovementDetection[] = response.data
        .filter((ai: any) => 
          ai.detection_type !== 'session_summary' && 
          ai.detection_data?.pose_landmarks
        )
        .map((ai: any) => ({
          id: ai.id,
          recording_id: ai.recording_id || recordingId,
          camera_id: ai.camera_id,
          session_id: ai.session_id,
          timestamp: 0, // Will be calculated relative to recording start
          name: ai.detection_type || 'unknown',
          confidence: ai.confidence_score || 0,
          validation_status: 'confirmed' as ValidationStatus, // AI-confirmed detections
          created_at: ai.created_at,
          detection_data: ai.detection_data,
        }));

      console.log(`📊 Fetched ${detections.length} AI detections for recording ${recordingId}`);

      return { success: true, data: detections, error: null };
    } catch (err) {
      console.error("Exception fetching detections by recording:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get all detections for a room
   */
  async getDetectionsByRoom(
    roomId: string
  ): Promise<MovementDetectionResponse<MovementDetection[]>> {
    try {
      const response = await api.get<MovementDetection[]>(
        `${this.baseUrl}/room/${roomId}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception fetching detections by room:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get detections filtered by movement type
   */
  async getDetectionsByMovementType(
    movementType: MovementType
  ): Promise<MovementDetectionResponse<MovementDetection[]>> {
    try {
      const response = await api.get<MovementDetection[]>(
        `${this.baseUrl}/movement/${movementType}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception fetching detections by movement type:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get detections filtered by validation status
   */
  async getDetectionsByStatus(
    status: ValidationStatus,
    limit?: number
  ): Promise<MovementDetectionResponse<MovementDetection[]>> {
    try {
      const params = new URLSearchParams({ status });
      if (limit) {
        params.append("limit", limit.toString());
      }

      const response = await api.get<MovementDetection[]>(
        `${this.baseUrl}/status?${params.toString()}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception fetching detections by status:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get detection statistics
   */
  async getStatistics(
    roomId?: string,
    recordingId?: string
  ): Promise<MovementDetectionResponse<MovementDetectionStats>> {
    try {
      const params = new URLSearchParams();
      if (roomId) params.append("room_id", roomId);
      if (recordingId) params.append("recording_id", recordingId);

      const response = await api.get<MovementDetectionStats>(
        `${this.baseUrl}/statistics?${params.toString()}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception fetching statistics:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Update a detection
   */
  async updateDetection(
    detectionId: number,
    data: UpdateMovementDetection
  ): Promise<MovementDetectionResponse<MovementDetection>> {
    try {
      const response = await api.patch<MovementDetection>(
        `${this.baseUrl}/${detectionId}`,
        data
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception updating detection:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Update validation status only (quick validation)
   */
  async updateValidationStatus(
    detectionId: number,
    status: ValidationStatus
  ): Promise<MovementDetectionResponse<MovementDetection>> {
    try {
      const data: UpdateValidationStatus = { validation_status: status };
      const response = await api.patch<MovementDetection>(
        `${this.baseUrl}/${detectionId}/validation`,
        data
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception updating validation status:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Delete a detection
   */
  async deleteDetection(
    detectionId: number
  ): Promise<MovementDetectionResponse<void>> {
    try {
      await api.delete(`${this.baseUrl}/${detectionId}`);
      return { success: true, data: null, error: null };
    } catch (err) {
      console.error("Exception deleting detection:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Delete all detections for a recording
   */
  async deleteDetectionsByRecording(
    recordingId: string
  ): Promise<MovementDetectionResponse<{ deleted_count: number }>> {
    try {
      const response = await api.delete<{ deleted_count: number }>(
        `${this.baseUrl}/recording/${recordingId}`
      );

      if (!response.data) {
        return { success: false, data: null, error: "No data returned" };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error("Exception deleting detections by recording:", err);
      return {
        success: false,
        data: null,
        error: err instanceof Error ? err.message : "Unknown error",
      };
    }
  }

  /**
   * Get the realtime SSE endpoint URL
   */
  getRealtimeUrl(
    roomId?: string,
    recordingId?: string,
    validationStatus?: ValidationStatus
  ): string {
    const params = new URLSearchParams();
    if (roomId) params.append("room_id", roomId);
    if (recordingId) params.append("recording_id", recordingId);
    if (validationStatus) params.append("validation_status", validationStatus);

    const queryString = params.toString();
    return `${this.baseUrl}/realtime${queryString ? `?${queryString}` : ""}`;
  }
}

export const movementDetectionService = new MovementDetectionService();
export default movementDetectionService;
