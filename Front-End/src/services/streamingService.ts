import type { ApiResponse } from "@/types";
import { api } from "./api";

// Streaming Types - Updated to match backend streaming.py
export interface RoomInfo {
  room_id: string;
}

export interface SDPData {
  sdp: string;
  type: string;
}

export interface StreamResponse {
  sdp: string;
  type: string;
}

// Legacy types for backward compatibility
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
  async createRoom(patientId: string): Promise<ApiResponse<RoomInfo>> {
    return api.post<RoomInfo>(`/streaming/create_room/${patientId}`);
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

  // Legacy methods for backward compatibility (not implemented in backend)
  async createSession(): Promise<ApiResponse<StreamSession>> {
    // This could be implemented later or throw not implemented error
    throw new Error(
      "Legacy streaming sessions not implemented in current backend"
    );
  },

  async getSession(): Promise<ApiResponse<StreamSession>> {
    throw new Error(
      "Legacy streaming sessions not implemented in current backend"
    );
  },

  async getAllSessions(): Promise<ApiResponse<StreamSession[]>> {
    throw new Error(
      "Legacy streaming sessions not implemented in current backend"
    );
  },

  async getSessionsByPatient(): Promise<ApiResponse<StreamSession[]>> {
    throw new Error(
      "Legacy streaming sessions not implemented in current backend"
    );
  },
};
