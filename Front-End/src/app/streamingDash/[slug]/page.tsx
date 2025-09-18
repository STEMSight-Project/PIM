"use client";

import { ConnectionStatus } from "@/components/ConnectionStatus";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useRealtimeRooms, useRealtimeSessions } from "@/hooks/useRealtime";
import { useStreaming } from "@/hooks/useStreaming";
import { patientService, streamingService } from "@/services";
import type { Patient, StreamingRoom, StreamingSession } from "@/types";
import {
  ArrowLeftIcon,
  ChevronDownIcon,
  ChevronUpIcon,
  ExclamationTriangleIcon,
  PlayIcon,
  SignalIcon,
  StopIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";

// Simple Badge component
const Badge = ({
  children,
  variant = "default",
  className = "",
}: {
  children: React.ReactNode;
  variant?: "default" | "secondary" | "outline";
  className?: string;
}) => {
  const baseClasses =
    "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium";
  const variantClasses = {
    default: "bg-blue-100 text-blue-800",
    secondary: "bg-gray-100 text-gray-800",
    outline: "border border-gray-300 text-gray-800",
  };

  return (
    <span className={`${baseClasses} ${variantClasses[variant]} ${className}`}>
      {children}
    </span>
  );
};

export default function PatientStreamingPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const patientId = params.slug as string;
  const roomId = searchParams.get("room"); // Get room ID from URL params

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(roomId);

  // State for tracking expanded sessions
  const [expandedSessions, setExpandedSessions] = useState<Set<string>>(
    new Set()
  );

  // Helper functions for managing expanded sessions
  const toggleSessionExpansion = (sessionId: string) => {
    setExpandedSessions((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(sessionId)) {
        newSet.delete(sessionId);
      } else {
        newSet.add(sessionId);
      }
      return newSet;
    });
  };

  const isSessionExpanded = (sessionId: string) =>
    expandedSessions.has(sessionId);

  // Initial data state - fetched once on load
  const [initialSessions, setInitialSessions] = useState<StreamingSession[]>(
    []
  );
  const [initialRooms, setInitialRooms] = useState<StreamingRoom[]>([]);
  const [dataLoading, setDataLoading] = useState(true);

  // Merged state for display - combines initial data with realtime updates
  const [mergedSessions, setMergedSessions] = useState<StreamingSession[]>([]);
  const [mergedRooms, setMergedRooms] = useState<StreamingRoom[]>([]);

  // Realtime hooks for live updates (don't rely on these for initial data)
  const {
    sessions: realtimeSessions,
    isConnected: sessionsConnected,
    error: sessionsError,
  } = useRealtimeSessions({
    patientId,
    enabled: true,
  });

  const {
    rooms: realtimeRooms,
    isConnected: roomsConnected,
    error: roomsError,
  } = useRealtimeRooms({
    enabled: true,
  });

  const {
    isConnected: isStreaming,
    isConnecting,
    isReconnecting,
    error: streamingError,
    connectionQuality,
    reconnectionAttempts: reconnectAttempts,
    maxReconnectionAttempts,

    // Enhanced UX properties
    reconnectionCountdown,
    reconnectionProgress,
    userFriendlyStatus,
    canManualRetry,
    isUserCancelledReconnection,

    currentSession,
    videoRef,
    startStreaming,
    stopStreaming,
    clearError: clearStreamingError,
    reconnect,
    cancelReconnection,
  } = useStreaming();

  useEffect(() => {
    if (patientId) {
      fetchPatientData();
      fetchInitialData();
    }
  }, [patientId]);

  // Initialize merged data when initial data is loaded
  useEffect(() => {
    setMergedSessions(initialSessions);
    setMergedRooms(initialRooms);
    console.log(
      `🔄 PATIENT PAGE - Initial data loaded: ${initialSessions.length} sessions, ${initialRooms.length} rooms`
    );
  }, [initialSessions, initialRooms]);

  // Apply realtime session updates to merged data
  useEffect(() => {
    if (realtimeSessions.length > 0) {
      setMergedSessions((prev) => {
        const updated = [...prev];

        realtimeSessions.forEach((session) => {
          const index = updated.findIndex((s) => s.id === session.id);
          if (index >= 0) {
            // Update existing session
            updated[index] = session;
            console.log(`🔄 PATIENT PAGE - Updated session: ${session.id}`);
          } else {
            // Add new session
            updated.push(session);
            console.log(`➕ PATIENT PAGE - Added new session: ${session.id}`);
          }
        });

        return updated;
      });
    }
  }, [realtimeSessions]);

  // Apply realtime room updates to merged data
  useEffect(() => {
    if (realtimeRooms.length > 0) {
      setMergedRooms((prev) => {
        const updated = [...prev];

        realtimeRooms.forEach((room) => {
          const index = updated.findIndex((r) => r.id === room.id);
          if (index >= 0) {
            // Update existing room
            updated[index] = room;
            console.log(
              `🔄 PATIENT PAGE - Updated room: ${room.id} connected: ${room.connected}`
            );
          } else {
            // Add new room
            updated.push(room);
            console.log(`➕ PATIENT PAGE - Added new room: ${room.id}`);
          }
        });

        return updated;
      });
    }
  }, [realtimeRooms]);

  useEffect(() => {
    // Set error if either realtime connection has issues
    if (sessionsError || roomsError) {
      setError(sessionsError || roomsError || null);
    } else {
      setError(null);
    }
  }, [sessionsError, roomsError]);

  const fetchPatientData = async () => {
    try {
      const response = await patientService.getById(patientId);
      if (response.error || !response.data) {
        setError("Patient not found");
        return;
      }
      setPatient(response.data);
    } catch (err) {
      setError("Failed to load patient data");
    } finally {
      setLoading(false);
    }
  };

  const fetchInitialData = async () => {
    try {
      setDataLoading(true);

      // Fetch sessions with rooms (this gives us both sessions and rooms data)
      const sessionsResponse = await streamingService.getSessionsWithRooms();
      if (sessionsResponse.data) {
        // Extract sessions
        const sessions = sessionsResponse.data.map((sessionWithRooms) => ({
          id: sessionWithRooms.id,
          patient_id: sessionWithRooms.patient_id,
          status: sessionWithRooms.status,
          started_at: sessionWithRooms.started_at,
          ended_at: sessionWithRooms.ended_at,
          created_at: sessionWithRooms.started_at, // Fallback
          updated_at: sessionWithRooms.started_at, // Fallback
        }));

        // Extract all rooms from all sessions with proper type mapping
        const rooms: StreamingRoom[] = sessionsResponse.data.flatMap(
          (sessionWithRooms) =>
            sessionWithRooms.streaming_rooms.map((room) => ({
              id: room.id,
              patient_id: sessionWithRooms.patient_id,
              room_id: room.room_id,
              session_id: room.session_id,
              device_name: room.device_name || "",
              connected: room.connected,
              started_at: room.created_at, // Use created_at as started_at
              ended_at: room.ended_at,
              last_seen: room.updated_at, // Use updated_at as last_seen
              created_at: room.created_at,
              updated_at: room.updated_at,
            }))
        );

        setInitialSessions(sessions);
        setInitialRooms(rooms);
        console.log(
          `📥 PATIENT PAGE - Loaded ${sessions.length} initial sessions, ${rooms.length} initial rooms`
        );
      }
    } catch (err) {
      console.error("Failed to load initial data:", err);
      setError("Failed to load streaming data");
    } finally {
      setDataLoading(false);
    }
  };

  const handleStartStream = () => {
    clearStreamingError();
    startStreaming(patientId);
  };

  const handleStopStream = () => {
    stopStreaming();
  };

  const handleReconnect = () => {
    clearStreamingError();
    reconnect();
  };

  const getConnectionStatus = () => {
    if (isConnecting || isReconnecting) return "Connecting...";
    if (isStreaming) return "Connected";
    if (streamingError) return "Error";
    return "Disconnected";
  };

  const getStatusColor = () => {
    if (isConnecting || isReconnecting) return "text-yellow-600";
    if (isStreaming) return "text-green-600";
    if (streamingError) return "text-red-600";
    return "text-gray-600";
  };

  if (loading) {
    return (
      <div className="container mx-auto p-6">
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading patient stream...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6">
      {/* Navigation Header */}
      <div className="flex items-center gap-4 mb-6">
        <Button
          onClick={() => router.push("/streamingDash")}
          variant="outline"
          size="sm"
          className="flex items-center gap-2"
        >
          <ArrowLeftIcon className="h-4 w-4" />
          Back to Dashboard
        </Button>

        <div className="flex-1">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
            <VideoCameraIcon className="h-8 w-8 text-blue-600" />
            {patient
              ? `${patient.first_name} ${patient.last_name}`
              : "Patient Stream"}
          </h1>
          <p className="text-gray-600 mt-1">
            Live streaming session with realtime updates
            {selectedRoomId && (
              <span className="ml-2 text-blue-600 font-medium">
                • Room: {selectedRoomId.split("-")[0]}...
              </span>
            )}
            <span className="ml-2 text-gray-500">
              •{" "}
              {
                mergedSessions.filter(
                  (s: StreamingSession) =>
                    s.patient_id === patientId && s.status === "active"
                ).length
              }
              /
              {
                mergedSessions.filter(
                  (s: StreamingSession) => s.patient_id === patientId
                ).length
              }{" "}
              sessions active •{" "}
              {
                mergedRooms.filter(
                  (r: StreamingRoom) =>
                    r.patient_id === patientId && r.connected
                ).length
              }
              /
              {
                mergedRooms.filter(
                  (r: StreamingRoom) => r.patient_id === patientId
                ).length
              }{" "}
              rooms connected
            </span>
          </p>
        </div>

        <div className="flex items-center gap-2">
          <SignalIcon className={`h-5 w-5 ${getStatusColor()}`} />
          <span className={`text-sm font-medium ${getStatusColor()}`}>
            {getConnectionStatus()}
          </span>
        </div>
      </div>

      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-red-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-red-700">{error}</p>
            <Button
              onClick={() => {
                setError(null);
                fetchPatientData();
              }}
              variant="outline"
              size="sm"
              className="mt-2"
            >
              Retry
            </Button>
          </div>
        </div>
      )}

      {/* Realtime connection warnings */}
      {(!sessionsConnected || !roomsConnected) && (
        <div className="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-yellow-700">
              Realtime connection issues detected. Some data may not be live.
            </p>
            <div className="text-sm text-yellow-600 mt-1">
              {!sessionsConnected && (
                <div>• Sessions realtime: Disconnected</div>
              )}
              {!roomsConnected && <div>• Rooms realtime: Disconnected</div>}
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Video Stream */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">Live Video Stream</h3>
                <div className="flex items-center gap-2">
                  {isStreaming && (
                    <Badge className="bg-red-500 text-white animate-pulse">
                      ● LIVE
                    </Badge>
                  )}
                  {isReconnecting && (
                    <Badge variant="outline">
                      Reconnecting... ({reconnectAttempts}/5)
                    </Badge>
                  )}
                </div>
              </div>
            </CardHeader>

            <CardContent>
              <div className="relative aspect-video bg-gray-900 rounded-lg overflow-hidden">
                <video
                  ref={videoRef}
                  className="w-full h-full object-contain"
                  autoPlay
                  playsInline
                  controls={false}
                />

                {!isStreaming && !isConnecting && !isReconnecting && (
                  <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-75">
                    <div className="text-center text-white">
                      <VideoCameraIcon className="h-16 w-16 mx-auto mb-4 opacity-50" />
                      <p className="text-lg font-medium">Camera Ready</p>
                      <p className="text-sm opacity-75">
                        Start watching to view live camera feed
                      </p>
                    </div>
                  </div>
                )}

                {(isConnecting || isReconnecting) && (
                  <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-75">
                    <div className="text-center text-white">
                      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-400 mx-auto mb-4"></div>
                      <p className="text-lg font-medium">
                        {isReconnecting
                          ? "Reconnecting to camera"
                          : "Connecting to camera"}
                        ...
                      </p>
                      {isReconnecting && (
                        <p className="text-sm opacity-75 mt-2">
                          Attempt {reconnectAttempts} of{" "}
                          {maxReconnectionAttempts}
                        </p>
                      )}
                    </div>
                  </div>
                )}
              </div>

              {/* Enhanced Connection Status */}
              <ConnectionStatus
                isConnected={isStreaming}
                isConnecting={isConnecting}
                isReconnecting={isReconnecting}
                error={streamingError}
                connectionQuality={connectionQuality}
                reconnectionAttempts={reconnectAttempts}
                maxReconnectionAttempts={maxReconnectionAttempts}
                reconnectionCountdown={reconnectionCountdown}
                reconnectionProgress={reconnectionProgress}
                userFriendlyStatus={userFriendlyStatus}
                canManualRetry={canManualRetry}
                isUserCancelledReconnection={isUserCancelledReconnection}
                onReconnect={reconnect}
                onCancelReconnection={cancelReconnection}
                onStopStreaming={handleStopStream}
              />

              {/* Stream Controls */}
              <div className="flex items-center justify-center gap-4 mt-4">
                {!isStreaming ? (
                  <Button
                    onClick={handleStartStream}
                    disabled={isConnecting}
                    className="flex items-center gap-2"
                  >
                    <PlayIcon className="h-4 w-4" />
                    Start Watching
                  </Button>
                ) : (
                  <Button
                    onClick={handleStopStream}
                    variant="outline"
                    className="flex items-center gap-2"
                  >
                    <StopIcon className="h-4 w-4" />
                    Stop Watching
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Side Panel */}
        <div className="space-y-6">
          {/* Patient Info */}
          {patient && (
            <Card>
              <CardHeader>
                <h3 className="text-lg font-semibold">Patient Information</h3>
              </CardHeader>
              <CardContent className="space-y-3">
                <div>
                  <label className="text-sm font-medium text-gray-500">
                    Name
                  </label>
                  <p className="text-gray-900">
                    {patient.first_name} {patient.last_name}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">
                    Date of Birth
                  </label>
                  <p className="text-gray-900">
                    {new Date(patient.date_of_birth).toLocaleDateString()}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">
                    Gender
                  </label>
                  <p className="text-gray-900 capitalize">{patient.gender}</p>
                </div>
                {patient.email && (
                  <div>
                    <label className="text-sm font-medium text-gray-500">
                      Email
                    </label>
                    <p className="text-gray-900">{patient.email}</p>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          {/* All Sessions with Expandable Rooms */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Patient Sessions</h3>
              <p className="text-sm text-gray-500">
                Click on a session to expand and view rooms inside it
              </p>
            </CardHeader>
            <CardContent>
              {(() => {
                // Get ALL sessions for this patient (not just active ones)
                const patientSessions = mergedSessions.filter(
                  (s: StreamingSession) => s.patient_id === patientId
                );

                if (patientSessions.length === 0) {
                  return (
                    <p className="text-gray-500 text-sm">
                      No sessions found for this patient.
                    </p>
                  );
                }

                return (
                  <div className="space-y-3">
                    {patientSessions.map((session: StreamingSession) => {
                      const isExpanded = isSessionExpanded(session.id);
                      // Get rooms that belong to this session
                      const sessionRooms = mergedRooms.filter(
                        (r: StreamingRoom) => r.session_id === session.id
                      );

                      return (
                        <div
                          key={session.id}
                          className="border border-gray-200 rounded-lg overflow-hidden"
                        >
                          {/* Session Header - Always Visible & Clickable */}
                          <div
                            className="p-4 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors border-b border-gray-200"
                            onClick={() => toggleSessionExpansion(session.id)}
                          >
                            <div className="flex items-center justify-between">
                              <div className="flex items-center space-x-3">
                                <div className="flex items-center">
                                  {isExpanded ? (
                                    <ChevronUpIcon className="h-5 w-5 text-gray-500 transition-transform" />
                                  ) : (
                                    <ChevronDownIcon className="h-5 w-5 text-gray-500 transition-transform" />
                                  )}
                                </div>
                                <div>
                                  <h4 className="text-sm font-medium text-gray-900">
                                    Session {session.created_at}...
                                  </h4>
                                  <p className="text-xs text-gray-500">
                                    {sessionRooms.length} room
                                    {sessionRooms.length !== 1 ? "s" : ""}
                                    {sessionRooms.some((r) => r.connected) &&
                                      ` • ${
                                        sessionRooms.filter((r) => r.connected)
                                          .length
                                      } connected`}
                                  </p>
                                </div>
                              </div>

                              <div className="flex items-center space-x-2">
                                <Badge
                                  variant={
                                    session.status === "active"
                                      ? "default"
                                      : "secondary"
                                  }
                                  className={
                                    session.status === "active"
                                      ? "bg-green-500 text-white"
                                      : session.status === "ended"
                                      ? "bg-gray-500 text-white"
                                      : "bg-red-500 text-white"
                                  }
                                >
                                  {session.status}
                                </Badge>
                                <span className="text-xs text-gray-400">
                                  {isExpanded
                                    ? "Click to collapse"
                                    : "Click to expand"}
                                </span>
                              </div>
                            </div>

                            <div className="mt-2 text-xs text-gray-600">
                              <span>
                                Started:{" "}
                                {new Date(session.started_at).toLocaleString()}
                              </span>
                              {session.ended_at && (
                                <span className="ml-4">
                                  Ended:{" "}
                                  {new Date(session.ended_at).toLocaleString()}
                                </span>
                              )}
                            </div>
                          </div>

                          {/* Expandable Rooms Section */}
                          {isExpanded && (
                            <div className="border-t border-gray-200 bg-white animate-in slide-in-from-top-2 duration-200">
                              {sessionRooms.length === 0 ? (
                                <div className="p-4 text-sm text-gray-500 text-center">
                                  No rooms found for this session
                                </div>
                              ) : (
                                <div className="p-4 space-y-3">
                                  <h5 className="text-sm font-medium text-gray-700 mb-3 flex items-center">
                                    <VideoCameraIcon className="h-4 w-4 mr-2 text-gray-500" />
                                    Rooms in this session:
                                  </h5>
                                  {sessionRooms.map((room: StreamingRoom) => (
                                    <div
                                      key={room.id}
                                      className={`p-3 rounded-lg border cursor-pointer transition-all ${
                                        selectedRoomId === room.room_id
                                          ? "border-blue-300 bg-blue-50 shadow-sm"
                                          : "border-gray-200 bg-gray-50 hover:bg-gray-100"
                                      }`}
                                      onClick={(e) => {
                                        e.stopPropagation(); // Prevent session collapse
                                        setSelectedRoomId(room.room_id);
                                      }}
                                      title="Click to select this room for streaming"
                                    >
                                      <div className="flex items-center justify-between mb-2">
                                        <div className="flex items-center space-x-2">
                                          <VideoCameraIcon className="h-4 w-4 text-gray-500" />
                                          <span className="text-sm font-medium">
                                            {room.device_name ||
                                              `Room ${
                                                room.room_id.split("-")[0]
                                              }...`}
                                          </span>
                                          {selectedRoomId === room.room_id && (
                                            <span className="text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded">
                                              Selected
                                            </span>
                                          )}
                                        </div>

                                        <div className="flex items-center space-x-2">
                                          <div
                                            className={`h-2 w-2 rounded-full ${
                                              room.connected
                                                ? "bg-green-500"
                                                : "bg-gray-400"
                                            }`}
                                          />
                                          <Badge
                                            variant={
                                              room.connected
                                                ? "default"
                                                : "secondary"
                                            }
                                            className={
                                              room.connected
                                                ? "bg-green-500 text-white"
                                                : ""
                                            }
                                          >
                                            {room.connected
                                              ? "Connected"
                                              : "Disconnected"}
                                          </Badge>
                                        </div>
                                      </div>

                                      <div className="text-xs text-gray-600 space-y-1 ml-6">
                                        <p>Room ID: {room.room_id}</p>
                                        <p>
                                          Started:{" "}
                                          {new Date(
                                            room.started_at
                                          ).toLocaleString()}
                                        </p>
                                        <p>
                                          Last Seen:{" "}
                                          {new Date(
                                            room.last_seen
                                          ).toLocaleString()}
                                        </p>
                                        {room.device_name && (
                                          <p>Device: {room.device_name}</p>
                                        )}
                                      </div>
                                    </div>
                                  ))}
                                </div>
                              )}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                );
              })()}
            </CardContent>
          </Card>

          {/* Connection Info */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Connection Status</h3>
            </CardHeader>
            <CardContent className="text-sm space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-500">Stream Status:</span>
                <span className={getStatusColor()}>
                  {getConnectionStatus()}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Reconnect Attempts:</span>
                <span>{reconnectAttempts}/5</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Realtime Sessions:</span>
                <span
                  className={
                    sessionsConnected ? "text-green-600" : "text-red-600"
                  }
                >
                  {sessionsConnected ? "Connected" : "Disconnected"}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Realtime Rooms:</span>
                <span
                  className={roomsConnected ? "text-green-600" : "text-red-600"}
                >
                  {roomsConnected ? "Connected" : "Disconnected"}
                </span>
              </div>
              {currentSession && currentSession.id && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Session ID:</span>
                  <span className="font-mono text-xs">
                    {currentSession.id.split("-")[0]}...
                  </span>
                </div>
              )}
              {selectedRoomId && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Selected Room:</span>
                  <span className="font-mono text-xs">
                    {selectedRoomId.split("-")[0]}...
                  </span>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
