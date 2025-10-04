"use client";

import { ConnectionStatus } from "@/components/ConnectionStatus";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useRealtimeRooms } from "@/hooks/useRealtime";
import { useStreaming } from "@/hooks/useStreaming";
import { ambulanceStreamingService } from "@/services";
import type {
  AmbulanceSession,
  AmbulanceStreamingStatus,
  CameraRoom,
} from "@/types";
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
import { useCallback, useEffect, useState } from "react";

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
  const [initialSessions, setInitialSessions] = useState<AmbulanceSession[]>(
    []
  );
  // CameraRoom from new API doesn't include patient_id, so we augment it locally
  type PatientCameraRoom = CameraRoom & { patient_id: string };
  // AmbulanceSession might include patient_id in some contexts
  type PatientAmbulanceSession = AmbulanceSession & { patient_id?: string };

  const [initialRooms, setInitialRooms] = useState<PatientCameraRoom[]>([]);
  const [, setDataLoading] = useState(true);

  // Merged state for display - combines initial data with realtime updates
  const [mergedSessions, setMergedSessions] = useState<AmbulanceSession[]>([]);
  const [mergedRooms, setMergedRooms] = useState<PatientCameraRoom[]>([]);

  // Realtime hooks for live updates (rooms remain realtime)
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

  const fetchInitialData = useCallback(async () => {
    try {
      setDataLoading(true);
      // Get all ambulance sessions
      const sessionsResponse =
        await ambulanceStreamingService.getAmbulanceSessions({});

      if (sessionsResponse.data) {
        // Get all sessions without patient filtering
        const sessions = sessionsResponse.data;

        // Get all camera rooms from ambulance streaming status
        const statusResponse =
          await ambulanceStreamingService.getAmbulancesStreamingStatus();
        const roomsAccumulator: PatientCameraRoom[] = [];

        if (statusResponse.data && Array.isArray(statusResponse.data)) {
          statusResponse.data.forEach((status: AmbulanceStreamingStatus) => {
            if (status.camera_rooms && Array.isArray(status.camera_rooms)) {
              status.camera_rooms.forEach((room: CameraRoom) => {
                roomsAccumulator.push({
                  ...room,
                  patient_id: "", // No specific patient context needed
                });
              });
            }
          });
        }

        setInitialSessions(sessions);
        setInitialRooms(roomsAccumulator);
        console.log(
          `📥 ROOM VIEWER - Loaded ${sessions.length} initial sessions, ${roomsAccumulator.length} initial rooms`
        );
      }
    } catch (err) {
      console.error("Failed to load initial data:", err);
      setError("Failed to load streaming data");
    } finally {
      setDataLoading(false);
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    // Fetch initial data for all rooms
    fetchInitialData();
  }, [fetchInitialData]);

  // Initialize merged data when initial data is loaded
  useEffect(() => {
    setMergedSessions(initialSessions);
    setMergedRooms(initialRooms);
    console.log(
      `🔄 PATIENT PAGE - Initial data loaded: ${initialSessions.length} sessions, ${initialRooms.length} rooms`
    );
  }, [initialSessions, initialRooms]);

  // NOTE: session-level realtime events are not available on the new API.
  // We continue to rely on initialSessions + room-level realtime updates
  // to infer changes to session state where possible.

  // Apply realtime room updates to merged data (rooms are PatientCameraRoom)
  useEffect(() => {
    if (realtimeRooms.length > 0) {
      setMergedRooms((prev) => {
        const updated = [...prev];

        realtimeRooms.forEach((room) => {
          // Try to find existing by id
          const index = updated.findIndex((r) => r.id === room.id);
          const augmented: PatientCameraRoom = {
            ...room,
            // No specific patient context needed for room viewer
            patient_id: (index >= 0 && updated[index].patient_id) || "",
          };

          if (index >= 0) {
            // Update existing room
            updated[index] = { ...updated[index], ...augmented };
            console.log(
              `🔄 ROOM VIEWER - Updated room: ${room.id} connected: ${room.connected}`
            );
          } else {
            // Add new room
            updated.push(augmented);
            console.log(`➕ ROOM VIEWER - Added new room: ${room.id}`);
          }
        });

        return updated;
      });
    }
  }, [realtimeRooms]);

  useEffect(() => {
    // Set error if realtime rooms connection has issues
    if (roomsError) {
      setError(roomsError || null);
    } else {
      setError(null);
    }
  }, [roomsError]);

  const handleStartStream = () => {
    clearStreamingError();
    startStreaming(patientId);
  };

  const handleStopStream = () => {
    stopStreaming();
  };

  // Reconnect functionality available via reconnect() from useStreaming

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
        {/* Loading Header */}
        <div className="flex items-center gap-4 mb-6">
          <div className="h-10 w-24 bg-gray-200 rounded-md animate-pulse"></div>
          <div className="flex-1">
            <div className="h-8 w-64 bg-gray-200 rounded animate-pulse mb-2"></div>
            <div className="h-4 w-96 bg-gray-100 rounded animate-pulse"></div>
          </div>
          <div className="h-6 w-20 bg-gray-200 rounded animate-pulse"></div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Loading Video Stream */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="h-6 w-40 bg-gray-200 rounded animate-pulse"></div>
                  <div className="h-6 w-16 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="relative aspect-video bg-gradient-to-br from-purple-50 to-violet-50 rounded-lg overflow-hidden border border-purple-100">
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="text-center">
                      <div className="relative mb-6">
                        {/* Main spinner */}
                        <div className="animate-spin rounded-full h-16 w-16 border-4 border-purple-200 border-t-purple-600 mx-auto"></div>
                        {/* Pulse effect */}
                        <div className="absolute inset-0 animate-ping rounded-full h-16 w-16 border-2 border-purple-400 opacity-30 mx-auto"></div>
                      </div>
                      <h3 className="text-xl font-semibold text-purple-900 mb-2">
                        Loading Patient Stream
                      </h3>
                      <p className="text-purple-700">
                        Preparing camera connection and patient data...
                      </p>
                      <div className="mt-4 flex items-center justify-center space-x-2">
                        <div className="h-2 w-2 bg-purple-500 rounded-full animate-bounce"></div>
                        <div
                          className="h-2 w-2 bg-purple-500 rounded-full animate-bounce"
                          style={{ animationDelay: "0.1s" }}
                        ></div>
                        <div
                          className="h-2 w-2 bg-purple-500 rounded-full animate-bounce"
                          style={{ animationDelay: "0.2s" }}
                        ></div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Loading Controls */}
                <div className="flex items-center justify-center gap-4 mt-4">
                  <div className="h-10 w-32 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Loading Side Panel */}
          <div className="space-y-6">
            {/* Loading Patient Info */}
            <Card>
              <CardHeader>
                <div className="h-6 w-36 bg-gray-200 rounded animate-pulse"></div>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="space-y-2">
                  <div className="h-4 w-16 bg-gray-100 rounded animate-pulse"></div>
                  <div className="h-5 w-32 bg-gray-200 rounded animate-pulse"></div>
                </div>
                <div className="space-y-2">
                  <div className="h-4 w-20 bg-gray-100 rounded animate-pulse"></div>
                  <div className="h-5 w-24 bg-gray-200 rounded animate-pulse"></div>
                </div>
                <div className="space-y-2">
                  <div className="h-4 w-12 bg-gray-100 rounded animate-pulse"></div>
                  <div className="h-5 w-16 bg-gray-200 rounded animate-pulse"></div>
                </div>
              </CardContent>
            </Card>

            {/* Loading Sessions */}
            <Card>
              <CardHeader>
                <div className="h-6 w-32 bg-gray-200 rounded animate-pulse mb-2"></div>
                <div className="h-4 w-48 bg-gray-100 rounded animate-pulse"></div>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {[1, 2].map((i) => (
                    <div
                      key={i}
                      className="border border-gray-200 rounded-lg p-4"
                    >
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-3">
                          <div className="h-5 w-5 bg-gray-200 rounded animate-pulse"></div>
                          <div className="h-4 w-24 bg-gray-200 rounded animate-pulse"></div>
                        </div>
                        <div className="h-6 w-16 bg-gray-200 rounded animate-pulse"></div>
                      </div>
                      <div className="h-3 w-40 bg-gray-100 rounded animate-pulse"></div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Loading Connection Info */}
            <Card>
              <CardHeader>
                <div className="h-6 w-32 bg-gray-200 rounded animate-pulse"></div>
              </CardHeader>
              <CardContent className="space-y-3">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="flex justify-between">
                    <div className="h-4 w-24 bg-gray-100 rounded animate-pulse"></div>
                    <div className="h-4 w-20 bg-gray-200 rounded animate-pulse"></div>
                  </div>
                ))}
              </CardContent>
            </Card>
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
            Camera Room Viewer
          </h1>
          <p className="text-gray-600 mt-1">
            Live streaming from multiple camera rooms
            {selectedRoomId && (
              <span className="ml-2 text-blue-600 font-medium">
                • Active Room: Room Name
              </span>
            )}
            <span className="ml-2 text-gray-500">
              • {mergedRooms.filter((r) => r.connected).length}/
              {mergedRooms.length} rooms online
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
                fetchInitialData();
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
      {!roomsConnected && (
        <div className="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-yellow-700">
              Realtime connection issues detected. Some data may not be live.
            </p>
            <div className="text-sm text-yellow-600 mt-1">
              <div>• Sessions realtime: unavailable with new API</div>
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
                      {selectedRoomId ? (
                        <>
                          <p className="text-lg font-medium">Camera Ready</p>
                          <p className="text-sm opacity-75 mb-2">
                            Room: Room Name
                          </p>
                          <p className="text-sm opacity-75">
                            Start watching to view live camera feed
                          </p>
                        </>
                      ) : (
                        <>
                          <p className="text-lg font-medium">Select a Room</p>
                          <p className="text-sm opacity-75">
                            Choose a camera room from the sidebar to start
                            watching
                          </p>
                        </>
                      )}
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
                    disabled={isConnecting || !selectedRoomId}
                    className="flex items-center gap-2"
                  >
                    <PlayIcon className="h-4 w-4" />
                    {selectedRoomId ? "Start Watching" : "Select Room First"}
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

                {selectedRoomId && (
                  <div className="text-xs text-gray-500 text-center">
                    <p>Watching: Room Name</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Side Panel */}
        <div className="space-y-6">
          {/* Room Selection */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Available Rooms</h3>
              <p className="text-sm text-gray-500">
                Select a room to watch its live stream
              </p>
            </CardHeader>
            <CardContent>
              {(() => {
                // Get all unique rooms from merged data
                const allRooms = mergedRooms;

                if (allRooms.length === 0) {
                  return (
                    <p className="text-gray-500 text-sm">
                      No camera rooms available.
                    </p>
                  );
                }

                return (
                  <div className="space-y-3">
                    {allRooms.map((room: PatientCameraRoom) => (
                      <div
                        key={room.id}
                        className={`p-3 rounded-lg border cursor-pointer transition-all ${
                          selectedRoomId === room.room_id
                            ? "border-blue-300 bg-blue-50 shadow-sm"
                            : "border-gray-200 bg-gray-50 hover:bg-gray-100"
                        }`}
                        onClick={() => {
                          setSelectedRoomId(room.room_id);
                          // Automatically start streaming when room is selected
                          if (!isStreaming) {
                            handleStartStream();
                          }
                        }}
                        title="Click to select this room for streaming"
                      >
                        <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center space-x-2">
                            <VideoCameraIcon className="h-5 w-5 text-gray-500" />
                            <div>
                              <span className="text-sm font-medium">
                                {room.room_id || "Room Name"}
                              </span>
                              {selectedRoomId === room.room_id && (
                                <span className="text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded ml-2">
                                  Active
                                </span>
                              )}
                            </div>
                          </div>

                          <div className="flex items-center space-x-2">
                            <div
                              className={`h-3 w-3 rounded-full ${
                                room.connected
                                  ? "bg-green-500 animate-pulse"
                                  : "bg-gray-400"
                              }`}
                            />
                            <Badge
                              variant={room.connected ? "default" : "secondary"}
                              className={
                                room.connected ? "bg-green-500 text-white" : ""
                              }
                            >
                              {room.connected ? "Online" : "Offline"}
                            </Badge>
                          </div>
                        </div>

                        <div className="text-xs text-gray-600 space-y-1">
                          {room.camera_id && <p>Camera ID: {room.camera_id}</p>}
                          <p>
                            Last Seen:{" "}
                            {room.last_seen
                              ? new Date(room.last_seen).toLocaleString()
                              : "Never"}
                          </p>
                          {room.session_id && <p>Session Active</p>}
                        </div>
                      </div>
                    ))}
                  </div>
                );
              })()}
            </CardContent>
          </Card>

          {/* All Sessions with Expandable Rooms */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">All Sessions</h3>
              <p className="text-sm text-gray-500">
                Click on a session to expand and view rooms inside it
              </p>
            </CardHeader>
            <CardContent>
              {(() => {
                // Get ALL sessions (no patient filtering)
                const allSessions = mergedSessions;

                if (allSessions.length === 0) {
                  return (
                    <p className="text-gray-500 text-sm">No sessions found.</p>
                  );
                }

                return (
                  <div className="space-y-3">
                    {allSessions.map((session: AmbulanceSession) => {
                      const isExpanded = isSessionExpanded(session.id);
                      // Get rooms that belong to this session
                      const sessionRooms = mergedRooms.filter(
                        (r: PatientCameraRoom) => r.session_id === session.id
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
                                    session.is_active ? "default" : "secondary"
                                  }
                                  className={
                                    session.is_active
                                      ? "bg-green-500 text-white"
                                      : session.ended_at
                                      ? "bg-gray-500 text-white"
                                      : "bg-red-500 text-white"
                                  }
                                >
                                  {session.is_active ? "active" : "ended"}
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
                                  {sessionRooms.map(
                                    (room: PatientCameraRoom) => (
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
                                              {room.camera_id || "Room Name"}
                                            </span>
                                            {selectedRoomId ===
                                              room.room_id && (
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
                                          {room.camera_id && (
                                            <p>Camera ID: {room.camera_id}</p>
                                          )}
                                          <p>
                                            Started:{" "}
                                            {room.connection_started_at
                                              ? new Date(
                                                  room.connection_started_at
                                                ).toLocaleString()
                                              : "—"}
                                          </p>
                                          <p>
                                            Last Seen:{" "}
                                            {room.last_seen
                                              ? new Date(
                                                  room.last_seen
                                                ).toLocaleString()
                                              : "—"}
                                          </p>
                                        </div>
                                      </div>
                                    )
                                  )}
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
                <span className="text-gray-500">
                  Unavailable (use rooms realtime)
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
              {selectedRoomId && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Selected Room:</span>
                  <span className="text-gray-900">Room Name</span>
                </div>
              )}
              {currentSession && currentSession.id && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Session Status:</span>
                  <span className="text-green-600">Active</span>
                </div>
              )}
              <div className="flex justify-between">
                <span className="text-gray-500">Available Rooms:</span>
                <span>{mergedRooms.length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Online Rooms:</span>
                <span className="text-green-600">
                  {mergedRooms.filter((r) => r.connected).length}
                </span>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
