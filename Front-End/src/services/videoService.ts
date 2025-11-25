import type { ApiResponse } from "@/types";
import { api } from "./api";

// ============================================================================
// LEGACY PATIENT VIDEO TYPES
// ============================================================================

export interface Video {
  id: string;
  patient_id: string;
  description?: string;
  file_path: string;
  public_video_url: string;
  created_at: string;
}

export interface VideoCreateRequest {
  patient_id: string;
  video_path: string;
  description?: string;
}

export interface VideoUpdateRequest {
  description?: string;
}

export interface VideoUploadResponse {
  id: string;
  patient_id: string;
  description?: string;
  file_path: string;
  public_video_url: string;
  created_at: string;
}

// ============================================================================
// AMBULANCE RECORDING TYPES (New)
// ============================================================================

export interface RecordingResponse {
  id: string;
  session_id: string;
  session_name?: string;
  ambulance_number?: string;
  camera_id?: string; // Camera identifier (e.g., "AMB-002-ROOM-001")
  recording_path?: string; // Local recording path
  file_path?: string;
  public_video_url?: string;
  duration?: number; // Duration in seconds
  file_size?: number; // File size in bytes
  session_start?: string;
  session_end?: string;
  created_at: string;
  is_archived: boolean; // True if uploaded to Supabase Storage
}

export interface SessionWithRecordings {
  session_id: string;
  session_name: string;
  ambulance_number: string;
  recordings: RecordingResponse[];
  total_duration: number;
  total_recordings: number;
}

// ============================================================================
// VIDEO SERVICE - LEGACY PATIENT VIDEOS
// ============================================================================

export const videoService = {
  // CRUD Operations for patient videos
  async getAll(): Promise<ApiResponse<Video[]>> {
    return api.get<Video[]>("/videos/");
  },

  async getByPatientId(patientId: string): Promise<ApiResponse<Video[]>> {
    return api.get<Video[]>(`/videos/${patientId}/videos`);
  },

  async create(data: VideoCreateRequest): Promise<ApiResponse<Video>> {
    return api.post<Video>("/videos/", data);
  },

  async delete(videoId: string): Promise<ApiResponse<{ message: string }>> {
    return api.delete<{ message: string }>(`/videos/${videoId}`);
  },
};

// ============================================================================
// RECORDING SERVICE - AMBULANCE SESSION RECORDINGS (New)
// ============================================================================

export const recordingService = {
  /**
   * Get all ambulance session recordings (both archived and live)
   */
  async getAllRecordings(): Promise<ApiResponse<RecordingResponse[]>> {
    return api.get<RecordingResponse[]>("/videos/recordings");
  },

  /**
   * Get only archived recordings (uploaded to Supabase Storage)
   * Excludes live/ongoing recordings
   */
  async getArchivedRecordings(): Promise<ApiResponse<RecordingResponse[]>> {
    return api.get<RecordingResponse[]>("/videos/recordings/archived");
  },

  /**
   * Get a specific recording by ID
   */
  async getRecordingById(
    recordingId: string
  ): Promise<ApiResponse<RecordingResponse>> {
    return api.get<RecordingResponse>(`/videos/recordings/${recordingId}`);
  },

  /**
   * Get all recordings for a specific ambulance session
   */
  async getRecordingsBySession(
    sessionId: string
  ): Promise<ApiResponse<RecordingResponse[]>> {
    return api.get<RecordingResponse[]>(
      `/videos/recordings/session/${sessionId}`
    );
  },

  /**
   * Get all recordings for a specific ambulance
   */
  async getRecordingsByAmbulance(
    ambulanceId: string
  ): Promise<ApiResponse<RecordingResponse[]>> {
    return api.get<RecordingResponse[]>(
      `/videos/recordings/ambulance/${ambulanceId}`
    );
  },

  /**
   * Delete a recording from the database
   * Note: This does NOT delete the file from Supabase Storage
   */
  async deleteRecording(
    recordingId: string
  ): Promise<ApiResponse<{ message: string }>> {
    return api.delete<{ message: string }>(`/videos/recordings/${recordingId}`);
  },

  /**
   * Group recordings by session
   * Helper function to organize recordings by session
   */
  async getSessionsWithRecordings(): Promise<
    ApiResponse<SessionWithRecordings[]>
  > {
    const response = await this.getArchivedRecordings();

    if (response.error || !response.data) {
      return {
        data: null,
        error: response.error || "Failed to fetch recordings",
      };
    }

    // Group recordings by session_id
    const sessionMap = new Map<string, RecordingResponse[]>();

    response.data.forEach((recording) => {
      const sessionId = recording.session_id;
      if (!sessionMap.has(sessionId)) {
        sessionMap.set(sessionId, []);
      }
      sessionMap.get(sessionId)!.push(recording);
    });

    // Convert to SessionWithRecordings array
    const sessions: SessionWithRecordings[] = Array.from(
      sessionMap.entries()
    ).map(([sessionId, recordings]) => {
      const totalDuration = recordings.reduce(
        (sum, rec) => sum + (rec.duration || 0),
        0
      );

      return {
        session_id: sessionId,
        session_name: recordings[0]?.session_name || "Unnamed Session",
        ambulance_number: recordings[0]?.ambulance_number || "Unknown",
        recordings,
        total_duration: totalDuration,
        total_recordings: recordings.length,
      };
    });

    // Sort by most recent first
    sessions.sort((a, b) => {
      const dateA = new Date(a.recordings[0]?.created_at || 0);
      const dateB = new Date(b.recordings[0]?.created_at || 0);
      return dateB.getTime() - dateA.getTime();
    });

    return {
      data: sessions,
      error: null,
    };
  },
};
