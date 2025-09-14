import type { ApiResponse } from "@/types";
import { api } from "./api";

// Patient Types - Updated to match existing @/types
export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: "male" | "female" | "other";
  email?: string;
  phone?: string;
  address?: string;
  emergency_contact?: string;
  created_at: string;
  updated_at: string;
}

export interface PatientCreateRequest {
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: "male" | "female" | "other";
  email?: string;
  phone?: string;
  address?: string;
  emergency_contact?: string;
}

export interface PatientUpdateRequest extends Partial<PatientCreateRequest> {}

// Patient Service Functions
export const patientService = {
  // CRUD Operations
  async getAll(): Promise<ApiResponse<Patient[]>> {
    return api.get<Patient[]>("/patients/");
  },

  async getById(id: string): Promise<ApiResponse<Patient>> {
    return api.get<Patient>(`/patients/${id}`);
  },

  async create(data: PatientCreateRequest): Promise<ApiResponse<Patient>> {
    return api.post<Patient>("/patients/", data);
  },

  async update(
    id: string,
    data: PatientUpdateRequest
  ): Promise<ApiResponse<Patient>> {
    return api.patch<Patient>(`/patients/${id}`, data);
  },

  async delete(id: string): Promise<ApiResponse<void>> {
    return api.delete<void>(`/patients/${id}`);
  },

  // Utility Functions
  getFullName(patient: Patient): string {
    return `${patient.first_name} ${patient.last_name}`;
  },

  formatPatientDisplay(patient: Patient): string {
    return `${this.getFullName(patient)} (DOB: ${new Date(
      patient.date_of_birth
    ).toLocaleDateString()})`;
  },
};
