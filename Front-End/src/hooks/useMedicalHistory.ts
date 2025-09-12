"use client";

import { useState, useCallback } from "react";
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

interface UseMedicalHistoryReturn {
  medicalHistories: MedicalHistory[];
  selectedHistory: MedicalHistory | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchMedicalHistories: () => Promise<void>;
  fetchMedicalHistoryById: (id: string) => Promise<void>;
  fetchMedicalHistoriesByPatient: (patientId: string) => Promise<void>;
  createMedicalHistory: (
    data: CreateMedicalHistoryRequest
  ) => Promise<MedicalHistory | null>;
  updateMedicalHistory: (
    id: string,
    data: UpdateMedicalHistoryRequest
  ) => Promise<MedicalHistory | null>;
  deleteMedicalHistory: (id: string) => Promise<boolean>;
  clearError: () => void;
  setSelectedHistory: (history: MedicalHistory | null) => void;
}

export function useMedicalHistory(): UseMedicalHistoryReturn {
  const [medicalHistories, setMedicalHistories] = useState<MedicalHistory[]>(
    []
  );
  const [selectedHistory, setSelectedHistory] = useState<MedicalHistory | null>(
    null
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const fetchMedicalHistories = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<MedicalHistory[]>("/medical_history/");
      setMedicalHistories(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "Failed to fetch medical histories";
      setError(message);
      console.error("Error fetching medical histories:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchMedicalHistoryById = useCallback(async (id: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<MedicalHistory>(`/medical_history/${id}`);
      if (response.data) {
        setSelectedHistory(response.data);
      } else {
        setError("Medical history not found");
      }
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch medical history";
      setError(message);
      console.error("Error fetching medical history:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchMedicalHistoriesByPatient = useCallback(
    async (patientId: string) => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get<MedicalHistory[]>(
          `/medical_history/patient/${patientId}/`
        );
        setMedicalHistories(response.data || []);
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "Failed to fetch patient medical histories";
        setError(message);
        console.error("Error fetching patient medical histories:", err);
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const createMedicalHistory = useCallback(
    async (
      data: CreateMedicalHistoryRequest
    ): Promise<MedicalHistory | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.post<MedicalHistory>(
          "/medical_history/",
          data
        );
        if (response.data) {
          setMedicalHistories((prev) => [...prev, response.data!]);
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "Failed to create medical history";
        setError(message);
        console.error("Error creating medical history:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const updateMedicalHistory = useCallback(
    async (
      id: string,
      data: UpdateMedicalHistoryRequest
    ): Promise<MedicalHistory | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.patch<MedicalHistory>(
          `/medical_history/${id}/`,
          data
        );
        if (response.data) {
          setMedicalHistories((prev) =>
            prev.map((history) =>
              history.id === id ? response.data! : history
            )
          );
          if (selectedHistory?.id === id) {
            setSelectedHistory(response.data);
          }
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "Failed to update medical history";
        setError(message);
        console.error("Error updating medical history:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [selectedHistory]
  );

  const deleteMedicalHistory = useCallback(
    async (id: string): Promise<boolean> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.delete(`/medical_history/${id}/`);
        if (!response.error) {
          setMedicalHistories((prev) =>
            prev.filter((history) => history.id !== id)
          );
          if (selectedHistory?.id === id) {
            setSelectedHistory(null);
          }
          return true;
        }
        return false;
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "Failed to delete medical history";
        setError(message);
        console.error("Error deleting medical history:", err);
        return false;
      } finally {
        setLoading(false);
      }
    },
    [selectedHistory]
  );

  return {
    medicalHistories,
    selectedHistory,
    loading,
    error,
    fetchMedicalHistories,
    fetchMedicalHistoryById,
    fetchMedicalHistoriesByPatient,
    createMedicalHistory,
    updateMedicalHistory,
    deleteMedicalHistory,
    clearError,
    setSelectedHistory,
  };
}
