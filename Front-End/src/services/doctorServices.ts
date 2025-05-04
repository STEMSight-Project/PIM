import { api } from "./api";

export enum Specialization {
  GENERAL_PRACTICE = "General Practice/Family Medicine",
  INTERNAL_MEDICINE = "Internal Medicine",
  CARDIOLOGY = "Cardiology",
  DERMATOLOGY = "Dermatology",
  ENDOCRINOLOGY = "Endocrinology",
  GASTROENTEROLOGY = "Gastroenterology",
  NEUROLOGY = "Neurology",
  OBSTETRICS_GYNECOLOGY = "Obstetrics & Gynecology",
  ONCOLOGY = "Oncology",
  ORTHOPEDICS = "Orthopedics",
  PEDIATRICS = "Pediatrics",
  PSYCHIATRY = "Psychiatry",
  RADIOLOGY = "Radiology",
  UROLOGY = "Urology",
}

interface Doctor {
  id: string;
  first_name: string;
  middle_name?: string;
  last_name: string;
  specialization: Specialization;
  email: string;
  primary_phone: string;
  created_at: Date;
  updated_at: Date;
}

export const getAllDoctors = async (): Promise<Doctor[]> => {
  const doctors = await api.get<Doctor[]>("/doctors/");
  return doctors;
};

export const getDoctorById = async (doctorId: string): Promise<Doctor> => {
  const doctor = await api.get<Doctor>(`/doctors/${doctorId}`);
  return doctor;
};

interface CreateDoctorRequest {
  first_name: string;
  middle_name?: string;
  last_name: string;
  specialization: Specialization;
  email: string;
  primary_phone: string;
}

export const createDoctor = async (
  doctor: CreateDoctorRequest
): Promise<Doctor> => {
  const newDoctor = await api.post<Doctor>("/doctors/", doctor);
  return newDoctor;
};

interface UpdateDoctorRequest {
  first_name?: string;
  middle_name?: string;
  last_name?: string;
  specialization?: Specialization;
  email?: string;
  primary_phone?: string;
}

export const updateDoctor = async (
  doctorId: string,
  doctor: Partial<UpdateDoctorRequest>
): Promise<Doctor> => {
  const updatedDoctor = await api.patch<Doctor>(
    `/doctors/${doctorId}/`,
    doctor
  );
  return updatedDoctor;
};
