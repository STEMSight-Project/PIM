"use client";

import { useState, useCallback } from "react";
import { api } from "@/services/api";

export interface PatientEvent {
  id: string;
  type: string;
  timestamp: string;
  confidence: number;
  validation_status: string;
  created_at: string;
  video_id: string;
}

interface UsePatientEventsReturn {
  events: PatientEvent[];
  selectedEvent: PatientEvent | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchEventsForPatient: (patientId: string) => Promise<void>;
  fetchEventsForVideo: (videoId: string) => Promise<void>;
  updateEventStatus: (
    eventId: string,
    status: "pending" | "confirmed" | "dismissed"
  ) => Promise<PatientEvent | null>;
  clearError: () => void;
  setSelectedEvent: (event: PatientEvent | null) => void;
  clearEvents: () => void;
}

export function usePatientEvents(): UsePatientEventsReturn {
  const [events, setEvents] = useState<PatientEvent[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<PatientEvent | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const clearEvents = useCallback(() => {
    setEvents([]);
    setSelectedEvent(null);
  }, []);

  const fetchEventsForPatient = useCallback(async (patientId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<PatientEvent[]>(
        `/patient-events/patient/${patientId}`
      );
      setEvents(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch patient events";
      setError(message);
      console.error("Error fetching patient events:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchEventsForVideo = useCallback(async (videoId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<PatientEvent[]>(
        `/patient-events/video/${videoId}`
      );
      setEvents(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch video events";
      setError(message);
      console.error("Error fetching video events:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const updateEventStatus = useCallback(
    async (
      eventId: string,
      status: "pending" | "confirmed" | "dismissed"
    ): Promise<PatientEvent | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.patch<PatientEvent>(
          `/patient-events/${eventId}`,
          {
            validation_status: status,
          }
        );

        if (response.data) {
          setEvents((prev) =>
            prev.map((event) => (event.id === eventId ? response.data! : event))
          );
          if (selectedEvent?.id === eventId) {
            setSelectedEvent(response.data);
          }
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to update event status";
        setError(message);
        console.error("Error updating event status:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [selectedEvent]
  );

  return {
    events,
    selectedEvent,
    loading,
    error,
    fetchEventsForPatient,
    fetchEventsForVideo,
    updateEventStatus,
    clearError,
    setSelectedEvent,
    clearEvents,
  };
}
