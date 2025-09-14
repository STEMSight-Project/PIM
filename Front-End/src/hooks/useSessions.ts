"use client";

import type { SessionWithPatient } from "@/components/session-review/types";
import { fetchStitchedSessions as fetchStitchedSessionsService } from "@/services/sessionService";
import { useCallback, useState } from "react";

interface UseSessionsReturn {
  sessions: SessionWithPatient[];
  selectedSession: SessionWithPatient | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchStitchedSessions: () => Promise<void>;
  selectSession: (session: SessionWithPatient | null) => void;
  clearError: () => void;
  clearSessions: () => void;
}

export function useSessions(): UseSessionsReturn {
  const [sessions, setSessions] = useState<SessionWithPatient[]>([]);
  const [selectedSession, setSelectedSession] =
    useState<SessionWithPatient | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const clearSessions = useCallback(() => {
    setSessions([]);
    setSelectedSession(null);
  }, []);

  const selectSession = useCallback((session: SessionWithPatient | null) => {
    setSelectedSession(session);
  }, []);

  const fetchStitchedSessions = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const stitchedSessions = await fetchStitchedSessionsService();
      setSessions(stitchedSessions);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch sessions";
      setError(message);
      console.error("Error fetching stitched sessions:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    sessions,
    selectedSession,
    loading,
    error,
    fetchStitchedSessions,
    selectSession,
    clearError,
    clearSessions,
  };
}
