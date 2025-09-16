// Patient Management Types
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

// Medical History Types
export interface MedicalHistory {
  id: string;
  patient_id: string;
  condition: string;
  diagnosis_date: string;
  treatment: string;
  notes?: string;
  doctor_id?: string;
  created_at: string;
  updated_at: string;
}

export interface MedicalHistoryCreateRequest {
  patient_id: string;
  condition: string;
  diagnosis_date: string;
  treatment: string;
  notes?: string;
  doctor_id?: string;
}

export interface MedicalHistoryUpdateRequest
  extends Partial<Omit<MedicalHistoryCreateRequest, "patient_id">> {}

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
