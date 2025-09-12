import { api } from "./api";
import type { Doctor } from "@/types";

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

interface CreateDoctorRequest {
  first_name: string;
  middle_name?: string;
  last_name: string;
  specialization: Specialization;
  email: string;
  primary_phone: string;
}

interface UpdateDoctorRequest {
  first_name?: string;
  middle_name?: string;
  last_name?: string;
  specialization?: Specialization;
  email?: string;
  primary_phone?: string;
}

export const getAllDoctors = async (): Promise<Doctor[]> => {
  const response = await api.get<Doctor[]>("/doctors/");
  return response.data || [];
};

export const getDoctorById = async (
  doctorId: string
): Promise<Doctor | null> => {
  const response = await api.get<Doctor>(`/doctors/${doctorId}`);
  return response.data;
};

export const createDoctor = async (
  doctor: CreateDoctorRequest
): Promise<Doctor | null> => {
  const response = await api.post<Doctor>("/doctors/", doctor);
  return response.data;
};

export const updateDoctor = async (
  doctorId: string,
  doctor: Partial<UpdateDoctorRequest>
): Promise<Doctor | null> => {
  const response = await api.patch<Doctor>(`/doctors/${doctorId}/`, doctor);
  return response.data;
};

export const deleteDoctor = async (doctorId: string): Promise<boolean> => {
  const response = await api.delete(`/doctors/${doctorId}/`);
  return !response.error;
};
