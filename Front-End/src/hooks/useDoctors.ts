"use client";

import type {
  Doctor,
  DoctorCreateRequest,
  DoctorUpdateRequest,
} from "@/services";
import { doctorService } from "@/services";
import { useCallback, useState } from "react";

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

interface UseDoctorsReturn {
  doctors: Doctor[];
  selectedDoctor: Doctor | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchDoctors: () => Promise<void>;
  fetchDoctor: (id: string) => Promise<void>;
  createDoctor: (data: DoctorCreateRequest) => Promise<Doctor | null>;
  updateDoctor: (
    id: string,
    data: DoctorUpdateRequest
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
      const { data, error } = await doctorService.getAll();
      if (error) {
        throw new Error(error);
      }
      setDoctors(data || []);
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
      const { data, error } = await doctorService.getById(id);
      if (error) {
        throw new Error(error);
      }
      if (data) {
        setSelectedDoctor(data);
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
    async (data: DoctorCreateRequest): Promise<Doctor | null> => {
      try {
        setLoading(true);
        setError(null);
        const { data: newDoctor, error } = await doctorService.create(data);
        if (error) {
          throw new Error(error);
        }
        if (newDoctor) {
          setDoctors((prev) => [...prev, newDoctor]);
          return newDoctor;
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
    async (id: string, data: DoctorUpdateRequest): Promise<Doctor | null> => {
      try {
        setLoading(true);
        setError(null);
        const { data: updatedDoctor, error } = await doctorService.update(
          id,
          data
        );
        if (error) {
          throw new Error(error);
        }
        if (updatedDoctor) {
          setDoctors((prev) =>
            prev.map((doctor) => (doctor.id === id ? updatedDoctor : doctor))
          );
          if (selectedDoctor?.id === id) {
            setSelectedDoctor(updatedDoctor);
          }
          return updatedDoctor;
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
        const { error } = await doctorService.delete(id);
        if (error) {
          throw new Error(error);
        }
        setDoctors((prev) => prev.filter((doctor) => doctor.id !== id));
        if (selectedDoctor?.id === id) {
          setSelectedDoctor(null);
        }
        return true;
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
