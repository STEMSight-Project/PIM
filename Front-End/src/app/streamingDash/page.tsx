"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useAuth } from "@/hooks/useAuth";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import type { AmbulanceSession, CameraRoom } from "@/types";
import {
  CameraIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  SignalIcon,
  TruckIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useMemo } from "react";

// Simple Badge component
const Badge = ({
  children,
  variant = "default",
  className = "",
}: {
  children: React.ReactNode;
  variant?: "default" | "secondary" | "success" | "warning" | "live";
  className?: string;
}) => {
  const baseClasses =
    "inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium";
  const variantClasses = {
    default: "bg-blue-100 text-blue-800",
    secondary: "bg-gray-100 text-gray-800",
    success: "bg-green-100 text-green-800",
    warning: "bg-yellow-100 text-yellow-800",
    live: "bg-red-500 text-white animate-pulse",
  };

  return (
    <span className={`${baseClasses} ${variantClasses[variant]} ${className}`}>
      {children}
    </span>
  );
};

// Simple ambulance data structure
interface SimpleAmbulanceData {
  ambulanceId: string;
  ambulanceNumber: string;
  activeSessions: AmbulanceSession[];
  connectedRooms: CameraRoom[];
  totalRooms: CameraRoom[];
}

export default function SimpleStreamingDashboard() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const router = useRouter();

  // Single source of truth - real-time sessions data
  const {
    sessions: realtimeSessions,
    isConnected: realtimeConnected,
    isLoading: realtimeLoading,
    error: realtimeError,
  } = useRealtimeAmbulanceSessions({
    enabled: isAuthenticated,
  });

  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push("/");
    }
  }, [isAuthenticated, authLoading, router]);

  // Process sessions into simple ambulance data
  const ambulancesData = useMemo(() => {
    const ambulanceMap = new Map<string, SimpleAmbulanceData>();

    realtimeSessions.forEach((session) => {
      const ambulanceId = session.ambulance_id;

      if (!ambulanceMap.has(ambulanceId)) {
        ambulanceMap.set(ambulanceId, {
          ambulanceId,
          ambulanceNumber: `AMB-${ambulanceId.substring(0, 3).toUpperCase()}`,
          activeSessions: [],
          connectedRooms: [],
          totalRooms: [],
        });
      }

      const ambulanceData = ambulanceMap.get(ambulanceId)!;

      if (session.is_active) {
        ambulanceData.activeSessions.push(session);
      }

      const sessionRooms = session.camera_rooms || [];

      ambulanceData.totalRooms.push(...sessionRooms);
      ambulanceData.connectedRooms.push(
        ...sessionRooms.filter((room) => room.connected)
      );
    });

    return Array.from(ambulanceMap.values());
  }, [realtimeSessions]);

  const handleViewStream = (ambulanceId: string) => {
    router.push(`/streamingDash/${ambulanceId}`);
  };

  const handleJoinRoom = (roomId: string, ambulanceId: string) => {
    router.push(`/streamingDash/${ambulanceId}?room=${roomId}`);
  };

  if (authLoading || realtimeLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <div className="relative mx-auto w-16 h-16 mb-8">
              <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
              <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
            </div>
            <h3 className="text-xl font-semibold text-slate-800 mb-2">
              Loading Dashboard
            </h3>
            <p className="text-slate-600">Loading streaming data...</p>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Simple Header */}
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
                    Real-time ambulance camera monitoring
                  </p>
                </div>
              </div>
              <div className="hidden lg:flex items-center space-x-6">
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {ambulancesData.length}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Ambulances
                  </div>
                </div>
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {ambulancesData.reduce(
                      (total, amb) => total + amb.connectedRooms.length,
                      0
                    )}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Live Cameras
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Status Bar */}
          <div className="bg-slate-50 px-8 py-4 border-t border-slate-200">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-6">
                <div className="flex items-center space-x-2">
                  <div
                    className={`w-3 h-3 rounded-full ${
                      realtimeConnected
                        ? "bg-green-500 animate-pulse"
                        : "bg-red-500"
                    }`}
                  ></div>
                  <span className="text-sm font-medium text-slate-700">
                    Real-time:{" "}
                    {realtimeConnected ? "Connected" : "Disconnected"}
                  </span>
                </div>
                <div className="flex items-center space-x-2">
                  <CameraIcon className="h-4 w-4 text-blue-600" />
                  <span className="text-sm text-slate-600">
                    {realtimeSessions.length} active sessions
                  </span>
                </div>
              </div>
              {realtimeError && (
                <div className="text-xs text-red-600 bg-red-50 px-2 py-1 rounded">
                  Connection issues detected
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Error Message */}
        {realtimeError && (
          <div className="p-4 bg-gradient-to-r from-red-50 to-pink-50 border border-red-200 rounded-xl shadow-sm">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-red-500 rounded-lg">
                <ExclamationTriangleIcon className="h-5 w-5 text-white" />
              </div>
              <div className="flex-1">
                <p className="text-red-800 font-medium">
                  Real-time Connection Issues
                </p>
                <p className="text-red-600 text-sm">{realtimeError}</p>
              </div>
            </div>
          </div>
        )}

        {ambulancesData.length === 0 ? (
          <Card className="border-0 shadow-xl bg-gradient-to-br from-white to-gray-50">
            <CardContent className="text-center py-16">
              <div className="mb-8">
                <div className="mx-auto w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center">
                  <VideoCameraIcon className="h-10 w-10 text-slate-400" />
                </div>
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-3">
                No Active Sessions
              </h3>
              <p className="text-slate-600 mb-8 max-w-md mx-auto">
                No ambulance sessions are currently active. Sessions will appear
                here when cameras connect.
              </p>
            </CardContent>
          </Card>
        ) : (
          <>
            {/* Stats Bar */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-wrap items-center justify-between gap-6">
                <div className="flex items-center space-x-8">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                      <TruckIcon className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-sm text-slate-500">
                        Active Ambulances
                      </p>
                      <p className="text-xl font-semibold text-slate-800">
                        {ambulancesData.length}
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
                        {ambulancesData.reduce(
                          (acc, amb) => acc + amb.activeSessions.length,
                          0
                        )}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
                      <SignalIcon className="h-5 w-5 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-sm text-slate-500">
                        Connected Cameras
                      </p>
                      <p className="text-xl font-semibold text-slate-800">
                        {ambulancesData.reduce(
                          (acc, amb) => acc + amb.connectedRooms.length,
                          0
                        )}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Ambulance Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {ambulancesData.map((ambulance) => (
                <Card
                  key={ambulance.ambulanceId}
                  className="bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-200"
                >
                  <CardHeader className="border-b border-slate-100 bg-slate-50">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                          <TruckIcon className="h-5 w-5 text-blue-600" />
                        </div>
                        <h3 className="text-lg font-semibold text-slate-800">
                          {ambulance.ambulanceNumber}
                        </h3>
                      </div>
                      {ambulance.activeSessions.length > 0 ? (
                        ambulance.connectedRooms.length > 0 ? (
                          <Badge variant="live">
                            <div className="w-2 h-2 bg-white rounded-full" />
                            LIVE
                          </Badge>
                        ) : (
                          <Badge variant="warning">Session Active</Badge>
                        )
                      ) : (
                        <Badge variant="secondary">Inactive</Badge>
                      )}
                    </div>
                  </CardHeader>

                  <CardContent className="p-6 space-y-4">
                    {ambulance.activeSessions.length > 0 ? (
                      <>
                        <div className="bg-blue-50 border border-blue-100 rounded-xl p-4">
                          <div className="text-sm">
                            <div className="flex items-center justify-between mb-2">
                              <span className="font-medium text-slate-700">
                                Sessions: {ambulance.activeSessions.length}
                              </span>
                              <span className="text-xs text-slate-500">
                                Rooms: {ambulance.connectedRooms.length}/
                                {ambulance.totalRooms.length}
                              </span>
                            </div>
                          </div>
                        </div>

                        {ambulance.totalRooms.length > 0 && (
                          <div className="space-y-2">
                            <div className="text-sm font-medium text-slate-700 mb-3">
                              Camera Rooms ({ambulance.totalRooms.length})
                            </div>
                            {ambulance.totalRooms.slice(0, 3).map((room) => (
                              <div
                                key={room.id}
                                onClick={() =>
                                  handleJoinRoom(
                                    room.room_id,
                                    ambulance.ambulanceId
                                  )
                                }
                                className="flex items-center justify-between p-3 bg-slate-50 hover:bg-slate-100 rounded-xl cursor-pointer transition-colors border border-slate-200"
                              >
                                <div className="flex items-center space-x-3">
                                  <div
                                    className={`w-3 h-3 rounded-full ${
                                      room.connected
                                        ? "bg-green-500 animate-pulse"
                                        : "bg-slate-400"
                                    }`}
                                  />
                                  <span className="text-sm font-medium text-slate-800">
                                    {room.room_id}
                                  </span>
                                </div>
                                <EyeIcon className="h-4 w-4 text-slate-400" />
                              </div>
                            ))}
                            {ambulance.totalRooms.length > 3 && (
                              <p className="text-xs text-slate-500 text-center">
                                +{ambulance.totalRooms.length - 3} more rooms
                              </p>
                            )}
                          </div>
                        )}

                        <div className="pt-4 border-t border-slate-200">
                          <Button
                            onClick={() =>
                              handleViewStream(ambulance.ambulanceId)
                            }
                            className="w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-2 px-4"
                          >
                            <VideoCameraIcon className="h-4 w-4 mr-2" />
                            View Stream
                          </Button>
                        </div>
                      </>
                    ) : (
                      <div className="text-center py-8 text-slate-500">
                        <CameraIcon className="h-12 w-12 mx-auto mb-3 text-slate-300" />
                        <p className="font-medium">No Active Session</p>
                        <p className="text-sm">
                          Waiting for cameras to connect
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
