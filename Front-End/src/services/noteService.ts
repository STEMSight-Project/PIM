import type { ApiResponse } from "@/types";
import { api } from "./api";

// Note Types - Updated to match existing hook types
export interface Note {
  id: string;
  created_at: string;
  content: string;
  patient_id: string;
  video_id?: string;
  author: string;
  timestamp_seconds?: number;
  updated_at?: string;
}

export interface NoteCreateRequest {
  content: string;
  patient_id: string;
  video_id?: string;
  author: string;
  timestamp_seconds?: number;
}

export interface NoteUpdateRequest {
  content?: string;
  author?: string;
  timestamp_seconds?: number;
}

// Note Service Functions - Updated to match backend endpoints
export const noteService = {
  // CRUD Operations matching backend note.py
  async getByPatientId(patientId: string): Promise<ApiResponse<Note[]>> {
    return api.get<Note[]>(`/note/patient/${patientId}`);
  },

  async getByVideoId(videoId: string): Promise<ApiResponse<Note[]>> {
    return api.get<Note[]>(`/note/video/${videoId}`);
  },

  async create(data: NoteCreateRequest): Promise<ApiResponse<Note>> {
    return api.post<Note>("/note/", data);
  },

  async update(
    id: string,
    data: NoteUpdateRequest
  ): Promise<ApiResponse<Note>> {
    return api.put<Note>(`/note/${id}`, data);
  },

  async delete(id: string): Promise<ApiResponse<{ message: string }>> {
    return api.delete<{ message: string }>(`/note/${id}`);
  },
};
