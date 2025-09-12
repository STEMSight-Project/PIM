import { api } from "@/services/api";
import type { MedicalHistory } from "@/types";

interface CreateMedicalHistoryRequest {
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  note?: string;
}

interface UpdateMedicalHistoryRequest {
  diagnosis?: string;
  note?: string;
}

export const getAllMedicalHistories = async (): Promise<MedicalHistory[]> => {
  const response = await api.get<MedicalHistory[]>("/medical_history/");
  return response.data || [];
};

export const getMedicalHistoryById = async (
  medicalHistoryId: string
): Promise<MedicalHistory | null> => {
  const response = await api.get<MedicalHistory>(
    `/medical_history/${medicalHistoryId}`
  );
  return response.data;
};

export const createMedicalHistory = async (
  medicalHistory: CreateMedicalHistoryRequest
): Promise<MedicalHistory | null> => {
  const response = await api.post<MedicalHistory>(
    "/medical_history/",
    medicalHistory
  );
  return response.data;
};

export const updateMedicalHistory = async (
  medicalHistoryId: string,
  medicalHistory: UpdateMedicalHistoryRequest
): Promise<MedicalHistory | null> => {
  const response = await api.patch<MedicalHistory>(
    `/medical_history/${medicalHistoryId}/`,
    medicalHistory
  );
  return response.data;
};

export const deleteMedicalHistory = async (
  medicalHistoryId: string
): Promise<boolean> => {
  const response = await api.delete(`/medical_history/${medicalHistoryId}/`);
  return !response.error;
};
