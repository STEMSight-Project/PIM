import type { ApiResponse } from "@/types";
import { api } from "./api";

// Video Types - Updated to match backend video.py
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

// Video Service Functions - Updated to match backend endpoints
export const videoService = {
  // CRUD Operations
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

  // Note: Backend doesn't have individual video get, update, or other advanced operations
  // Keeping minimal interface that matches actual backend implementation
};
