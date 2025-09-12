"use client";

import { useState, useCallback, useEffect } from "react";
import { api } from "@/services/api";
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

interface UseDoctorsReturn {
  doctors: Doctor[];
  selectedDoctor: Doctor | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchDoctors: () => Promise<void>;
  fetchDoctor: (id: string) => Promise<void>;
  createDoctor: (data: CreateDoctorRequest) => Promise<Doctor | null>;
  updateDoctor: (
    id: string,
    data: UpdateDoctorRequest
  ) => Promise<Doctor | null>;
  deleteDoctor: (id: string) => Promise<boolean>;
  clearError: () => void;
  setSelectedDoctor: (doctor: Doctor | null) => void;
}

export function useDoctors(): UseDoctorsReturn {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [selectedDoctor, setSelectedDoctor] = useState<Doctor | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const fetchDoctors = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Doctor[]>("/doctors/");
      setDoctors(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch doctors";
      setError(message);
      console.error("Error fetching doctors:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchDoctor = useCallback(async (id: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Doctor>(`/doctors/${id}`);
      if (response.data) {
        setSelectedDoctor(response.data);
      } else {
        setError("Doctor not found");
      }
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch doctor";
      setError(message);
      console.error("Error fetching doctor:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const createDoctor = useCallback(
    async (data: CreateDoctorRequest): Promise<Doctor | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.post<Doctor>("/doctors/", data);
        if (response.data) {
          setDoctors((prev) => [...prev, response.data!]);
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to create doctor";
        setError(message);
        console.error("Error creating doctor:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const updateDoctor = useCallback(
    async (id: string, data: UpdateDoctorRequest): Promise<Doctor | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.patch<Doctor>(`/doctors/${id}/`, data);
        if (response.data) {
          setDoctors((prev) =>
            prev.map((doctor) => (doctor.id === id ? response.data! : doctor))
          );
          if (selectedDoctor?.id === id) {
            setSelectedDoctor(response.data);
          }
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to update doctor";
        setError(message);
        console.error("Error updating doctor:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [selectedDoctor]
  );

  const deleteDoctor = useCallback(
    async (id: string): Promise<boolean> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.delete(`/doctors/${id}/`);
        if (!response.error) {
          setDoctors((prev) => prev.filter((doctor) => doctor.id !== id));
          if (selectedDoctor?.id === id) {
            setSelectedDoctor(null);
          }
          return true;
        }
        return false;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to delete doctor";
        setError(message);
        console.error("Error deleting doctor:", err);
        return false;
      } finally {
        setLoading(false);
      }
    },
    [selectedDoctor]
  );

  return {
    doctors,
    selectedDoctor,
    loading,
    error,
    fetchDoctors,
    fetchDoctor,
    createDoctor,
    updateDoctor,
    deleteDoctor,
    clearError,
    setSelectedDoctor,
  };
}
