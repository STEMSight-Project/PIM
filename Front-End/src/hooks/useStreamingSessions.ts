"use client";

/**
 * Compatibility wrapper: streaming sessions were removed from the database.
 *
 * This file keeps the old hook name available for callers but treats
 * session-changing operations as safe no-ops. Read-only data (ambulance
 * list, streaming status, statistics) is forwarded from
 * `useAmbulanceStreaming` so the UI can continue to show current
 * ambulance/camera status.
 */

import type {
  AmbulanceStreamingStatus,
  CameraRoom,
} from "@/types";
import { useAmbulanceStreaming } from "./useAmbulanceStreaming";

// Reuse the exported AmbulanceWithSession shape from useAmbulanceStreaming
import type { AmbulanceWithSession } from "./useAmbulanceStreaming";

interface UseAmbulanceStreamingSessionsReturn {
  ambulances: AmbulanceWithSession[];
  streamingStatus: AmbulanceStreamingStatus[];
  loading: boolean;
  error: string | null;

  // Actions (mutations are now no-ops / soft-fail because sessions are gone)
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

/**
 * Backward-compatible wrapper around `useAmbulanceStreaming`.
 *
 * Note: the database no longer stores "streaming sessions". To avoid
 * breaking callers we forward read-only data and make session mutations
 * (create/end) into safe no-ops that log a warning. Prefer `useAmbulanceStreaming`
 * directly for new code.
 */
export function useAmbulanceStreamingSessions(): UseAmbulanceStreamingSessionsReturn {
  const {
    ambulances,
    streamingStatus,
    loading,
    error,
    // fetchSessions and endSession would normally call session endpoints.
    // We still forward refreshData for read-only updates.
    fetchData,
    refreshData,
    lastRefreshTime,
  } = useAmbulanceStreaming();

  // No-op fetchSessions: just refresh read-only data
  const fetchSessions = async () => {
    console.warn(
      "useAmbulanceStreamingSessions.fetchSessions: streaming sessions endpoint removed; performing read-only refresh instead"
    );
    await fetchData();
  };

  // No-op endSession: previously mutated session state in DB; now we warn and return
  const endSession = async (sessionId: string) => {
    console.warn(
      `useAmbulanceStreamingSessions.endSession: cannot end session ${sessionId} because streaming sessions are removed from the database`
    );
    // Resolve so callers that await this don't throw; they should handle the no-op.
    return Promise.resolve();
  };

  return {
    ambulances,
    streamingStatus,
    loading,
    error,
    fetchSessions,
    endSession,
    clearError: () => {},
    refreshData: async () => {
      await refreshData();
    },
    totalSessions: ambulances.filter((a) => !!a.session).length,
    activeSessions: ambulances.filter((a) => a.session?.is_active).length,
    connectedRooms: streamingStatus.reduce(
      (total, s) => total + (s.connected_camera_rooms || 0),
      0
    ),
    lastRefreshTime,
  };
}

export type { AmbulanceWithSession, UseAmbulanceStreamingSessionsReturn };
