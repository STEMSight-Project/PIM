import type { ApiResponse } from "@/types";
import { api } from "./api";

// Doctor Types
export interface Doctor {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  specialization?: string;
  phone?: string;
  license_number?: string;
  created_at: string;
  updated_at: string;
}

export interface DoctorCreateRequest {
  first_name: string;
  last_name: string;
  email: string;
  specialization?: string;
  phone?: string;
  license_number?: string;
}

export interface DoctorUpdateRequest extends Partial<DoctorCreateRequest> {}

// Doctor Service Functions
export const doctorService = {
  // CRUD Operations
  async getAll(): Promise<ApiResponse<Doctor[]>> {
    return api.get<Doctor[]>("/doctors/");
  },

  async getById(id: string): Promise<ApiResponse<Doctor>> {
    return api.get<Doctor>(`/doctors/${id}`);
  },

  async create(data: DoctorCreateRequest): Promise<ApiResponse<Doctor>> {
    return api.post<Doctor>("/doctors/", data);
  },

  async update(
    id: string,
    data: DoctorUpdateRequest
  ): Promise<ApiResponse<Doctor>> {
    return api.patch<Doctor>(`/doctors/${id}`, data);
  },

  async delete(id: string): Promise<ApiResponse<void>> {
    return api.delete<void>(`/doctors/${id}`);
  },

  // Utility Functions
  getFullName(doctor: Doctor): string {
    return `${doctor.first_name} ${doctor.last_name}`;
  },

  getDisplayName(doctor: Doctor): string {
    const name = this.getFullName(doctor);
    return doctor.specialization
      ? `Dr. ${name} (${doctor.specialization})`
      : `Dr. ${name}`;
  },
};
