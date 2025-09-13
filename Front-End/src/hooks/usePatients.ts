"use client";

import { api } from "@/services/api";
import type {
  Patient,
  PatientCreateRequest,
  PatientUpdateRequest,
} from "@/types";
import { useEffect, useState } from "react";

export function usePatients() {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPatients = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const { data, error } = await api.get<Patient[]>("/patients/");

      if (error) {
        throw new Error(error);
      }

      setPatients(data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch patients";
      setError(errorMessage);
      console.error("Error fetching patients:", err);
    } finally {
      setIsLoading(false);
    }
  };

  const createPatient = async (patientData: PatientCreateRequest) => {
    try {
      const { data, error } = await api.post<Patient>(
        "/patients/",
        patientData
      );

      if (error) {
        throw new Error(error);
      }

      if (data) {
        setPatients((prev) => [...prev, data]);
      }

      return { success: true, data };
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to create patient";
      return { success: false, error: errorMessage };
    }
  };

  const updatePatient = async (
    patientId: string,
    patientData: PatientUpdateRequest
  ) => {
    try {
      const { data, error } = await api.patch<Patient>(
        `/patients/${patientId}`,
        patientData
      );

      if (error) {
        throw new Error(error);
      }

      if (data) {
        setPatients((prev) => prev.map((p) => (p.id === patientId ? data : p)));
      }

      return { success: true, data };
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to update patient";
      return { success: false, error: errorMessage };
    }
  };

  const deletePatient = async (patientId: string) => {
    try {
      const { error } = await api.delete(`/patients/${patientId}`);

      if (error) {
        throw new Error(error);
      }

      setPatients((prev) => prev.filter((p) => p.id !== patientId));
      return { success: true };
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to delete patient";
      return { success: false, error: errorMessage };
    }
  };

  const getPatient = async (patientId: string) => {
    try {
      const { data, error } = await api.get<Patient>(`/patients/${patientId}`);
      console.log("Authorization header:", {
        Authorization: `Bearer ${localStorage.getItem("access_token")}`,
      });
      if (error) {
        throw new Error(error);
      }

      return { success: true, data };
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch patient";
      return { success: false, error: errorMessage };
    }
  };

  useEffect(() => {
    fetchPatients();
  }, []);

  return {
    patients,
    isLoading,
    error,
    fetchPatients,
    createPatient,
    updatePatient,
    deletePatient,
    getPatient,
    refreshPatients: fetchPatients,
  };
}
