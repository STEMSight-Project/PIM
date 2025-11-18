import type {
  AmbulanceCamera,
  AmbulanceSession,
  AmbulanceSessionCreate,
  AmbulanceSessionUpdate,
  AmbulanceStreamingStatus,
  ApiResponse,
  CameraRoom,
  CameraRoomCreate,
  SDPData,
  StreamResponse,
} from "@/types";
import { api } from "./api";
import getApiBaseUrl from "@/lib/apiBase";

/**
 * AMBULANCE STREAMING SERVICE
 *
 * Handles live streaming operations for ambulance emergency response:
 * - WebRTC signaling (SDP exchange) for camera feeds
 * - Ambulance session management
 * - Camera room management for multi-camera support
 * - Real-time emergency response streaming
 *
 * Use this service for:
 * - Managing ambulance streaming sessions
 * - Connecting to ambulance camera feeds
 * - Monitoring emergency response activities
 * - Real-time dashboard operations
 *
 * Updated to match backend ambulance_streaming.py API (September 2025)
 */

// ============================================================================
// AMBULANCE STREAMING SERVICE
// ============================================================================

export const ambulanceStreamingService = {
  // ============================================================================
  // AMBULANCE MANAGEMENT
  // ============================================================================

  /**
   * Get streaming status for all ambulances with active sessions
   */
  async getAmbulancesStreamingStatus(): Promise<
    ApiResponse<AmbulanceStreamingStatus[]>
  > {
    return api.get<AmbulanceStreamingStatus[]>(
      "/ambulance-streaming/ambulances/status"
    );
  },

  /**
   * Get cameras assigned to a specific ambulance
   */
  async getAmbulanceCameras(
    ambulanceId: string
  ): Promise<ApiResponse<AmbulanceCamera[]>> {
    return api.get<AmbulanceCamera[]>(
      `/ambulance-streaming/ambulances/${ambulanceId}/cameras`
    );
  },

  // ============================================================================
  // AMBULANCE SESSION MANAGEMENT
  // ============================================================================

  /**
   * Get all ambulance streaming sessions
   */
  async getAmbulanceSessions(filters?: {
    ambulance_id?: string;
    session_type?: string;
    is_active?: boolean;
    limit?: number;
  }): Promise<ApiResponse<AmbulanceSession[]>> {
    const params = new URLSearchParams();
    if (filters?.ambulance_id)
      params.append("ambulance_id", filters.ambulance_id);
    if (filters?.session_type)
      params.append("session_type", filters.session_type);
    if (filters?.is_active !== undefined)
      params.append("is_active", filters.is_active.toString());
    if (filters?.limit) {
      params.append("limit", filters.limit.toString());
    } else {
      params.append("limit", "100"); // Default limit
    }

    const queryString = params.toString();
    const endpoint = queryString
      ? `/ambulance-streaming/ambulance-sessions?${queryString}`
      : "/ambulance-streaming/ambulance-sessions";

    return api.get<AmbulanceSession[]>(endpoint);
  },

  /**
   * Create a new ambulance streaming session
   */
  async createAmbulanceSession(
    sessionData: AmbulanceSessionCreate
  ): Promise<ApiResponse<AmbulanceSession>> {
    return api.post<AmbulanceSession>(
      "/ambulance-streaming/ambulance-sessions",
      sessionData
    );
  },

  /**
   * Update an existing ambulance session
   */
  async updateAmbulanceSession(
    sessionId: string,
    updateData: AmbulanceSessionUpdate
  ): Promise<ApiResponse<AmbulanceSession>> {
    return api.put<AmbulanceSession>(
      `/ambulance-streaming/ambulance-sessions/${sessionId}`,
      updateData
    );
  },

  /**
   * End an ambulance streaming session
   */
  async endAmbulanceSession(
    sessionId: string
  ): Promise<ApiResponse<AmbulanceSession>> {
    return api.post<AmbulanceSession>(
      `/ambulance-streaming/ambulance-sessions/${sessionId}/end`
    );
  },

  // ============================================================================
  // CAMERA ROOM MANAGEMENT
  // ============================================================================

  /**
   * Create a camera streaming room within a session
   */
  async createCameraRoom(
    sessionId: string,
    roomData: CameraRoomCreate
  ): Promise<ApiResponse<CameraRoom>> {
    const params = new URLSearchParams();
    params.append("session_id", sessionId);

    return api.post<CameraRoom>(
      `/ambulance-streaming/camera-rooms?${params.toString()}`,
      roomData
    );
  },

  /**
   * Get all camera rooms with optional filters
   */
  async getCameraRooms(filters?: {
    session_id?: string;
    connected?: boolean;
    limit?: number;
  }): Promise<ApiResponse<CameraRoom[]>> {
    const params = new URLSearchParams();
    if (filters?.session_id) params.append("session_id", filters.session_id);
    if (filters?.connected !== undefined)
      params.append("connected", filters.connected.toString());
    if (filters?.limit) params.append("limit", filters.limit.toString());

    const queryString = params.toString();
    const endpoint = queryString
      ? `/ambulance-streaming/camera-rooms?${queryString}`
      : "/ambulance-streaming/camera-rooms";

    return api.get<CameraRoom[]>(endpoint);
  },

  /**
   * Get camera room details by room ID
   */
  async getCameraRoom(roomId: string): Promise<ApiResponse<CameraRoom>> {
    return api.get<CameraRoom>(`/ambulance-streaming/camera-rooms/${roomId}`);
  },

  /**
   * Disconnect a camera room
   */
  async disconnectCameraRoom(roomId: string): Promise<ApiResponse<CameraRoom>> {
    return api.put<CameraRoom>(
      `/ambulance-streaming/camera-rooms/${roomId}/disconnect`
    );
  },

  // ============================================================================
  // WEBRTC STREAMING
  // ============================================================================

  /**
   * Connect as a camera streamer (for Raspberry Pi devices)
   *
   * @param cameraId - Actually the room_id (e.g., "AMB-001-ROOM-001")
   *                   In our system, room_id IS the camera identifier
   */
  async connectCameraStreamer(
    cameraId: string,
    sdpData: SDPData
  ): Promise<ApiResponse<StreamResponse>> {
    return api.post<StreamResponse>(
      `/ambulance-streaming/camera/${cameraId}/streamer`,
      sdpData
    );
  },

  /**
   * Connect as a camera viewer (for dashboard monitoring)
   *
   * @param cameraId - Actually the room_id (e.g., "AMB-001-ROOM-001")
   *                   In our system, room_id IS the camera identifier
   */
  async connectCameraViewer(
    cameraId: string,
    sdpData: SDPData
  ): Promise<ApiResponse<StreamResponse>> {
    return api.post<StreamResponse>(
      `/ambulance-streaming/camera/${cameraId}/viewer`,
      sdpData
    );
  },

  // ============================================================================
  // REAL-TIME MONITORING
  // ============================================================================

  /**
   * Get real-time ambulance sessions stream (Server-Sent Events)
   */
  getRealtimeAmbulanceSessions(): EventSource {
    const baseURL = getApiBaseUrl();
    return new EventSource(`${baseURL}/realtime/ambulance-sessions`);
  },

  /**
   * Get real-time camera rooms stream (Server-Sent Events)
   */
  getRealtimeCameraRooms(): EventSource {
    const baseURL = getApiBaseUrl();
    return new EventSource(`${baseURL}/realtime/camera-rooms`);
  },

  // ============================================================================
  // MAINTENANCE
  // ============================================================================

  /**
   * Cleanup inactive camera rooms
   */
  async cleanupInactiveRooms(
    thresholdMinutes: number = 30
  ): Promise<ApiResponse<{ cleaned_rooms: number }>> {
    const params = new URLSearchParams();
    params.append("threshold_minutes", thresholdMinutes.toString());

    return api.post<{ cleaned_rooms: number }>(
      `/ambulance-streaming/maintenance/cleanup-inactive-rooms?${params.toString()}`
    );
  },

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /**
   * Check if an ambulance has any active streaming sessions
   */
  async hasActiveSession(ambulanceId: string): Promise<boolean> {
    try {
      const response = await this.getAmbulanceSessions({
        ambulance_id: ambulanceId,
        is_active: true,
      });
      return response.data ? response.data.length > 0 : false;
    } catch (error) {
      console.error("Error checking for active ambulance sessions:", error);
      return false;
    }
  },

  /**
   * Get active sessions for a specific ambulance
   */
  async getActiveSessionsForAmbulance(
    ambulanceId: string
  ): Promise<ApiResponse<AmbulanceSession[]>> {
    return this.getAmbulanceSessions({
      ambulance_id: ambulanceId,
      is_active: true,
    });
  },
};

// ============================================================================
// LEGACY COMPATIBILITY LAYER (DEPRECATED)
// ============================================================================

/**
 * @deprecated Use ambulanceStreamingService instead
 * Legacy streaming service maintained for backward compatibility
 * Will be removed in future versions
 */
export const streamingService = {
  /**
   * @deprecated Use ambulanceStreamingService.getAmbulanceSessions() instead
   */
  async getSessions(): Promise<ApiResponse<any[]>> {
    console.warn(
      "streamingService.getSessions() is deprecated. Use ambulanceStreamingService.getAmbulanceSessions() instead."
    );
    return ambulanceStreamingService.getAmbulanceSessions();
  },

  /**
   * @deprecated Use ambulanceStreamingService.createAmbulanceSession() instead
   */
  async createSession(sessionData: any): Promise<ApiResponse<any>> {
    console.warn(
      "streamingService.createSession() is deprecated. Use ambulanceStreamingService.createAmbulanceSession() instead."
    );
    return ambulanceStreamingService.createAmbulanceSession(sessionData);
  },
};

// Export the new ambulance streaming service as default
export default ambulanceStreamingService;
