"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import { ambulanceStreamingService } from "@/services/streamingService";
import type { AmbulanceSession } from "@/types";
import { formatDate } from "@/utils/cn";
import {
  CalendarIcon,
  ChartBarIcon,
  ClockIcon,
  EyeIcon,
  PlayIcon,
  SignalIcon,
  TruckIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

export default function RecentLiveSessionPage() {
  const router = useRouter();
  const [ambulances, setAmbulances] = useState<any[]>([]);
  const [isLoadingAmbulances, setIsLoadingAmbulances] = useState(true);

  // Real-time sessions data
  const {
    sessions: realtimeSessions,
    isConnected: realtimeConnected,
    error: realtimeError,
    isLoading: isLoadingSessions,
  } = useRealtimeAmbulanceSessions({
    enabled: true,
  });

  // Load ambulances data
  useEffect(() => {
    const loadAmbulances = async () => {
      try {
        setIsLoadingAmbulances(true);
        const response =
          await ambulanceStreamingService.getAmbulancesStreamingStatus();
        if (response.error) {
          throw new Error(response.error);
        }
        setAmbulances(response.data || []);
      } catch (error) {
        console.error("Failed to load ambulances:", error);
      } finally {
        setIsLoadingAmbulances(false);
      }
    };

    loadAmbulances();
  }, []);

  // Calculate statistics
  const statistics = useMemo(() => {
    const activeSessions = realtimeSessions.filter((s) => s.is_active);
    const totalRooms = realtimeSessions.reduce(
      (acc, s) => acc + (s.camera_rooms?.length || 0),
      0
    );
    const connectedRooms = realtimeSessions.reduce(
      (acc, s) =>
        acc + (s.camera_rooms?.filter((r) => r.connected).length || 0),
      0
    );
    const totalDetections = realtimeSessions.reduce(
      (acc, s) =>
        acc +
        (s.camera_rooms?.reduce(
          (sum, r) => sum + (r.detections_count || 0),
          0
        ) || 0),
      0
    );

    return {
      totalSessions: realtimeSessions.length,
      activeSessions: activeSessions.length,
      totalRooms,
      connectedRooms,
      totalDetections,
    };
  }, [realtimeSessions]);

  // Get ambulance info by ID
  const getAmbulanceInfo = (ambulanceId: string) => {
    const status = ambulances.find((a) => a.ambulance_id === ambulanceId);
    return status ? { ambulance_number: status.ambulance_number } : null;
  };

  // Calculate session duration
  const getSessionDuration = (session: AmbulanceSession) => {
    const start = new Date(session.started_at);
    const end = session.ended_at ? new Date(session.ended_at) : new Date();
    const durationMs = end.getTime() - start.getTime();
    const minutes = Math.floor(durationMs / 60000);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    }
    return `${minutes}m`;
  };

  // Get session status display
  const getSessionStatusInfo = (session: AmbulanceSession) => {
    if (session.is_active) {
      return {
        label: "Active",
        color: "bg-green-100 text-green-800",
        icon: PlayIcon,
      };
    }
    return {
      label: "Completed",
      color: "bg-gray-100 text-gray-800",
      icon: ClockIcon,
    };
  };

  // Get priority level display
  const getPriorityDisplay = (level: number) => {
    if (level === 1) return { label: "Critical", color: "text-red-600" };
    if (level === 2) return { label: "High", color: "text-orange-600" };
    if (level === 3) return { label: "Medium", color: "text-yellow-600" };
    return { label: "Low", color: "text-blue-600" };
  };

  const isLoading = isLoadingAmbulances || isLoadingSessions;

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading ambulance sessions..." />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Recent Ambulance Sessions
            </h1>
            <p className="text-gray-600">
              Real-time monitoring of all ambulance camera sessions
            </p>
          </div>
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <SignalIcon
                className={`h-5 w-5 ${
                  realtimeConnected ? "text-green-600" : "text-red-600"
                }`}
              />
              <span
                className={`text-sm font-medium ${
                  realtimeConnected ? "text-green-600" : "text-red-600"
                }`}
              >
                {realtimeConnected ? "Live" : "Disconnected"}
              </span>
            </div>
            <Button variant="outline">
              <ChartBarIcon className="h-4 w-4 mr-2" />
              Export Report
            </Button>
          </div>
        </div>

        {realtimeError && <Alert variant="error">{realtimeError}</Alert>}

        {/* Session Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <TruckIcon className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Total Sessions
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {statistics.totalSessions}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <PlayIcon className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Active Sessions
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {statistics.activeSessions}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <VideoCameraIcon className="h-6 w-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Camera Rooms
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {statistics.totalRooms}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <SignalIcon className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Connected</p>
                <p className="text-2xl font-bold text-gray-900">
                  {statistics.connectedRooms}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <EyeIcon className="h-6 w-6 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Detections</p>
                <p className="text-2xl font-bold text-gray-900">
                  {statistics.totalDetections}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Sessions List */}
        <Card className="overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">
              Ambulance Sessions
            </h3>
          </div>

          {realtimeSessions.length === 0 ? (
            <div className="text-center py-12">
              <TruckIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No ambulance sessions
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                No recent ambulance camera sessions found.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-200">
              {realtimeSessions.map((session) => {
                const ambulance = getAmbulanceInfo(session.ambulance_id);
                const statusInfo = getSessionStatusInfo(session);
                const StatusIcon = statusInfo.icon;
                const priority = getPriorityDisplay(session.priority_level);
                const connectedRooms =
                  session.camera_rooms?.filter((r) => r.connected).length || 0;
                const totalRooms = session.camera_rooms?.length || 0;
                const sessionDetections =
                  session.camera_rooms?.reduce(
                    (sum, r) => sum + (r.detections_count || 0),
                    0
                  ) || 0;

                return (
                  <div key={session.id} className="p-6 hover:bg-gray-50">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="flex-shrink-0">
                          <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
                            <TruckIcon className="h-6 w-6 text-blue-600" />
                          </div>
                        </div>

                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2">
                            <p className="text-sm font-medium text-gray-900 truncate">
                              {ambulance?.ambulance_number ||
                                "Unknown Ambulance"}
                            </p>
                            <span
                              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusInfo.color}`}
                            >
                              <StatusIcon className="h-3 w-3 mr-1" />
                              {statusInfo.label}
                            </span>
                            <span
                              className={`text-xs font-medium ${priority.color}`}
                            >
                              {priority.label} Priority
                            </span>
                          </div>

                          <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                            <div className="flex items-center">
                              <CalendarIcon className="h-4 w-4 mr-1" />
                              {formatDate(session.started_at)}
                            </div>
                            <div className="flex items-center">
                              <ClockIcon className="h-4 w-4 mr-1" />
                              {getSessionDuration(session)}
                            </div>
                            <div className="flex items-center">
                              <VideoCameraIcon className="h-4 w-4 mr-1" />
                              {session.session_type}
                            </div>
                            {session.session_name && (
                              <div className="flex items-center">
                                <span className="text-xs bg-gray-100 px-2 py-1 rounded">
                                  {session.session_name}
                                </span>
                              </div>
                            )}
                          </div>

                          {/* Camera Rooms Status */}
                          {totalRooms > 0 && (
                            <div className="mt-2 flex items-center space-x-3">
                              <span className="text-xs text-gray-500">
                                Cameras: {connectedRooms}/{totalRooms} online
                              </span>
                              <div className="flex space-x-1">
                                {session.camera_rooms?.map((room) => (
                                  <div
                                    key={room.id}
                                    className={`h-2 w-2 rounded-full ${
                                      room.connected
                                        ? "bg-green-500"
                                        : "bg-gray-300"
                                    }`}
                                    title={`${room.room_id}: ${
                                      room.connected ? "Connected" : "Offline"
                                    }`}
                                  />
                                ))}
                              </div>
                            </div>
                          )}
                        </div>
                      </div>

                      <div className="flex items-center space-x-6">
                        <div className="text-right">
                          <p className="text-sm font-medium text-gray-900">
                            {sessionDetections} detections
                          </p>
                          <p className="text-sm text-gray-500">
                            {totalRooms} camera{totalRooms !== 1 ? "s" : ""} •{" "}
                            {connectedRooms} active
                          </p>
                        </div>

                        <div className="flex space-x-2">
                          {session.is_active && (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() =>
                                router.push(
                                  `/streamingDash/${session.ambulance_id}`
                                )
                              }
                            >
                              <EyeIcon className="h-4 w-4 mr-1" />
                              Watch Live
                            </Button>
                          )}
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() =>
                              router.push(`/sessions/${session.id}`)
                            }
                          >
                            <ChartBarIcon className="h-4 w-4 mr-1" />
                            View Details
                          </Button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
}
