"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import type { AmbulanceWithSession } from "@/hooks";
import {
  useAmbulanceStreaming,
  useRealtimeAmbulanceSessions,
  useRealtimeRooms,
} from "@/hooks";
import { useAuth } from "@/hooks/useAuth";
import type { CameraRoom } from "@/types";
import {
  ArrowPathIcon,
  CameraIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  SignalIcon,
  SignalSlashIcon,
  StopIcon,
  UserIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

// Badge component following UI design system rules
const Badge = ({
  children,
  variant = "default",
  className = "",
}: {
  children: React.ReactNode;
  variant?:
    | "default"
    | "secondary"
    | "outline"
    | "success"
    | "warning"
    | "danger"
    | "live";
  className?: string;
}) => {
  const baseClasses =
    "inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold transition-all duration-200";
  const variantClasses = {
    default: "bg-blue-100 text-blue-800 border border-blue-200",
    secondary: "bg-slate-100 text-slate-700 border border-slate-200",
    outline: "border border-blue-200 text-blue-700 bg-white hover:bg-blue-50",
    success: "bg-emerald-100 text-emerald-800 border border-emerald-200",
    warning: "bg-amber-100 text-amber-800 border border-amber-200",
    danger: "bg-red-100 text-red-800 border border-red-200",
    live: "bg-red-500 text-white shadow-lg animate-pulse border-2 border-red-400",
  };

  return (
    <span className={`${baseClasses} ${variantClasses[variant]} ${className}`}>
      {children}
    </span>
  );
};

export default function LiveStreamingDashboard() {
  const { user, isAuthenticated, isLoading } = useAuth();
  const {
    ambulances,
    loading,
    error,
    endSession,
    clearError,
    totalSessions,
    activeSessions,
    connectedRooms,
  } = useAmbulanceStreaming();

  // Realtime hooks for live data
  const {
    sessions: realtimeSessions,
    isConnected: sessionsConnected,
    error: sessionsError,
  } = useRealtimeAmbulanceSessions({
    enabled: true,
  });

  const { rooms: realtimeRooms, isConnected: roomsConnected } =
    useRealtimeRooms({
      enabled: true,
    });

  // Use ambulances data directly (real-time updates are handled in the hook)
  const [selectedAmbulance, setSelectedAmbulance] = useState<string | null>(
    null
  );

  // Real-time updates are now handled directly in useAmbulanceStreaming hook
  // No need for manual data merging

  const router = useRouter();
  const [endingSession, setEndingSession] = useState<string | null>(null);

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push("/");
    }
  }, [isAuthenticated, isLoading, router]);

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="relative mx-auto w-16 h-16 mb-8">
              <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
              <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
            </div>
            <h3 className="text-xl font-semibold text-slate-800 mb-2">
              Loading Dashboard
            </h3>
            <p className="text-slate-600">
              Please wait while we set up your streaming dashboard...
            </p>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  const handleViewStream = (ambulanceId: string) => {
    router.push(`/streamingDash/${ambulanceId}`);
  };

  const handleEndSession = async (sessionId: string) => {
    try {
      setEndingSession(sessionId);
      await endSession(sessionId);
    } catch (err) {
      console.error("Error ending session:", err);
    } finally {
      setEndingSession(null);
    }
  };

  const handleJoinRoom = (roomId: string, ambulanceId: string) => {
    // Navigate to streaming room with room ID parameter
    router.push(`/streamingDash/${ambulanceId}?room=${roomId}`);
  };

  const getSessionStatusBadge = (ambulance: AmbulanceWithSession) => {
    if (!ambulance.session) {
      return (
        <Badge variant="secondary">
          <StopIcon className="w-3 h-3" />
          No Session
        </Badge>
      );
    }

    if (!ambulance.session.is_active) {
      return (
        <Badge variant="secondary">
          <StopIcon className="w-3 h-3" />
          Ended
        </Badge>
      );
    }

    const connectedRooms = ambulance.cameras.filter(
      (room: CameraRoom) => room.connected
    ).length;
    const totalRooms = ambulance.cameras.length;

    if (connectedRooms === 0) {
      return (
        <Badge variant="secondary">
          <SignalSlashIcon className="w-3 h-3" />
          Disconnected
        </Badge>
      );
    }

    if (connectedRooms === totalRooms && totalRooms > 0) {
      return (
        <Badge variant="live">
          <div className="w-2 h-2 bg-white rounded-full animate-pulse" />
          LIVE
        </Badge>
      );
    }

    return (
      <Badge variant="warning">
        <SignalIcon className="w-3 h-3" />
        {connectedRooms}/{totalRooms} Connected
      </Badge>
    );
  };

  const getRoomStatusBadge = (room: CameraRoom) => {
    if (room.connected) {
      return (
        <Badge variant="success" className="text-xs">
          <SignalIcon className="w-3 h-3" />
          Connected
        </Badge>
      );
    } else {
      return (
        <Badge variant="secondary" className="text-xs">
          <SignalSlashIcon className="w-3 h-3" />
          Disconnected
        </Badge>
      );
    }
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <div className="relative mx-auto w-16 h-16 mb-8">
              <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
              <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
            </div>
            <h3 className="text-xl font-semibold text-slate-800 mb-2">
              Loading Live Streams
            </h3>
            <p className="text-slate-600">
              Connecting to camera feeds and ambulance sessions...
            </p>
            <div className="mt-4 flex justify-center">
              <div className="flex space-x-1">
                <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
                <div
                  className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"
                  style={{ animationDelay: "0.1s" }}
                ></div>
                <div
                  className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"
                  style={{ animationDelay: "0.2s" }}
                ></div>
              </div>
            </div>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-96">
          <div className="text-center max-w-md">
            <div className="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-6">
              <ExclamationTriangleIcon className="w-8 h-8 text-red-600" />
            </div>
            <h3 className="text-xl font-semibold text-slate-800 mb-3">
              Connection Failed
            </h3>
            <p className="text-slate-600 mb-6">
              Unable to connect to streaming service. Please check your internet
              connection and try again.
            </p>
            <div className="bg-red-50 border border-red-200 rounded-xl p-4 mb-6">
              <p className="text-red-800 text-sm font-medium">Error Details:</p>
              <p className="text-red-700 text-sm mt-1">{error}</p>
            </div>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Standard page header following UI design system */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <div className="bg-white/20 p-3 rounded-xl backdrop-blur-sm">
                  <VideoCameraIcon className="h-8 w-8 text-white" />
                </div>
                <div>
                  <h1 className="text-3xl font-bold text-white">
                    Live Streaming Dashboard
                  </h1>
                  <p className="text-blue-100 mt-1">
                    Real-time camera monitoring and ambulance session management
                  </p>
                </div>
              </div>
              <div className="hidden lg:flex items-center space-x-6">
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {ambulances.length}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Ambulances
                  </div>
                </div>
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {connectedRooms}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Connected Rooms
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Status bar */}
          <div className="bg-slate-50 px-8 py-4 border-t border-slate-200">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-6">
                <div className="flex items-center space-x-2">
                  <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-sm font-medium text-slate-700">
                    System Online
                  </span>
                </div>
                <div className="flex items-center space-x-2">
                  <CameraIcon className="h-4 w-4 text-blue-600" />
                  <span className="text-sm text-slate-600">
                    {totalSessions} total sessions
                  </span>
                </div>
                {/* Realtime connection status */}
                <div className="flex items-center space-x-2">
                  <div
                    className={`w-3 h-3 rounded-full ${
                      sessionsConnected && roomsConnected
                        ? "bg-green-500 animate-pulse"
                        : "bg-red-500"
                    }`}
                  ></div>
                  <span className="text-sm text-slate-600">
                    Realtime:{" "}
                    {sessionsConnected && roomsConnected
                      ? "Connected"
                      : "Disconnected"}
                  </span>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <span className="text-sm text-slate-500">
                  Live data: {realtimeSessions.length} sessions,{" "}
                  {realtimeRooms.length} rooms
                </span>
              </div>
            </div>
          </div>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-gradient-to-r from-red-50 to-pink-50 border border-red-200 rounded-xl shadow-sm">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-red-500 rounded-lg">
                <StopIcon className="h-5 w-5 text-white" />
              </div>
              <div>
                <p className="text-red-800 font-medium">Connection Error</p>
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            </div>
          </div>
        )}

        {ambulances.length === 0 ? (
          <Card className="border-0 shadow-xl bg-gradient-to-br from-white to-gray-50">
            <CardContent className="text-center py-16">
              <div className="mb-8">
                <div className="mx-auto w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center">
                  <VideoCameraIcon className="h-10 w-10 text-slate-400" />
                </div>
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-3">
                No Active Streams
              </h3>
              <p className="text-slate-600 mb-8 max-w-md mx-auto">
                No ambulances are currently streaming. Active camera feeds will
                appear here automatically.
              </p>
            </CardContent>
          </Card>
        ) : (
          <>
            {/* Stats Bar */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8">
              <div className="flex flex-wrap items-center justify-between gap-6">
                <div className="flex items-center space-x-8">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                      <UserIcon className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-sm text-slate-500">
                        Active Ambulances
                      </p>
                      <p className="text-xl font-semibold text-slate-800">
                        {ambulances.length}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
                      <CameraIcon className="h-5 w-5 text-green-600" />
                    </div>
                    <div>
                      <p className="text-sm text-slate-500">Live Sessions</p>
                      <p className="text-xl font-semibold text-slate-800">
                        {activeSessions}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Ambulance Cards Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {ambulances.map((ambulance: AmbulanceWithSession) => (
                <Card
                  key={ambulance.id}
                  className="bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-200 overflow-hidden"
                >
                  <CardHeader className="border-b border-slate-100 bg-slate-50">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                          <CameraIcon className="h-5 w-5 text-blue-600" />
                        </div>
                        <h3 className="text-lg font-semibold text-slate-800 truncate">
                          {ambulance.ambulance_number}
                        </h3>
                      </div>
                      {getSessionStatusBadge(ambulance)}
                    </div>
                  </CardHeader>

                  <CardContent className="p-6 space-y-4">
                    {ambulance.session ? (
                      <>
                        <div className="bg-blue-50 border border-blue-100 rounded-xl p-4">
                          <div className="flex items-center justify-between text-sm">
                            <div className="flex items-center space-x-2">
                              <CameraIcon className="h-4 w-4 text-blue-600" />
                              <span className="font-medium text-slate-700">
                                Session:{" "}
                                {ambulance.session.is_active
                                  ? "Active"
                                  : "Inactive"}
                              </span>
                            </div>
                            <div className="flex items-center space-x-1 text-slate-500">
                              <ClockIcon className="h-4 w-4" />
                              <span className="text-xs">
                                {new Date(
                                  ambulance.session.started_at
                                ).toLocaleTimeString()}
                              </span>
                            </div>
                          </div>
                        </div>
                        <div className="space-y-3">
                          <div className="flex items-center justify-between text-sm font-medium text-slate-700">
                            <span>Cameras ({ambulance.cameras.length})</span>
                            <span className="text-xs text-slate-500">
                              {
                                ambulance.cameras.filter(
                                  (r: CameraRoom) => r.connected
                                ).length
                              }{" "}
                              connected
                            </span>
                          </div>

                          {ambulance.cameras.map((room: CameraRoom) => (
                            <div
                              key={room.id}
                              onClick={() =>
                                handleJoinRoom(room.room_id, ambulance.id)
                              }
                              className="flex items-center justify-between p-3 bg-slate-50 hover:bg-slate-100 rounded-xl cursor-pointer transition-colors duration-200 border border-slate-200"
                              title={`Click to join room ${room.room_id}`}
                            >
                              <div className="flex items-center space-x-3">
                                <div
                                  className={`w-3 h-3 rounded-full ${
                                    room.connected
                                      ? "bg-green-500 animate-pulse"
                                      : "bg-slate-400"
                                  }`}
                                ></div>
                                <div>
                                  <p className="text-sm font-medium text-slate-800">
                                    {room.device_name ||
                                      room.room_id.split("-")[0]}
                                  </p>
                                  <p className="text-xs text-slate-500">
                                    Room: {room.device_name ?? room.room_id}
                                  </p>
                                </div>
                              </div>
                              <div className="flex items-center space-x-2">
                                {getRoomStatusBadge(room)}
                                <EyeIcon className="h-4 w-4 text-slate-400" />
                              </div>
                            </div>
                          ))}
                        </div>

                        <div className="pt-4 border-t border-slate-200">
                          <div className="flex gap-2">
                            <Button
                              onClick={() => handleViewStream(ambulance.id)}
                              className="flex-1 bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-2 px-4 transition-colors duration-200"
                            >
                              <VideoCameraIcon className="h-4 w-4 mr-2" />
                              View Stream
                            </Button>
                            {ambulance.session.is_active && (
                              <Button
                                onClick={() =>
                                  handleEndSession(ambulance.session!.id)
                                }
                                disabled={
                                  endingSession === ambulance.session!.id
                                }
                                className="bg-red-600 hover:bg-red-700 text-white rounded-xl py-2 px-4 transition-colors duration-200 disabled:opacity-50"
                              >
                                {endingSession === ambulance.session!.id ? (
                                  <>
                                    <ArrowPathIcon className="h-4 w-4 mr-2 animate-spin" />
                                    Ending...
                                  </>
                                ) : (
                                  <>
                                    <StopIcon className="h-4 w-4 mr-2" />
                                    End Session
                                  </>
                                )}
                              </Button>
                            )}
                          </div>
                        </div>
                      </>
                    ) : (
                      <div className="text-center py-8 text-slate-500">
                        <CameraIcon className="h-12 w-12 mx-auto mb-3 text-slate-300" />
                        <p className="font-medium">No active session</p>
                        <p className="text-sm">
                          This ambulance is not currently streaming
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              ))}
            </div>
          </>
        )}
      </div>
    </DashboardLayout>
  );
}
