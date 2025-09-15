"use client";

import type { SessionWithRooms, StreamingRoom } from "@/services";
import { patientService, streamingService } from "@/services";
import { useCallback, useEffect, useState } from "react";

// Types for streaming sessions with rooms
interface PatientWithSession {
  id: string;
  first_name: string;
  last_name: string;
  session: SessionWithRooms | null;
}

interface UseStreamingSessionsReturn {
  // State
  patients: PatientWithSession[];
  loading: boolean;
  error: string | null;

  // Actions
  fetchSessions: () => Promise<void>;
  endSession: (sessionId: string) => Promise<void>;
  clearError: () => void;
  refreshData: () => Promise<void>;

  // Statistics
  totalSessions: number;
  activeSessions: number;
  connectedRooms: number;

  // Manual refresh control
  lastRefreshTime: Date | null;
}

export function useStreamingSessions(): UseStreamingSessionsReturn {
  const [patients, setPatients] = useState<PatientWithSession[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastRefreshTime, setLastRefreshTime] = useState<Date | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const fetchSessions = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Use the new streamingService method to get all sessions with their rooms
      const response = await streamingService.getSessionsWithRooms();

      if (response.error) {
        setError(response.error);
        return;
      }

      if (!response.data || !Array.isArray(response.data)) {
        console.log("No valid session data received:", response.data);
        setPatients([]);
        return;
      }

      if (response.data.length === 0) {
        setPatients([]);
        return;
      }

      // Get unique patient IDs from sessions
      const patientIds = [
        ...new Set(
          response.data.map((session: SessionWithRooms) => session.patient_id)
        ),
      ];

      // Fetch patient data for each ID and match with their session
      const patientPromises = patientIds.map(async (patientId: string) => {
        try {
          const patientResponse = await patientService.getById(patientId);
          if (patientResponse.error || !patientResponse.data) {
            return null;
          }

          // Find the session for this patient (1:1 relationship)
          const patientSession = response.data?.find(
            (session: SessionWithRooms) => session.patient_id === patientId
          );

          return {
            id: patientResponse.data.id,
            first_name: patientResponse.data.first_name,
            last_name: patientResponse.data.last_name,
            session: patientSession || null,
          };
        } catch (err) {
          console.error(`Error fetching patient ${patientId}:`, err);
          return null;
        }
      });

      const fetchedPatients = await Promise.all(patientPromises);
      setPatients(fetchedPatients.filter(Boolean) as PatientWithSession[]);
      setLastRefreshTime(new Date());
    } catch (err) {
      console.error("Error in fetchSessions:", err);
      setError(
        err instanceof Error
          ? err.message
          : "Failed to fetch streaming sessions"
      );
    } finally {
      setLoading(false);
    }
  }, []);

  const endSession = useCallback(
    async (sessionId: string) => {
      try {
        const response = await streamingService.endSession(sessionId);
        if (response.error) {
          setError(`Failed to end session: ${response.error}`);
          return;
        }

        // Refresh the data after ending session
        await fetchSessions();
      } catch (err) {
        console.error("Error ending session:", err);
        setError("Failed to end session");
      }
    },
    [fetchSessions]
  );

  const refreshData = useCallback(async () => {
    await fetchSessions();
  }, [fetchSessions]);

  // Initial data fetch
  useEffect(() => {
    fetchSessions(); // Initial fetch
  }, [fetchSessions]);

  // Calculate statistics
  const totalSessions = patients.filter((p) => p.session).length;
  const activeSessions = patients.reduce((acc, p) => {
    if (!p.session) return acc;
    const connectedRooms = p.session.streaming_rooms.filter(
      (room) => room.connected
    ).length;
    return acc + (connectedRooms > 0 ? 1 : 0);
  }, 0);
  const connectedRooms = patients.reduce((acc, p) => {
    if (!p.session) return acc;
    const connected = p.session.streaming_rooms.filter(
      (room) => room.connected
    ).length;
    return acc + connected;
  }, 0);

  return {
    patients,
    loading,
    error,
    fetchSessions,
    endSession,
    clearError,
    refreshData,
    totalSessions,
    activeSessions,
    connectedRooms,
    lastRefreshTime,
  };
}

export type {
  PatientWithSession,
  SessionWithRooms,
  StreamingRoom,
  UseStreamingSessionsReturn,
};
