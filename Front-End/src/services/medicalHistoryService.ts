import type { ApiResponse } from "@/types";
import { api } from "./api";

// Medical History Types - Updated to match backend medical_history.py
export interface MedicalHistory {
  id: string;
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  note?: string;
  created_at: string;
  updated_at: string;
}

export interface MedicalHistoryCreateRequest {
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  note?: string;
}

export interface MedicalHistoryUpdateRequest
  extends Partial<MedicalHistoryCreateRequest> {}

// Medical History Service Functions - Updated to match backend endpoints
export const medicalHistoryService = {
  // CRUD Operations
  async getAll(): Promise<ApiResponse<MedicalHistory[]>> {
    return api.get<MedicalHistory[]>("/medical-history/");
  },

  async getById(id: string): Promise<ApiResponse<MedicalHistory>> {
    return api.get<MedicalHistory>(`/medical-history/${id}`);
  },

  async getByPatientId(
    patientId: string
  ): Promise<ApiResponse<MedicalHistory[]>> {
    const response = await api.get<MedicalHistory[]>("/medical-history/");
    // Filter client-side since backend doesn't have patient-specific endpoint
    const filteredData = (response.data || []).filter(
      (history) => history.patient_id === patientId
    );
    return {
      ...response,
      data: filteredData,
    };
  },

  async create(
    data: MedicalHistoryCreateRequest
  ): Promise<ApiResponse<MedicalHistory>> {
    return api.post<MedicalHistory>("/medical-history/", data);
  },

  async update(
    id: string,
    data: MedicalHistoryUpdateRequest
  ): Promise<ApiResponse<MedicalHistory>> {
    return api.put<MedicalHistory>(`/medical-history/${id}`, data);
  },

  async delete(id: string): Promise<ApiResponse<{ message: string }>> {
    return api.delete<{ message: string }>(`/medical-history/${id}`);
  },

  // Utility Methods
  async updateNote(
    id: string,
    note: string
  ): Promise<ApiResponse<MedicalHistory[]>> {
    return api.patch<MedicalHistory[]>(
      `/medical-history/update_note/${id}?note=${encodeURIComponent(note)}`
    );
  },
};
