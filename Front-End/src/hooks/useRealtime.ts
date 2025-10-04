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

type UseRealtimeCameraRoomsOptions = RealtimeOptions;

export interface UseRealtimeAmbulanceOptions {
  ambulanceId: string;
  enabled?: boolean;
}

/**
 * Hook for subscribing to real-time ambulance sessions updates
 */
export function useRealtimeAmbulanceSessions(
  options: UseRealtimeAmbulanceSessionsOptions = {}
) {
  const [sessions, setSessions] = useState<AmbulanceSession[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [events, setEvents] = useState<AmbulanceSessionEvent[]>([]);
  const eventSourceRef = useRef<EventSource | null>(null);

  const { enabled = true } = options;

  const handleMessage = useCallback((event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);
      console.log("🎯 AMBULANCE SESSIONS - Received SSE event:", data);

      setError(null);

      if (data.event_type && data.session) {
        const sessionEvent: AmbulanceSessionEvent = {
          event_type: data.event_type,
          session: data.session,
          timestamp: data.timestamp || new Date().toISOString(),
        };

        setEvents((prev) => [...prev, sessionEvent]);

        // Update sessions based on event type
        setSessions((prev) => {
          const newSessions = [...prev];

          switch (data.event_type) {
            case "session_created":
              console.log("➕ Adding new ambulance session:", data.session.id);
              newSessions.push(data.session);
              break;

            case "session_updated":
              const index = newSessions.findIndex(
                (s) => s.id === data.session.id
              );
              if (index >= 0) {
                console.log("🔄 Updating ambulance session:", data.session.id);
                newSessions[index] = data.session;
              } else {
                newSessions.push(data.session);
              }
              break;

            case "session_ended":
              console.log("🗑️ Ending ambulance session:", data.session.id);
              return newSessions.filter((s) => s.id !== data.session.id);
          }

          return newSessions;
        });
      }
    } catch (err) {
      console.error("Failed to parse ambulance session SSE event:", err);
      setError("Failed to parse real-time event");
    }
  }, []);

  const connect = useCallback(() => {
    if (!enabled) return;

    try {
      console.log("🔗 Connecting to ambulance sessions SSE stream");
      const eventSource =
        ambulanceStreamingService.getRealtimeAmbulanceSessions();

      eventSource.onopen = () => {
        setIsConnected(true);
        console.log("📡 Connected to ambulance sessions stream");
      };

      eventSource.onmessage = handleMessage;

      eventSource.onerror = (err) => {
        console.error("❌ Ambulance sessions SSE error:", err);
        setError("Connection to real-time updates failed");
        setIsConnected(false);
      };

      eventSourceRef.current = eventSource;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, handleMessage]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
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
  }, [enabled, connect, disconnect]);

  return {
    sessions,
    events,
    isConnected,
    error,
    connect,
    disconnect,
    setSessions, // Allow manual session updates
    clearEvents: useCallback(() => setEvents([]), []),
  };
}

/**
 * Hook for subscribing to real-time streaming rooms updates
 */
export function useRealtimeRooms(options: UseRealtimeCameraRoomsOptions = {}) {
  const [rooms, setRooms] = useState<CameraRoom[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [events, setEvents] = useState<CameraRoomEvent[]>([]);
  const eventSourceRef = useRef<EventSource | null>(null);

  const { enabled = true } = options;

  const handleMessage = useCallback((event: MessageEvent) => {
    console.log("🎯 ROOMS - Received SSE event:", event.data);
    setError(null);

    try {
      const eventData =
        typeof event.data === "string" ? JSON.parse(event.data) : event.data;
      const roomEvent: CameraRoomEvent = {
        event_type: eventData.event_type,
        room: eventData.room,
        timestamp: eventData.timestamp || new Date().toISOString(),
      };

      setEvents((prev) => [...prev, roomEvent]);

      switch (roomEvent.event_type) {
        case "room_created":
        case "room_updated":
        case "room_connected":
          console.log(
            "🔄 ROOMS - Processing room update:",
            roomEvent.event_type
          );
          if (roomEvent.room) {
            setRooms((prev) => {
              const exists = prev.find((r) => r.id === roomEvent.room.id);
              if (exists) {
                console.log(
                  "🔄 ROOMS - Updating existing room:",
                  roomEvent.room.id
                );
                return prev.map((r) =>
                  r.id === roomEvent.room.id ? { ...r, ...roomEvent.room } : r
                );
              }
              console.log("➕ ROOMS - Adding new room:", roomEvent.room.id);
              return [...prev, roomEvent.room];
            });
          }
          break;

        case "room_disconnected":
          console.log("� ROOMS - Room disconnected:", roomEvent.room?.id);
          if (roomEvent.room) {
            setRooms((prev) =>
              prev.map((r) =>
                r.id === roomEvent.room.id
                  ? {
                      ...r,
                      connected: false,
                      connection_ended_at: roomEvent.timestamp,
                    }
                  : r
              )
            );
          }
          break;

        default:
          console.warn(
            "❓ ROOMS - Unknown room event type:",
            roomEvent.event_type
          );
      }
    } catch (error) {
      console.error("❌ ROOMS - Error processing event:", error);
      setError(`Failed to process event: ${error}`);
    }
  }, []);

  const connect = useCallback(() => {
    if (!enabled) return;

    try {
      console.log("🔌 ROOMS - Connecting to camera rooms SSE...");
      const eventSource = ambulanceStreamingService.getRealtimeCameraRooms();

      eventSource.onmessage = handleMessage;
      eventSource.onopen = () => {
        setIsConnected(true);
        console.log("✅ ROOMS - Connected to camera rooms SSE");
      };
      eventSource.onerror = (error) => {
        console.error("❌ ROOMS - SSE connection error:", error);
        setError("SSE connection failed");
        setIsConnected(false);
      };

      eventSourceRef.current = eventSource;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, handleMessage]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
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
  }, [enabled, connect, disconnect]);

  return {
    rooms,
    events,
    isConnected,
    error,
    connect,
    disconnect,
    setRooms, // Allow manual room updates
    clearEvents: useCallback(() => setEvents([]), []),
  };
}
