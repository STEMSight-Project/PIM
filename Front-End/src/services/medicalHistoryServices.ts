import { api } from "@/services/api";

interface MedicalHistory {
  id: string;
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  note?: string;
  created_at: Date;
  updated_at: Date;
}

export const getAllMedicalHistories = async (): Promise<MedicalHistory[]> => {
  const medicalHistories = await api.get<MedicalHistory[]>("/medical_history/");
  return medicalHistories;
};

export const getMedicalHistoryById = async (
  medicalHistoryId: string
): Promise<MedicalHistory> => {
  const medicalHistory = await api.get<MedicalHistory>(
    `/medical_history/${medicalHistoryId}`
  );
  return medicalHistory;
};

export const createMedicalHistory = async (
  medicalHistory: Omit<MedicalHistory, "id" | "created_at" | "updated_at">
): Promise<MedicalHistory> => {
  const newMedicalHistory = await api.post<MedicalHistory>(
    "/medical_history/",
    medicalHistory
  );
  return newMedicalHistory;
};

export const updateMedicalHistory = async (
  medicalHistoryId: string,
  medicalHistory: Partial<
    Omit<
      MedicalHistory,
      "id" | "created_at" | "updated_at" | "patient_id" | "doctor_id"
    >
  >
): Promise<MedicalHistory> => {
  const updatedMedicalHistory = await api.patch<MedicalHistory>(
    `/medical_history/${medicalHistoryId}/`,
    medicalHistory
  );
  return updatedMedicalHistory;
};

export const deleteMedicalHistory = async (
  medicalHistoryId: string
): Promise<void> => {
  await api.delete(`/medical_history/${medicalHistoryId}/`);
};
