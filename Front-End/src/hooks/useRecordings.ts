import {
  recordingService,
  type RecordingResponse,
  type SessionWithRecordings,
} from "@/services/videoService";
import { useCallback, useState } from "react";

export interface UseRecordingsReturn {
  // State
  recordings: RecordingResponse[];
  sessions: SessionWithRecordings[];
  currentRecording: RecordingResponse | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  fetchAllRecordings: () => Promise<void>;
  fetchArchivedRecordings: () => Promise<void>;
  fetchSessionsWithRecordings: () => Promise<void>;
  fetchRecordingById: (recordingId: string) => Promise<void>;
  fetchRecordingsBySession: (sessionId: string) => Promise<void>;
  fetchRecordingsByAmbulance: (ambulanceId: string) => Promise<void>;
  deleteRecording: (recordingId: string) => Promise<boolean>;
  clearError: () => void;
}

export function useRecordings(): UseRecordingsReturn {
  const [recordings, setRecordings] = useState<RecordingResponse[]>([]);
  const [sessions, setSessions] = useState<SessionWithRecordings[]>([]);
  const [currentRecording, setCurrentRecording] =
    useState<RecordingResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Fetch all recordings (archived and live)
  const fetchAllRecordings = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await recordingService.getAllRecordings();

      if (response.error) {
        throw new Error(response.error);
      }

      setRecordings(response.data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch recordings";
      setError(errorMessage);
      console.error("Error fetching recordings:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch only archived recordings
  const fetchArchivedRecordings = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await recordingService.getArchivedRecordings();

      if (response.error) {
        throw new Error(response.error);
      }

      setRecordings(response.data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error
          ? err.message
          : "Failed to fetch archived recordings";
      setError(errorMessage);
      console.error("Error fetching archived recordings:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch sessions grouped with their recordings
  const fetchSessionsWithRecordings = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await recordingService.getSessionsWithRecordings();

      if (response.error) {
        throw new Error(response.error);
      }

      setSessions(response.data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch sessions";
      setError(errorMessage);
      console.error("Error fetching sessions:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch specific recording by ID
  const fetchRecordingById = useCallback(async (recordingId: string) => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await recordingService.getRecordingById(recordingId);

      if (response.error) {
        throw new Error(response.error);
      }

      setCurrentRecording(response.data || null);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch recording";
      setError(errorMessage);
      console.error("Error fetching recording:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch recordings for a specific session
  const fetchRecordingsBySession = useCallback(async (sessionId: string) => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await recordingService.getRecordingsBySession(sessionId);

      if (response.error) {
        throw new Error(response.error);
      }

      setRecordings(response.data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error
          ? err.message
          : "Failed to fetch session recordings";
      setError(errorMessage);
      console.error("Error fetching session recordings:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch recordings for a specific ambulance
  const fetchRecordingsByAmbulance = useCallback(
    async (ambulanceId: string) => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await recordingService.getRecordingsByAmbulance(
          ambulanceId
        );

        if (response.error) {
          throw new Error(response.error);
        }

        setRecordings(response.data || []);
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to fetch ambulance recordings";
        setError(errorMessage);
        console.error("Error fetching ambulance recordings:", err);
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Delete a recording
  const deleteRecording = useCallback(
    async (recordingId: string): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await recordingService.deleteRecording(recordingId);

        if (response.error) {
          throw new Error(response.error);
        }

        // Remove from local state
        setRecordings((prev) => prev.filter((rec) => rec.id !== recordingId));

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to delete recording";
        setError(errorMessage);
        console.error("Error deleting recording:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Clear error
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    recordings,
    sessions,
    currentRecording,
    isLoading,
    error,
    fetchAllRecordings,
    fetchArchivedRecordings,
    fetchSessionsWithRecordings,
    fetchRecordingById,
    fetchRecordingsBySession,
    fetchRecordingsByAmbulance,
    deleteRecording,
    clearError,
  };
}
