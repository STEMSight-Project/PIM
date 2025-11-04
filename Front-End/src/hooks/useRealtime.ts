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
  sessionId?: string;
  isActive?: boolean; // Filter by active/inactive sessions
}

export interface UseRealtimeAmbulanceOptions {
  ambulanceId: string;
  enabled?: boolean;
}

/**
 * Hook for subscribing to real-time ambulance sessions with embedded rooms
 * Listens to both session and room changes to keep data synchronized
 *
 * **Architecture:**
 * 1. **Initial Load:** Fetches all cameras for each ambulance via `/ambulances/{id}/cameras`
 *    - This includes ALL cameras installed on the ambulance (not just active streaming rooms)
 *    - Cameras without active streams are marked as `connected: false`
 *
 * 2. **Real-Time Updates:** Subscribes to SSE events for:
 *    - Session changes (INSERT/UPDATE/DELETE)
 *    - Camera room changes (when cameras start/stop streaming)
 *
 * 3. **Data Sync:** Real-time events update existing camera/room states without full refetch
 *
 * @param options.ambulanceId - Filter sessions by specific ambulance ID
 * @param options.sessionId - Filter to get a specific session by ID
 * @param options.isActive - Filter by active status (true/false/undefined for all)
 * @param options.enabled - Enable/disable real-time updates (default: true)
 *
 * @example
 * // Get all active sessions with ALL ambulance cameras
 * const { sessions } = useRealtimeAmbulanceSessions({ isActive: true });
 * // sessions[0].camera_rooms will include all cameras, not just streaming ones
 *
 * @example
 * // Get active sessions for specific ambulance
 * const { sessions } = useRealtimeAmbulanceSessions({
 *   ambulanceId: "AMB-001",
 *   isActive: true
 * });
 *
 * @example
 * // Get specific session by ID
 * const { sessions } = useRealtimeAmbulanceSessions({
 *   sessionId: "session-uuid-123"
 * });
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
  const roomUpdateTimersRef = useRef<Map<string, NodeJS.Timeout>>(new Map());

  const { enabled = true, ambulanceId, sessionId, isActive } = options;

  /**
   * Fetch complete session information including all ambulance cameras
   *
   * **Purpose:** When a session is created or updated via SSE, this function
   * fetches all the related data to provide a complete session object.
   *
   * **What it fetches:**
   * 1. All cameras installed on the ambulance (via `/ambulances/{id}/cameras`)
   * 2. Active streaming rooms for this session (via `/camera-rooms?session_id={id}`)
   * 3. Merges camera and room data to show which cameras are streaming
   *
   * **Why separate function:**
   * - SSE events only contain basic session data (id, ambulance_id, is_active, etc.)
   * - We need to fetch related data (cameras, rooms) to build complete UI
   * - Keeps session update logic clean and reusable
   *
   * @param sessionData - Basic session data from SSE event
   * @returns Complete session with all ambulance cameras as camera_rooms
   */
  const fetchCompleteSessionInfo = useCallback(
    async (sessionData: AmbulanceSession): Promise<AmbulanceSession> => {
      try {
        console.log(
          `[Realtime] Fetching complete info for session ${sessionData.id}`
        );

        // Get all cameras for this ambulance
        const camerasResponse =
          await ambulanceStreamingService.getAmbulanceCameras(
            sessionData.ambulance_id
          );

        if (camerasResponse.data && !camerasResponse.error) {
          // Get active rooms for this session
          const roomsResponse = await ambulanceStreamingService.getCameraRooms({
            session_id: sessionData.id,
          });

          // Map cameras to camera rooms, marking active ones
          const cameraRooms: CameraRoom[] = camerasResponse.data.map(
            (camera) => {
              // Find matching active room if exists
              const existingRoom = (roomsResponse.data || []).find(
                (room) => room.camera_id === camera.id
              );

              if (existingRoom) {
                return existingRoom;
              }

              // Create room structure from camera (not yet streaming)
              // Use a placeholder UUID format so it doesn't conflict with real room UUIDs
              return {
                id: `placeholder-${camera.id}`, // Unique placeholder ID
                session_id: sessionData.id,
                camera_id: camera.id,
                room_id: `${sessionData.ambulance_id}-${camera.camera_id}`,
                room_name: `${sessionData.ambulance_id}-${camera.camera_id}`,
                camera_name: camera.camera_name || "Unknown Camera",
                connected: false,
                connection_started_at: new Date().toISOString(),
                ai_processing_active: false,
                detections_count: 0,
                created_at: camera.created_at,
                updated_at: camera.updated_at,
              };
            }
          );

          return {
            ...sessionData,
            camera_rooms: cameraRooms,
          };
        }

        // Fallback: if cameras fetch fails, return session with empty rooms
        console.warn(
          `Failed to fetch cameras for ambulance ${sessionData.ambulance_id}`
        );
        return {
          ...sessionData,
          camera_rooms: [],
        };
      } catch (err) {
        console.error(
          `Error fetching complete session info for ${sessionData.id}:`,
          err
        );
        return {
          ...sessionData,
          camera_rooms: [],
        };
      }
    },
    []
  );

  const handleSessionMessage = useCallback(
    async (event: MessageEvent) => {
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
          switch (actualEventType) {
            case "INSERT":
              {
                // Apply filters to new session data
                let shouldInclude = true;

                if (ambulanceId && sessionData.ambulance_id !== ambulanceId) {
                  shouldInclude = false;
                }

                if (sessionId && sessionData.id !== sessionId) {
                  shouldInclude = false;
                }

                if (
                  isActive !== undefined &&
                  sessionData.is_active !== isActive
                ) {
                  shouldInclude = false;
                }

                if (shouldInclude) {
                  console.log(
                    `[Realtime] New session ${sessionData.id} inserted, fetching complete info`
                  );

                  // 🔥 NEW: Fetch complete session info with all ambulance cameras
                  const completeSession = await fetchCompleteSessionInfo(
                    sessionData
                  );

                  setSessions((prev) => {
                    // Check if session already exists (race condition protection)
                    const index = prev.findIndex(
                      (s) => s.id === completeSession.id
                    );
                    if (index >= 0) {
                      // Update existing
                      const updated = [...prev];
                      updated[index] = completeSession;
                      return updated;
                    }
                    // Add new
                    return [...prev, completeSession];
                  });
                }
              }
              break;

            case "UPDATE":
              {
                // Apply filters to updated session data
                let shouldInclude = true;

                if (ambulanceId && sessionData.ambulance_id !== ambulanceId) {
                  shouldInclude = false;
                }

                if (sessionId && sessionData.id !== sessionId) {
                  shouldInclude = false;
                }

                if (
                  isActive !== undefined &&
                  sessionData.is_active !== isActive
                ) {
                  shouldInclude = false;
                }

                setSessions((prev) => {
                  const newSessions = [...prev];
                  const index = newSessions.findIndex(
                    (s) => s.id === sessionData.id
                  );

                  if (shouldInclude) {
                    if (index >= 0) {
                      // 🔥 CRITICAL: Preserve existing rooms when updating session
                      // Only update session fields, keep camera_rooms intact
                      const existingRooms =
                        newSessions[index].camera_rooms || [];
                      console.log(
                        `[Realtime] Updating session ${sessionData.id}, preserving ${existingRooms.length} rooms`
                      );
                      newSessions[index] = {
                        ...sessionData,
                        camera_rooms: existingRooms, // Preserve existing rooms
                      };
                    } else {
                      // Session now matches filter - fetch complete info
                      console.log(
                        `[Realtime] Session ${sessionData.id} now matches filter, fetching complete info`
                      );
                      // Will be fetched asynchronously
                      fetchCompleteSessionInfo(sessionData).then(
                        (completeSession) => {
                          setSessions((current) => {
                            const idx = current.findIndex(
                              (s) => s.id === completeSession.id
                            );
                            if (idx < 0) {
                              return [...current, completeSession];
                            }
                            return current;
                          });
                        }
                      );
                    }
                  } else if (index >= 0) {
                    // Remove session if it no longer matches filters
                    console.log(
                      `[Realtime] Session ${sessionData.id} no longer matches filter, removing`
                    );
                    newSessions.splice(index, 1);
                  }

                  return newSessions;
                });
              }
              break;

            case "DELETE":
              {
                setSessions((prev) =>
                  prev.filter((s) => s.id !== sessionData.id)
                );
                console.log(
                  `[Realtime] Session ${sessionData.id} deleted, removed from list`
                );
              }
              break;

            default:
              break;
          }
        }
      } catch (err) {
        console.error("Failed to parse ambulance session SSE event:", err);
        setError("Failed to parse real-time event");
      }
    },
    [ambulanceId, sessionId, isActive, fetchCompleteSessionInfo]
  );

  const handleRoomMessage = useCallback((event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);
      setError(null);

      const eventData = typeof data === "string" ? JSON.parse(data) : data;
      const roomData = eventData.new || eventData.room || eventData.record;

      // Extract the actual event type
      const actualEventType =
        eventData.event || eventData.event_type || eventData.type;

      if (roomData && roomData.session_id) {
        const roomEvent: CameraRoomEvent = {
          name: eventData.table || "camera_streaming_rooms",
          event_type: actualEventType,
          room: roomData,
          timestamp: eventData.timestamp || new Date().toISOString(),
        };

        setEvents((prev) => [...prev, roomEvent]);

        // Handle DELETE event - remove room immediately
        if (actualEventType === "DELETE") {
          // Clear any pending update for this room
          const timerId = roomUpdateTimersRef.current.get(roomData.camera_id);
          if (timerId) {
            clearTimeout(timerId);
            roomUpdateTimersRef.current.delete(roomData.camera_id);
          }

          setSessions((prev) =>
            prev.map((session) => {
              if (session.id === roomData.session_id) {
                return {
                  ...session,
                  camera_rooms: (session.camera_rooms || []).filter(
                    (r: CameraRoom) => r.camera_id !== roomData.camera_id
                  ),
                };
              }
              return session;
            })
          );
          console.log(
            `[Realtime] Room for camera ${roomData.camera_id} deleted`
          );
          return;
        }

        // Handle INSERT/UPDATE with debouncing (300ms to batch rapid updates)
        const existingTimer = roomUpdateTimersRef.current.get(
          roomData.camera_id
        );
        if (existingTimer) {
          clearTimeout(existingTimer);
        }

        const newTimer = setTimeout(() => {
          roomUpdateTimersRef.current.delete(roomData.camera_id);

          setSessions((prev) =>
            prev.map((session) => {
              console.log(
                "session.id:",
                session.id,
                "roomData.session_id:",
                roomData.session_id
              );
              if (session.id === roomData.session_id) {
                const currentRooms = session.camera_rooms || [];
                const existingIndex = currentRooms.findIndex(
                  (r: CameraRoom) => r.camera_id === roomData.camera_id
                );

                if (existingIndex >= 0) {
                  // Replace existing room with new data from backend
                  const updatedRooms = [...currentRooms];
                  updatedRooms[existingIndex] = roomData;
                  console.log(
                    `[Realtime] Room for camera ${roomData.camera_id} updated`
                  );
                  return { ...session, camera_rooms: updatedRooms };
                } else {
                  // Add new room
                  console.log(
                    `[Realtime] Room for camera ${roomData.camera_id} added`
                  );
                  return {
                    ...session,
                    camera_rooms: [...currentRooms, roomData],
                  };
                }
              }
              return session;
            })
          );
        }, 300); // 300ms debounce

        roomUpdateTimersRef.current.set(roomData.camera_id, newTimer);
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

      // Build filters based on options
      const filters: Record<string, any> = {};

      if (ambulanceId) {
        filters.ambulance_id = ambulanceId;
      }

      if (sessionId) {
        filters.session_id = sessionId;
      }

      if (isActive !== undefined) {
        filters.is_active = isActive;
      }

      // Fetch sessions with filters
      const sessionsResponse =
        await ambulanceStreamingService.getAmbulanceSessions(filters);

      if (sessionsResponse.data && !sessionsResponse.error) {
        // 🔥 NEW: Fetch all cameras for each ambulance (not just session rooms)
        const sessionsWithCameras = await Promise.all(
          sessionsResponse.data.map(async (session) => {
            try {
              // Get all cameras for this ambulance
              const camerasResponse =
                await ambulanceStreamingService.getAmbulanceCameras(
                  session.ambulance_id
                );

              if (camerasResponse.data && !camerasResponse.error) {
                // Convert AmbulanceCamera[] to CameraRoom[] format
                // Include all cameras, marking active ones from current session
                const roomsResponse =
                  await ambulanceStreamingService.getCameraRooms({
                    session_id: session.id,
                  });

                const activeRoomIds = new Set(
                  (roomsResponse.data || []).map((room) => room.camera_id)
                );

                const cameraRooms: CameraRoom[] = camerasResponse.data.map(
                  (camera) => {
                    // Find matching room data if exists
                    const existingRoom = (roomsResponse.data || []).find(
                      (room) => room.camera_id === camera.id
                    );

                    if (existingRoom) {
                      return existingRoom;
                    }
                    // Create room structure from camera if no active room
                    // Use placeholder ID to avoid conflicts with real room UUIDs
                    return {
                      id: `placeholder-${camera.id}`, // Unique placeholder ID
                      session_id: session.id,
                      camera_id: camera.id,
                      room_id: `${session.ambulance_id}-${camera.camera_id}`,
                      room_name: `${session.ambulance_id}-${camera.camera_id}`,
                      camera_name: camera.camera_name || "Unknown Camera",
                      connected: false, // Not connected yet
                      connection_started_at: new Date().toISOString(),
                      ai_processing_active: false,
                      detections_count: 0,
                      created_at: camera.created_at,
                      updated_at: camera.updated_at,
                    };
                  }
                );

                return {
                  ...session,
                  camera_rooms: cameraRooms,
                };
              }

              // Fallback: if cameras fetch fails, use session rooms only
              const roomsResponse =
                await ambulanceStreamingService.getCameraRooms({
                  session_id: session.id,
                });

              return {
                ...session,
                camera_rooms: roomsResponse.data || [],
              };
            } catch (err) {
              console.error(
                `Failed to fetch cameras for ambulance ${session.ambulance_id}:`,
                err
              );
              return {
                ...session,
                camera_rooms: [],
              };
            }
          })
        );

        setSessions(sessionsWithCameras);
      } else {
        setError(sessionsResponse.error || "Failed to load initial sessions");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load sessions");
    } finally {
      setIsLoading(false);
    }
  }, [enabled, ambulanceId, sessionId, isActive]);

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
  }, [enabled, fetchInitialSessions]);

  const disconnect = useCallback(() => {
    if (sessionEventSourceRef.current) {
      sessionEventSourceRef.current.close();
      sessionEventSourceRef.current = null;
    }
    if (roomEventSourceRef.current) {
      roomEventSourceRef.current.close();
      roomEventSourceRef.current = null;
    }

    // Clear all pending room update timers
    roomUpdateTimersRef.current.forEach((timerId) => {
      clearTimeout(timerId);
    });
    roomUpdateTimersRef.current.clear();

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
    // Only reconnect when enabled changes, not when filter params change
    // Filter params are used during initial fetch and SSE message filtering
    // eslint-disable-next-line react-hooks/exhaustive-deps
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
