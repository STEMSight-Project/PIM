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

export type PatientUpdateRequest = Partial<PatientCreateRequest>;

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
    // Backend validation expects `dob` and `primary_phone` field names. Throws an error code 500 and 244 otherwise
    // Map our front-end shape (date_of_birth, phone) to the backend contract.
    const payload: any = {
      ...data,
      dob: data.date_of_birth,
      primary_phone: data.phone,
    };
    // Remove originals inputted values if backend does not accept them alongside mapped keys
    delete payload.date_of_birth;
    delete payload.phone;

    return api.post<Patient>("/patients/", payload);
  },

  async update(
    id: string,
    data: PatientUpdateRequest
  ): Promise<ApiResponse<Patient>> {
    // Map optional fields for update as well, and will do the same as was done with create (remove originals)
    const payload: any = { ...data };
    if (payload.date_of_birth !== undefined) {
      payload.dob = (payload as any).date_of_birth;
      delete payload.date_of_birth;
    }
    if (payload.phone !== undefined) {
      payload.primary_phone = (payload as any).phone;
      delete payload.phone;
    }

    return api.patch<Patient>(`/patients/${id}`, payload);
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
