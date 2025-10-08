/**
 * React hooks for realtime functionality
 * Provides easy-to-use hooks for consuming SSE streams
 */

import { ambulanceStreamingService } from "@/services/streamingService";
import type {
  AmbulanceSession,
  AmbulanceSessionEvent,
  CameraRoom,
  CameraRoomEvent,
} from "@/types";
import { useCallback, useEffect, useRef, useState } from "react";

// Hook options interfaces
interface RealtimeOptions {
  enabled?: boolean;
  autoReconnect?: boolean;
}

interface UseRealtimeAmbulanceSessionsOptions extends RealtimeOptions {
  ambulanceId?: string;
}

export interface UseRealtimeAmbulanceOptions {
  ambulanceId: string;
  enabled?: boolean;
}

/**
 * Hook for subscribing to real-time ambulance sessions with embedded rooms
 * Listens to both session and room changes to keep data synchronized
 */
export function useRealtimeAmbulanceSessions(
  options: UseRealtimeAmbulanceSessionsOptions = {}
) {
  const [sessions, setSessions] = useState<AmbulanceSession[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [events, setEvents] = useState<
    (AmbulanceSessionEvent | CameraRoomEvent)[]
  >([]);
  const [isLoading, setIsLoading] = useState(true);
  const sessionEventSourceRef = useRef<EventSource | null>(null);
  const roomEventSourceRef = useRef<EventSource | null>(null);

  const { enabled = true, ambulanceId } = options;

  const handleSessionMessage = useCallback((event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);

      setError(null);

      // Extract actual event type from 'event' field
      const actualEventType = data.event || data.event_type;
      const sessionData = data.new || data.session || data.record;

      if (actualEventType && sessionData) {
        const sessionEvent: AmbulanceSessionEvent = {
          name: data.type,
          event_type: actualEventType,
          session: sessionData,
          timestamp: data.timestamp || new Date().toISOString(),
        };

        setEvents((prev) => [...prev, sessionEvent]);

        // Update sessions based on event type
        setSessions((prev) => {
          const newSessions = [...prev];

          switch (actualEventType) {
            case "UPDATE":
            case "INSERT":
            case "DELETE":
              {
                const index = newSessions.findIndex(
                  (s) => s.id === sessionData.id
                );
                if (index >= 0) {
                  // Preserve existing rooms when updating session
                  newSessions[index] = {
                    ...sessionData,
                    camera_rooms: newSessions[index].camera_rooms || [],
                  };
                } else {
                  newSessions.push({ ...sessionData, camera_rooms: [] });
                }
              }
              break;
            default:
              break;
          }

          return newSessions;
        });
      }
    } catch (err) {
      console.error("Failed to parse ambulance session SSE event:", err);
      setError("Failed to parse real-time event");
    }
  }, []);

  const handleRoomMessage = useCallback((event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);

      setError(null);

      const eventData = typeof data === "string" ? JSON.parse(data) : data;
      const roomData = eventData.new || eventData.room || eventData.record;

      // Extract the actual event type - it's in 'event' field, not 'type'
      const actualEventType =
        eventData.event || eventData.event_type || eventData.type;

      if (roomData && roomData.session_id) {
        const roomEvent: CameraRoomEvent = {
          name: eventData.table || "camera_rooms",
          event_type: actualEventType,
          room: roomData,
          timestamp: eventData.timestamp || new Date().toISOString(),
        };

        setEvents((prev) => [...prev, roomEvent]);

        // Update the session that contains this room
        setSessions((prev) => {
          return prev.map((session) => {
            if (session.id === roomData.session_id) {
              const currentRooms = session.camera_rooms || [];

              switch (actualEventType) {
                case "INSERT":
                case "UPDATE":
                  const existingIndex = currentRooms.findIndex(
                    (r: CameraRoom) => r.id === roomData.id
                  );

                  if (existingIndex >= 0) {
                    // Update existing room
                    const updatedRooms = [...currentRooms];
                    updatedRooms[existingIndex] = {
                      ...updatedRooms[existingIndex],
                      ...roomData,
                    };
                    return { ...session, camera_rooms: updatedRooms };
                  } else {
                    // Add new room
                    return {
                      ...session,
                      camera_rooms: [...currentRooms, roomData],
                    };
                  }

                case "DELETE":
                  return {
                    ...session,
                    camera_rooms: currentRooms.filter(
                      (r: CameraRoom) => r.id !== roomData.id
                    ),
                  };

                default:
                  return session;
              }
            }
            return session;
          });
        });
      }
    } catch (err) {
      console.error("Failed to parse camera room SSE event:", err);
      setError("Failed to parse room real-time event");
    }
  }, []);

  const fetchInitialSessions = useCallback(async () => {
    if (!enabled) return;

    try {
      setIsLoading(true);

      // Fetch sessions first
      const filters = ambulanceId ? { ambulance_id: ambulanceId } : {};
      const sessionsResponse =
        await ambulanceStreamingService.getAmbulanceSessions(filters);

      if (sessionsResponse.data && !sessionsResponse.error) {
        // Fetch all camera rooms
        const roomsResponse = await ambulanceStreamingService.getCameraRooms();

        if (roomsResponse.data && !roomsResponse.error) {
          // Combine sessions with their camera rooms
          const sessionsWithRooms = sessionsResponse.data.map((session) => ({
            ...session,
            camera_rooms: (roomsResponse.data || []).filter(
              (room) => room.session_id === session.id
            ),
          }));

          setSessions(sessionsWithRooms);
        } else {
          // Sessions without rooms if rooms fetch fails
          const sessionsWithEmptyRooms = sessionsResponse.data.map(
            (session) => ({
              ...session,
              camera_rooms: [],
            })
          );
          setSessions(sessionsWithEmptyRooms);
        }
      } else {
        setError(sessionsResponse.error || "Failed to load initial sessions");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load sessions");
    } finally {
      setIsLoading(false);
    }
  }, [enabled, ambulanceId]);

  const connect = useCallback(async () => {
    if (!enabled) return;

    // First fetch initial data
    await fetchInitialSessions();

    try {
      // Connect to sessions stream
      const sessionEventSource =
        ambulanceStreamingService.getRealtimeAmbulanceSessions();

      sessionEventSource.onopen = () => {
        setIsConnected(false);
      };
      sessionEventSource.onmessage = handleSessionMessage;
      sessionEventSource.onerror = (err) => {
        console.error("Ambulance sessions SSE error:", err);
        setError("Connection to sessions real-time updates failed");
        setIsConnected(false);
      };

      // Connect to rooms stream
      const roomEventSource =
        ambulanceStreamingService.getRealtimeCameraRooms();

      roomEventSource.onopen = () => {
        // Only set connected when both streams are ready
        setIsConnected(true);
      };
      roomEventSource.onmessage = handleRoomMessage;
      roomEventSource.onerror = (err) => {
        console.error("Camera rooms SSE error:", err);
        setError("Connection to rooms real-time updates failed");
        setIsConnected(false);
      };

      sessionEventSourceRef.current = sessionEventSource;
      roomEventSourceRef.current = roomEventSource;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, handleSessionMessage, handleRoomMessage, fetchInitialSessions]);

  const disconnect = useCallback(() => {
    if (sessionEventSourceRef.current) {
      sessionEventSourceRef.current.close();
      sessionEventSourceRef.current = null;
    }
    if (roomEventSourceRef.current) {
      roomEventSourceRef.current.close();
      roomEventSourceRef.current = null;
    }
    setIsConnected(false);
  }, []);

  useEffect(() => {
    if (enabled) {
      connect();
    } else {
      disconnect();
    }

    return () => {
      disconnect();
    };
  }, [enabled]);

  return {
    sessions,
    events,
    isConnected,
    isLoading,
    error,
    connect,
    disconnect,
    setSessions, // Allow manual session updates
    clearEvents: useCallback(() => setEvents([]), []),
    refetchInitialData: fetchInitialSessions,
  };
}

// Note: useRealtimeRooms hook removed - rooms are now embedded within sessions
// Use useRealtimeAmbulanceSessions which includes camera_rooms for each session
