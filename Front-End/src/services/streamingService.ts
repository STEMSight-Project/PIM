import type { ApiResponse } from "@/types";
import { api } from "./api";

// Streaming Types - Updated to match backend streaming.py
export interface RoomInfo {
  room_id: string;
  session_id?: string;
  created?: boolean;
  reconnected?: boolean;
  already_exists?: boolean;
}

export interface SDPData {
  sdp: string;
  type: "offer" | "answer" | "pranswer" | "rollback";
}

export interface StreamResponse {
  sdp: string;
  type: "offer" | "answer" | "pranswer" | "rollback";
}

// Streaming Session Types - Updated to match backend streaming.py
export interface StreamingSession {
  id: string;
  patient_id: string;
  room_id: string;
  device_name?: string;
  is_live: boolean;
  status: "active" | "ended" | "error" | "disconnected";
  started_at: string;
  ended_at?: string;
  created_at: string;
  updated_at: string;
}

export interface StreamingSessionCreate {
  patient_id: string;
  room_id: string;
  device_name?: string;
}

export interface StreamingSessionUpdate {
  is_live?: boolean;
  status?: "active" | "ended" | "error" | "disconnected";
  device_name?: string;
}

// Legacy types for backward compatibility (deprecated)
export interface StreamSession {
  id: string;
  patient_id: string;
  doctor_id?: string;
  room_id: string;
  status: "active" | "inactive" | "ended" | "error";
  stream_url?: string;
  started_at: string;
  ended_at?: string;
  duration_seconds?: number;
  quality: "low" | "medium" | "high" | "ultra";
  resolution?: string;
  frame_rate?: number;
  created_at: string;
  updated_at: string;
}

export interface StreamCreateRequest {
  patient_id: string;
  doctor_id?: string;
  room_id: string;
  quality?: "low" | "medium" | "high" | "ultra";
  resolution?: string;
  frame_rate?: number;
}

export interface StreamUpdateRequest {
  status?: "active" | "inactive" | "ended" | "error";
  quality?: "low" | "medium" | "high" | "ultra";
  resolution?: string;
  frame_rate?: number;
}

export interface StreamStats {
  session_id: string;
  bitrate: number;
  packet_loss: number;
  latency_ms: number;
  frames_per_second: number;
  bandwidth_usage: number;
  timestamp: string;
}

// Streaming Service Functions - Updated to match backend endpoints
export const streamingService = {
  // Room Management - Matches backend streaming.py
  async createRoom(
    patientId: string,
    deviceName?: string
  ): Promise<ApiResponse<RoomInfo>> {
    const params = deviceName
      ? `?device_name=${encodeURIComponent(deviceName)}`
      : "";
    return api.post<RoomInfo>(`/streaming/create_room/${patientId}${params}`);
  },

  // WebRTC Signaling - Matches backend streaming.py
  async publishStreamer(
    patientId: string,
    sdpData: SDPData
  ): Promise<ApiResponse<StreamResponse>> {
    return api.post<StreamResponse>(
      `/streaming/rooms/${patientId}/streamer`,
      sdpData
    );
  },

  async publishViewer(
    patientId: string,
    sdpData: SDPData
  ): Promise<ApiResponse<StreamResponse>> {
    return api.post<StreamResponse>(
      `/streaming/rooms/${patientId}/viewer`,
      sdpData
    );
  },

  // Streaming Sessions CRUD - Matches backend streaming.py
  async createSession(
    sessionData: StreamingSessionCreate
  ): Promise<ApiResponse<StreamingSession>> {
    return api.post<StreamingSession>("/streaming/sessions", sessionData);
  },

  async getSessions(filters?: {
    patient_id?: string;
    is_live?: boolean;
  }): Promise<ApiResponse<StreamingSession[]>> {
    const params = new URLSearchParams();
    if (filters?.patient_id) params.append("patient_id", filters.patient_id);
    if (filters?.is_live !== undefined)
      params.append("is_live", filters.is_live.toString());

    const queryString = params.toString();
    const endpoint = queryString
      ? `/streaming/sessions?${queryString}`
      : "/streaming/sessions";

    return api.get<StreamingSession[]>(endpoint);
  },

  async getSession(sessionId: string): Promise<ApiResponse<StreamingSession>> {
    return api.get<StreamingSession>(`/streaming/sessions/${sessionId}`);
  },

  async updateSession(
    sessionId: string,
    updateData: StreamingSessionUpdate
  ): Promise<ApiResponse<StreamingSession>> {
    return api.put<StreamingSession>(
      `/streaming/sessions/${sessionId}`,
      updateData
    );
  },

  async endSession(sessionId: string): Promise<ApiResponse<StreamingSession>> {
    return api.post<StreamingSession>(`/streaming/sessions/${sessionId}/end`);
  },

  async getActiveSessionsForPatient(
    patientId: string
  ): Promise<ApiResponse<StreamingSession[]>> {
    return api.get<StreamingSession[]>(
      `/streaming/sessions/patient/${patientId}/active`
    );
  },

  // Legacy methods for backward compatibility (deprecated - use new session methods above)
  async getAllSessions(): Promise<ApiResponse<StreamSession[]>> {
    console.warn("getAllSessions is deprecated. Use getSessions() instead.");
    const response = await this.getSessions();
    // Transform new format to legacy format for compatibility
    if (response.data) {
      const legacyData: StreamSession[] = response.data.map((session) => ({
        ...session,
        doctor_id: undefined,
        status:
          session.status === "active"
            ? ("active" as const)
            : ("ended" as const),
        stream_url: undefined,
        duration_seconds: undefined,
        quality: "medium" as const,
        resolution: undefined,
        frame_rate: undefined,
      }));
      return { data: legacyData, error: response.error };
    }
    return { data: null, error: response.error };
  },

  async getSessionsByPatient(
    patientId: string
  ): Promise<ApiResponse<StreamSession[]>> {
    console.warn(
      "getSessionsByPatient is deprecated. Use getSessions({ patient_id }) instead."
    );
    const response = await this.getSessions({ patient_id: patientId });
    // Transform new format to legacy format for compatibility
    if (response.data) {
      const legacyData: StreamSession[] = response.data.map((session) => ({
        ...session,
        doctor_id: undefined,
        status:
          session.status === "active"
            ? ("active" as const)
            : ("ended" as const),
        stream_url: undefined,
        duration_seconds: undefined,
        quality: "medium" as const,
        resolution: undefined,
        frame_rate: undefined,
      }));
      return { data: legacyData, error: response.error };
    }
    return { data: null, error: response.error };
  },
};
