import { ambulanceStreamingService } from "@/services/streamingService";
import type {
  AmbulanceSession,
  AmbulanceSessionCreate,
  AmbulanceStreamingStatus,
  CameraRoom,
} from "@/types";
import { useCallback, useEffect, useState } from "react";

// Enhanced interface for ambulance with session data
export interface AmbulanceWithSession {
  id: string;
  ambulance_number: string;
  status: string;
  session: AmbulanceSession | null;
  cameras: CameraRoom[];
}

/**
 * Comprehensive hook for managing ambulance streaming operations
 *
 * Combines session management, real-time updates, statistics, and camera operations
 *
 * Example usage:
 * ```tsx
 * const {
 *   sessions,
 *   ambulances,
 *   streamingStatus,
 *   statistics,
 *   loading,
 *   error,
 *   createSession,
 *   endSession,
 *   refreshData,
 *   connectToCamera
 * } = useAmbulanceStreaming();
 * ```
 */
export const useAmbulanceStreaming = () => {
  const [sessions, setSessions] = useState<AmbulanceSession[]>([]);
  const [ambulances, setAmbulances] = useState<AmbulanceWithSession[]>([]);
  const [streamingStatus, setStreamingStatus] = useState<
    AmbulanceStreamingStatus[]
  >([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastRefreshTime, setLastRefreshTime] = useState<Date | null>(null);

  // Real-time event sources
  const [sessionsEventSource, setSessionsEventSource] =
    useState<EventSource | null>(null);
  const [roomsEventSource, setRoomsEventSource] = useState<EventSource | null>(
    null
  );

  // Clear error state
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  // Comprehensive data fetching that combines sessions, status, and ambulance data
  const fetchData = useCallback(
    async (filters?: {
      ambulance_id?: string;
      session_type?: string;
      is_active?: boolean;
    }) => {
      setLoading(true);
      setError(null);

      try {
        // Fetch streaming status
        const statusResponse =
          await ambulanceStreamingService.getAmbulancesStreamingStatus();
        if (statusResponse.error) {
          throw new Error(statusResponse.error);
        }
        if (statusResponse.data) {
          setStreamingStatus(statusResponse.data);
        }

        // Fetch all sessions
        const sessionsResponse =
          await ambulanceStreamingService.getAmbulanceSessions(filters);
        if (sessionsResponse.error) {
          throw new Error(sessionsResponse.error);
        }

        const sessionsData = sessionsResponse.data || [];
        setSessions(sessionsData);

        // Create ambulance data structure with sessions
        if (sessionsData.length > 0) {
          const ambulanceIds = [
            ...new Set(
              sessionsData.map(
                (session: AmbulanceSession) => session.ambulance_id
              )
            ),
          ];

          const ambulanceData: AmbulanceWithSession[] = ambulanceIds.map(
            (ambulanceId: string) => {
              const ambulanceSession = sessionsData.find(
                (session: AmbulanceSession) =>
                  session.ambulance_id === ambulanceId
              );
              const statusInfo = statusResponse.data?.find(
                (status: AmbulanceStreamingStatus) =>
                  status.ambulance_id === ambulanceId
              );

              return {
                id: ambulanceId,
                ambulance_number:
                  statusInfo?.ambulance_number ||
                  `AMB-${ambulanceId.slice(-4)}`,
                status: statusInfo?.status || "unknown",
                session: ambulanceSession || null,
                cameras: statusInfo?.camera_rooms || [],
              };
            }
          );

          setAmbulances(ambulanceData);
        } else {
          setAmbulances([]);
        }

        setLastRefreshTime(new Date());
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to fetch data");
      } finally {
        setLoading(false);
      }
    },
    []
  );

  // Backward compatibility - fetchSessions method
  const fetchSessions = useCallback(
    (filters?: {
      ambulance_id?: string;
      session_type?: string;
      is_active?: boolean;
    }) => fetchData(filters),
    [fetchData]
  );

  // Refresh all data - alias for fetchData
  const refreshData = useCallback(() => fetchData(), [fetchData]);

  // Create a new ambulance session
  const createSession = useCallback(
    async (sessionData: AmbulanceSessionCreate) => {
      setLoading(true);
      setError(null);

      try {
        const response = await ambulanceStreamingService.createAmbulanceSession(
          sessionData
        );
        if (response.error) {
          throw new Error(response.error);
        }

        // Refresh all data after creation
        await refreshData();
        return response.data;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to create session";
        setError(errorMessage);
        throw new Error(errorMessage);
      } finally {
        setLoading(false);
      }
    },
    [fetchSessions]
  );

  // End an ambulance session
  const endSession = useCallback(
    async (sessionId: string) => {
      setLoading(true);
      setError(null);

      try {
        const response = await ambulanceStreamingService.endAmbulanceSession(
          sessionId
        );
        if (response.error) {
          throw new Error(response.error);
        }

        // Refresh all data after ending
        await refreshData();
        return response.data;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to end session";
        setError(errorMessage);
        throw new Error(errorMessage);
      } finally {
        setLoading(false);
      }
    },
    [fetchSessions]
  );

  // Connect to WebRTC camera as viewer
  const connectToCamera = useCallback(
    async (cameraId: string, sdpOffer: RTCSessionDescriptionInit) => {
      try {
        const response = await ambulanceStreamingService.connectCameraViewer(
          cameraId,
          {
            sdp: sdpOffer.sdp || "",
            type: sdpOffer.type as any,
          }
        );

        if (response.error) {
          throw new Error(response.error);
        }

        return response.data;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to connect to camera";
        setError(errorMessage);
        throw new Error(errorMessage);
      }
    },
    []
  );

  // Check if ambulance has active session
  const hasActiveSession = useCallback(async (ambulanceId: string) => {
    return ambulanceStreamingService.hasActiveSession(ambulanceId);
  }, []);

  // Initial load
  useEffect(() => {
    refreshData();
  }, [refreshData]);

  // Calculate statistics
  const statistics = {
    totalSessions: sessions.length,
    activeSessions: sessions.filter((session) => session.is_active).length,
    connectedRooms: streamingStatus.reduce(
      (total, status) => total + status.connected_camera_rooms,
      0
    ),
    totalRooms: streamingStatus.reduce(
      (total, status) => total + status.total_camera_rooms,
      0
    ),
  };

  return {
    // State
    sessions,
    ambulances,
    streamingStatus,
    loading,
    error,
    lastRefreshTime,

    // Actions
    fetchSessions, // Backward compatibility
    fetchData,
    refreshData,
    createSession,
    endSession,
    connectToCamera,
    hasActiveSession,
    clearError,

    // Statistics
    statistics,
    totalSessions: statistics.totalSessions,
    activeSessions: statistics.activeSessions,
    connectedRooms: statistics.connectedRooms,
  };
};

/**
 * Hook for real-time ambulance session updates
 *
 * Example usage:
 * ```tsx
 * const { sessionEvents, roomEvents } = useAmbulanceStreamingRealtime();
 *
 * useEffect(() => {
 *   if (sessionEvents.length > 0) {
 *     console.log('New session event:', sessionEvents[sessionEvents.length - 1]);
 *   }
 * }, [sessionEvents]);
 * ```
 */
export const useAmbulanceStreamingRealtime = () => {
  const [sessionEvents, setSessionEvents] = useState<any[]>([]);
  const [roomEvents, setRoomEvents] = useState<any[]>([]);
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    // Connect to ambulance sessions SSE stream
    const sessionsEventSource =
      ambulanceStreamingService.getRealtimeAmbulanceSessions();

    sessionsEventSource.onopen = () => {
      setConnected(true);
    };

    sessionsEventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        setSessionEvents((prev) => [
          ...prev,
          { ...data, timestamp: new Date() },
        ]);
      } catch (err) {
        console.error("Failed to parse session event:", err);
      }
    };

    sessionsEventSource.onerror = () => {
      setConnected(false);
    };

    // Connect to camera rooms SSE stream
    const roomsEventSource = ambulanceStreamingService.getRealtimeCameraRooms();

    roomsEventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        setRoomEvents((prev) => [...prev, { ...data, timestamp: new Date() }]);
      } catch (err) {
        console.error("Failed to parse room event:", err);
      }
    };

    // Cleanup
    return () => {
      sessionsEventSource.close();
      roomsEventSource.close();
    };
  }, []);

  return {
    sessionEvents,
    roomEvents,
    connected,
    clearEvents: useCallback(() => {
      setSessionEvents([]);
      setRoomEvents([]);
    }, []),
  };
};
