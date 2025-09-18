/**
 * React hooks for realtime functionality
 * Provides easy-to-use hooks for consuming SSE streams
 */

import {
  RealtimeConnection,
  RealtimeEvent,
  RealtimeOptions,
  realtimeService,
} from "@/services/realtimeService";
import type { StreamingRoom, StreamingSession } from "@/types";
import { useCallback, useEffect, useRef, useState } from "react";

export interface UseRealtimeSessionsOptions extends RealtimeOptions {
  patientId?: string;
  enabled?: boolean;
}

export interface UseRealtimeRoomsOptions extends RealtimeOptions {
  enabled?: boolean;
}

export interface UseRealtimePatientOptions extends RealtimeOptions {
  patientId: string;
  enabled?: boolean;
}

/**
 * Hook for subscribing to real-time streaming sessions updates
 */
export function useRealtimeSessions(options: UseRealtimeSessionsOptions = {}) {
  const [sessions, setSessions] = useState<StreamingSession[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastEvent, setLastEvent] = useState<RealtimeEvent | null>(null);
  const connectionRef = useRef<RealtimeConnection | null>(null);

  const { patientId, enabled = true, ...realtimeOptions } = options;

  const handleMessage = useCallback((event: RealtimeEvent) => {
    console.log("🎯 SESSIONS - Received realtime event:", event);
    setLastEvent(event);
    setError(null);

    switch (event.type) {
      case "connected":
        setIsConnected(true);
        console.log("📡 Connected to sessions stream");
        break;

      case "database_change":
        console.log("🔄 SESSIONS - Processing database change:", event);
        if (event.table === "streaming_sessions") {
          setSessions((prev) => {
            console.log(
              "📊 SESSIONS - Current sessions before update:",
              prev.length
            );
            const newSessions = [...prev];
            const sessionData = event.new as StreamingSession;

            if (event.event === "INSERT" && sessionData) {
              // Add new session
              console.log("➕ SESSIONS - Adding new session:", sessionData.id);
              newSessions.push(sessionData);
            } else if (event.event === "UPDATE" && sessionData) {
              // Update existing session
              const index = newSessions.findIndex(
                (s) => s.id === sessionData.id
              );
              if (index >= 0) {
                console.log(
                  "🔄 SESSIONS - Updating existing session at index:",
                  index
                );
                newSessions[index] = sessionData;
              } else {
                console.log(
                  "➕ SESSIONS - Adding session (not found for update):",
                  sessionData.id
                );
                newSessions.push(sessionData);
              }
            } else if (event.event === "DELETE" && event.old) {
              // Remove deleted session
              const oldData = event.old as StreamingSession;
              console.log("🗑️ SESSIONS - Removing session:", oldData.id);
              return newSessions.filter((s) => s.id !== oldData.id);
            }

            console.log(
              "📊 SESSIONS - Sessions after update:",
              newSessions.length
            );
            return newSessions;
          });
        } else {
          console.log(
            "⚠️ SESSIONS - Ignoring event for different table:",
            event.table
          );
        }
        break;

      case "error":
        console.error("❌ SESSIONS - Realtime error:", event.error);
        setError(event.error || "Unknown realtime error");
        setIsConnected(false);
        break;

      case "heartbeat":
        console.log("💓 SESSIONS - Heartbeat received");
        // Keep connection alive
        break;

      default:
        console.log("❓ SESSIONS - Unknown event type:", event.type);
    }
  }, []);

  const connect = useCallback(() => {
    if (!enabled) return;

    try {
      const connection = realtimeService.subscribeToSessions(
        handleMessage,
        patientId,
        realtimeOptions
      );
      connectionRef.current = connection;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, patientId, handleMessage, realtimeOptions]);

  const disconnect = useCallback(() => {
    if (connectionRef.current) {
      connectionRef.current.close();
      connectionRef.current = null;
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
    isConnected,
    error,
    lastEvent,
    connect,
    disconnect,
    setSessions, // Allow manual session updates
  };
}

/**
 * Hook for subscribing to real-time streaming rooms updates
 */
export function useRealtimeRooms(options: UseRealtimeRoomsOptions = {}) {
  const [rooms, setRooms] = useState<StreamingRoom[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastEvent, setLastEvent] = useState<RealtimeEvent | null>(null);
  const connectionRef = useRef<RealtimeConnection | null>(null);

  const { enabled = true, ...realtimeOptions } = options;

  const handleMessage = useCallback((event: RealtimeEvent) => {
    console.log("🎯 ROOMS - Received realtime event:", event);
    setLastEvent(event);
    setError(null);

    switch (event.type) {
      case "connected":
        setIsConnected(true);
        console.log("📡 Connected to rooms stream");
        break;

      case "database_change":
        console.log("🔄 ROOMS - Processing database change:", event);
        if (event.table === "streaming_rooms") {
          setRooms((prev) => {
            console.log("📊 ROOMS - Current rooms before update:", prev.length);
            const newRooms = [...prev];
            const roomData = event.new as StreamingRoom;

            if (event.event === "INSERT" && roomData) {
              console.log("➕ ROOMS - Adding new room:", roomData.id);
              newRooms.push(roomData);
            } else if (event.event === "UPDATE" && roomData) {
              const index = newRooms.findIndex((r) => r.id === roomData.id);
              if (index >= 0) {
                console.log(
                  "🔄 ROOMS - Updating existing room at index:",
                  index
                );
                console.log(
                  "🔄 ROOMS - Old connected:",
                  newRooms[index].connected,
                  "-> New connected:",
                  roomData.connected
                );
                newRooms[index] = roomData;
              } else {
                console.log(
                  "➕ ROOMS - Adding room (not found for update):",
                  roomData.id
                );
                newRooms.push(roomData);
              }
            } else if (event.event === "DELETE" && event.old) {
              const oldData = event.old as StreamingRoom;
              console.log("🗑️ ROOMS - Removing room:", oldData.id);
              return newRooms.filter((r) => r.id !== oldData.id);
            }

            console.log("📊 ROOMS - Rooms after update:", newRooms.length);
            return newRooms;
          });
        } else {
          console.log(
            "⚠️ ROOMS - Ignoring event for different table:",
            event.table
          );
        }
        break;

      case "error":
        console.error("❌ ROOMS - Realtime error:", event.error);
        setError(event.error || "Unknown realtime error");
        setIsConnected(false);
        break;

      case "heartbeat":
        console.log("💓 ROOMS - Heartbeat received");
        // Keep connection alive
        break;

      default:
        console.log("❓ ROOMS - Unknown event type:", event.type);
    }
  }, []);

  const connect = useCallback(() => {
    if (!enabled) return;

    try {
      const connection = realtimeService.subscribeToRooms(
        handleMessage,
        realtimeOptions
      );
      connectionRef.current = connection;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, realtimeOptions]);

  const disconnect = useCallback(() => {
    if (connectionRef.current) {
      connectionRef.current.close();
      connectionRef.current = null;
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
    rooms,
    isConnected,
    error,
    lastEvent,
    connect,
    disconnect,
    setRooms, // Allow manual room updates
  };
}

/**
 * Hook for subscribing to real-time patient status updates
 */
export function useRealtimePatient(options: UseRealtimePatientOptions) {
  const [patientData, setPatientData] = useState<Record<string, any> | null>(
    null
  );
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastEvent, setLastEvent] = useState<RealtimeEvent | null>(null);
  const connectionRef = useRef<RealtimeConnection | null>(null);

  const { patientId, enabled = true, ...realtimeOptions } = options;

  const handleMessage = useCallback(
    (event: RealtimeEvent) => {
      setLastEvent(event);
      setError(null);

      switch (event.type) {
        case "connected":
          setIsConnected(true);
          console.log(`📡 Connected to patient ${patientId} stream`);
          break;

        case "database_change":
          if (event.table === "patients" && event.event === "UPDATE") {
            const updatedPatient = event.new;
            if (updatedPatient) {
              setPatientData(updatedPatient);
            }
          }
          break;

        case "error":
          setError(event.error || "Unknown realtime error");
          setIsConnected(false);
          break;

        case "heartbeat":
          // Keep connection alive
          break;
      }
    },
    [patientId]
  );

  const connect = useCallback(() => {
    if (!enabled || !patientId) return;

    try {
      const connection = realtimeService.subscribeToPatientStatus(
        patientId,
        handleMessage,
        realtimeOptions
      );
      connectionRef.current = connection;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to connect");
      setIsConnected(false);
    }
  }, [enabled, patientId, realtimeOptions]);

  const disconnect = useCallback(() => {
    if (connectionRef.current) {
      connectionRef.current.close();
      connectionRef.current = null;
    }
    setIsConnected(false);
  }, []);

  useEffect(() => {
    if (enabled && patientId) {
      connect();
    } else {
      disconnect();
    }

    return () => {
      disconnect();
    };
  }, [enabled, patientId]);

  return {
    patientData,
    isConnected,
    error,
    lastEvent,
    connect,
    disconnect,
    setPatientData, // Allow manual patient data updates
  };
}

/**
 * Hook for general realtime service status and health
 */
export function useRealtimeStatus() {
  const [health, setHealth] = useState<any>(null);
  const [connectionStatus, setConnectionStatus] = useState<Record<string, any>>(
    {}
  );
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const checkHealth = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const healthData = await realtimeService.checkHealth();
      setHealth(healthData);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Health check failed");
    } finally {
      setIsLoading(false);
    }
  }, []);

  const updateConnectionStatus = useCallback(() => {
    const status = realtimeService.getConnectionStatus();
    setConnectionStatus(status);
  }, []);

  useEffect(() => {
    checkHealth();
    updateConnectionStatus();

    // Update connection status periodically
    const interval = setInterval(updateConnectionStatus, 5000);
    return () => clearInterval(interval);
  }, []);

  return {
    health,
    connectionStatus,
    isLoading,
    error,
    checkHealth,
    updateConnectionStatus,
  };
}

/**
 * Hook for testing realtime functionality
 */
export function useRealtimeTest(patientId?: string) {
  const [testEvents, setTestEvents] = useState<RealtimeEvent[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const connectionRef = useRef<RealtimeConnection | null>(null);

  const handleMessage = useCallback((event: RealtimeEvent) => {
    setTestEvents((prev) => [...prev, event]);
    setError(null);

    if (event.type === "connected") {
      setIsConnected(true);
    } else if (event.type === "error") {
      setError(event.error || "Unknown error");
      setIsConnected(false);
    }
  }, []);

  const startTest = useCallback(() => {
    setTestEvents([]);
    setError(null);

    try {
      const connection = realtimeService.subscribeToTest(
        handleMessage,
        patientId
      );
      connectionRef.current = connection;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to start test");
    }
  }, [patientId]);

  const stopTest = useCallback(() => {
    if (connectionRef.current) {
      connectionRef.current.close();
      connectionRef.current = null;
    }
    setIsConnected(false);
  }, []);

  const clearEvents = useCallback(() => {
    setTestEvents([]);
  }, []);

  return {
    testEvents,
    isConnected,
    error,
    startTest,
    stopTest,
    clearEvents,
  };
}
