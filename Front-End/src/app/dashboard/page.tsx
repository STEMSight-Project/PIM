"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { useAuth } from "@/hooks/useAuth";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import {
  ChartBarIcon,
  CheckCircleIcon,
  ClockIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  PlayIcon,
  SignalIcon,
  TruckIcon,
  VideoCameraIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

export default function DashboardPage() {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();
  const [selectedFilter, setSelectedFilter] = useState<
    "all" | "active" | "inactive"
  >("active");

  // Fetch real-time ambulance sessions and camera data
  const {
    sessions,
    isLoading: sessionsLoading,
    isConnected,
    error: sessionsError,
  } = useRealtimeAmbulanceSessions({
    enabled: true,
    isActive:
      selectedFilter === "active"
        ? true
        : selectedFilter === "inactive"
        ? false
        : undefined,
  });

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push("/");
    }
  }, [isAuthenticated, isLoading, router]);

  // Calculate real-time statistics
  const stats = useMemo(() => {
    const activeSessions = sessions.filter((s) => s.is_active);
    const allRooms = sessions.flatMap((s) => s.camera_rooms || []);
    const connectedRooms = allRooms.filter((r) => r.connected);
    const totalDetections = allRooms.reduce(
      (sum, r) => sum + (r.detections_count || 0),
      0
    );
    const roomsWithAI = allRooms.filter((r) => r.ai_processing_active);

    // Movement types detected (from AI model classes)
    const movementTypes = [
      "ballistic",
      "chorea",
      "decerebrate",
      "decorticate",
      "dystonia",
      "fencer_posture",
      "myoclonus",
      "tremor",
      "versive_head",
    ];
    const detectionRate =
      connectedRooms.length > 0
        ? (totalDetections / connectedRooms.length).toFixed(1)
        : "0";

    return [
      {
        label: "Active Sessions",
        value: activeSessions.length.toString(),
        color: "bg-blue-500",
        icon: TruckIcon,
        trend: `${sessions.length} total sessions`,
        status: activeSessions.length > 0 ? "online" : "offline",
      },
      {
        label: "Live Camera Feeds",
        value: `${connectedRooms.length}/${allRooms.length}`,
        color: "bg-green-500",
        icon: VideoCameraIcon,
        trend:
          connectedRooms.length > 0
            ? "Currently streaming"
            : "No active streams",
        status: connectedRooms.length > 0 ? "active" : "inactive",
      },
      {
        label: "Movement Detections",
        value: totalDetections.toString(),
        color: "bg-purple-500",
        icon: ChartBarIcon,
        trend: `${detectionRate} avg per camera`,
        status: "normal",
      },
      {
        label: "AI Processing",
        value: `${roomsWithAI.length}/${allRooms.length}`,
        color: "bg-orange-500",
        icon: SignalIcon,
        trend:
          roomsWithAI.length > 0 ? "UNIK Model Active" : "No AI processing",
        status: roomsWithAI.length > 0 ? "excellent" : "inactive",
      },
    ];
  }, [sessions]);

  // Recent activity from camera rooms
  const recentActivity = useMemo(() => {
    const allRooms = sessions.flatMap((s) =>
      (s.camera_rooms || []).map((room) => ({
        ...room,
        ambulance_id: s.ambulance_id,
      }))
    );

    // Sort by last_detection_at or last_seen
    const sorted = allRooms
      .filter((r) => r.last_detection_at || r.last_seen)
      .sort((a, b) => {
        const aTime = new Date(
          a.last_detection_at || a.last_seen || 0
        ).getTime();
        const bTime = new Date(
          b.last_detection_at || b.last_seen || 0
        ).getTime();
        return bTime - aTime;
      })
      .slice(0, 5);

    return sorted.map((room, idx) => ({
      id: idx + 1,
      camera: room.camera_name || room.room_name,
      ambulanceId: room.ambulance_id,
      event: room.ai_processing_active
        ? `AI Detection Active (${room.detections_count || 0} detections)`
        : room.connected
        ? "Streaming Live"
        : "Camera Offline",
      confidence: room.detections_count || 0,
      time: new Date(room.last_detection_at || room.last_seen || Date.now()),
      status: room.connected
        ? room.ai_processing_active
          ? "alert"
          : "normal"
        : "offline",
      fps: room.current_fps,
      latency: room.latency_ms,
    }));
  }, [sessions]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Header Section */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              PIM Monitoring Dashboard
            </h1>
            <p className="text-gray-600 mt-1">
              Real-time Parkinson&apos;s Involuntary Movement Detection System
            </p>
            {isConnected && (
              <div className="flex items-center mt-2 text-sm text-green-600">
                <div className="w-2 h-2 bg-green-600 rounded-full mr-2 animate-pulse"></div>
                <span>Live Data Connected</span>
              </div>
            )}
          </div>
          <div className="flex space-x-3">
            <Button
              variant="outline"
              onClick={() => router.push("/streamingDash")}
              className="flex items-center space-x-2"
            >
              <EyeIcon className="w-4 h-4" />
              <span>Live Cameras</span>
            </Button>
            <Button
              onClick={() => router.push("/recent-live-session")}
              className="flex items-center space-x-2"
            >
              <ChartBarIcon className="w-4 h-4" />
              <span>Session History</span>
            </Button>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex items-center space-x-2 border-b border-gray-200">
          <button
            onClick={() => setSelectedFilter("active")}
            className={`px-4 py-2 font-medium transition-colors ${
              selectedFilter === "active"
                ? "text-blue-600 border-b-2 border-blue-600"
                : "text-gray-600 hover:text-gray-900"
            }`}
          >
            Active Sessions
          </button>
          <button
            onClick={() => setSelectedFilter("all")}
            className={`px-4 py-2 font-medium transition-colors ${
              selectedFilter === "all"
                ? "text-blue-600 border-b-2 border-blue-600"
                : "text-gray-600 hover:text-gray-900"
            }`}
          >
            All Sessions
          </button>
          <button
            onClick={() => setSelectedFilter("inactive")}
            className={`px-4 py-2 font-medium transition-colors ${
              selectedFilter === "inactive"
                ? "text-blue-600 border-b-2 border-blue-600"
                : "text-gray-600 hover:text-gray-900"
            }`}
          >
            Completed Sessions
          </button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => {
            const IconComponent = stat.icon;
            return (
              <Card
                key={index}
                className="p-6 hover:shadow-lg transition-shadow cursor-pointer"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className={`p-3 rounded-lg ${stat.color}`}>
                      <IconComponent className="w-6 h-6 text-white" />
                    </div>
                    <div className="ml-4">
                      <p className="text-sm font-medium text-gray-600">
                        {stat.label}
                      </p>
                      <p className="text-2xl font-bold text-gray-900">
                        {stat.value}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">{stat.trend}</p>
                    </div>
                  </div>
                  <div className="flex items-center">
                    {stat.status === "online" && (
                      <div className="flex items-center text-green-600">
                        <div className="w-2 h-2 bg-green-600 rounded-full mr-1 animate-pulse"></div>
                        <span className="text-xs font-medium">Online</span>
                      </div>
                    )}
                    {stat.status === "active" && (
                      <div className="flex items-center text-blue-600">
                        <SignalIcon className="w-4 h-4 mr-1" />
                        <span className="text-xs font-medium">Active</span>
                      </div>
                    )}
                    {stat.status === "normal" && (
                      <CheckCircleIcon className="w-5 h-5 text-green-600" />
                    )}
                    {stat.status === "excellent" && (
                      <div className="flex items-center text-green-600">
                        <CheckCircleIcon className="w-4 h-4 mr-1" />
                        <span className="text-xs font-medium">Excellent</span>
                      </div>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Recent Camera Activity */}
          <div className="lg:col-span-2">
            <Card className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-semibold text-gray-900">
                  Recent Camera Activity
                </h3>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => router.push("/streamingDash")}
                  className="flex items-center space-x-1"
                >
                  <EyeIcon className="w-4 h-4" />
                  <span>View All</span>
                </Button>
              </div>

              {sessionsLoading ? (
                <div className="flex items-center justify-center py-12">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
              ) : recentActivity.length === 0 ? (
                <div className="text-center py-12">
                  <VideoCameraIcon className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                  <p className="text-gray-600">No recent camera activity</p>
                  <p className="text-sm text-gray-500 mt-1">
                    Waiting for camera devices to connect and stream
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {recentActivity.map((activity) => (
                    <div
                      key={activity.id}
                      className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer"
                      onClick={() =>
                        router.push(
                          `/streamingDash?ambulance=${activity.ambulanceId}`
                        )
                      }
                    >
                      <div className="flex items-center space-x-4">
                        <div
                          className={`p-2 rounded-lg ${
                            activity.status === "alert"
                              ? "bg-orange-500"
                              : activity.status === "normal"
                              ? "bg-green-500"
                              : "bg-gray-400"
                          }`}
                        >
                          {activity.status === "alert" ? (
                            <ExclamationTriangleIcon className="w-5 h-5 text-white" />
                          ) : activity.status === "normal" ? (
                            <PlayIcon className="w-5 h-5 text-white" />
                          ) : (
                            <XCircleIcon className="w-5 h-5 text-white" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">
                            {activity.camera}
                          </p>
                          <p className="text-sm text-gray-600">
                            {activity.event}
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="flex items-center space-x-2">
                          {activity.fps && (
                            <span className="px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                              {activity.fps} FPS
                            </span>
                          )}
                          {activity.latency && (
                            <span className="px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                              {activity.latency}ms
                            </span>
                          )}
                        </div>
                        <p className="text-sm text-gray-600 mt-1 flex items-center justify-end">
                          <ClockIcon className="w-3 h-3 mr-1" />
                          {activity.time.toLocaleTimeString()}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>

          {/* Active Sessions Overview */}
          <div>
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-6">
                Active Sessions
              </h3>

              {sessionsLoading ? (
                <div className="flex items-center justify-center py-8">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                </div>
              ) : sessions.filter((s) => s.is_active).length === 0 ? (
                <div className="text-center py-8">
                  <TruckIcon className="w-10 h-10 text-gray-400 mx-auto mb-2" />
                  <p className="text-sm text-gray-600">No active sessions</p>
                  <p className="text-xs text-gray-500 mt-1">
                    Waiting for camera devices to connect
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {sessions
                    .filter((s) => s.is_active)
                    .slice(0, 4)
                    .map((session) => {
                      const liveRooms = (session.camera_rooms || []).filter(
                        (r) => r.connected
                      ).length;
                      const totalRooms = session.camera_rooms?.length || 0;
                      const detections = (session.camera_rooms || []).reduce(
                        (sum, r) => sum + (r.detections_count || 0),
                        0
                      );

                      return (
                        <div
                          key={session.id}
                          className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 hover:shadow-sm transition-all cursor-pointer"
                          onClick={() =>
                            router.push(
                              `/streamingDash?ambulance=${session.ambulance_id}`
                            )
                          }
                        >
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center space-x-2">
                              <TruckIcon className="w-4 h-4 text-blue-600" />
                              <span className="font-medium text-gray-900">
                                {session.ambulance_id}
                              </span>
                            </div>
                            <span className="px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded-full">
                              Active
                            </span>
                          </div>
                          <div className="space-y-1 text-sm text-gray-600">
                            <div className="flex items-center justify-between">
                              <span>Cameras:</span>
                              <span className="font-medium">
                                {liveRooms}/{totalRooms} Live
                              </span>
                            </div>
                            <div className="flex items-center justify-between">
                              <span>Detections:</span>
                              <span className="font-medium">{detections}</span>
                            </div>
                            <div className="flex items-center justify-between">
                              <span>Started:</span>
                              <span className="font-medium">
                                {new Date(
                                  session.started_at
                                ).toLocaleTimeString()}
                              </span>
                            </div>
                          </div>
                        </div>
                      );
                    })}
                </div>
              )}

              <Button
                variant="outline"
                className="w-full mt-4"
                onClick={() => router.push("/streamingDash")}
              >
                View All Sessions
              </Button>
            </Card>

            {/* Movement Classifications */}
            <Card className="p-6 mt-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Movement Classifications
              </h3>
              <div className="space-y-2 text-sm">
                {[
                  { name: "Tremor", color: "bg-red-500" },
                  { name: "Decorticate", color: "bg-orange-500" },
                  { name: "Versive Head", color: "bg-yellow-500" },
                  { name: "Chorea", color: "bg-green-500" },
                  { name: "Myoclonus", color: "bg-blue-500" },
                  { name: "Dystonia", color: "bg-purple-500" },
                  { name: "Normal", color: "bg-gray-500" },
                ].map((movement) => (
                  <div
                    key={movement.name}
                    className="flex items-center justify-between"
                  >
                    <div className="flex items-center space-x-2">
                      <div
                        className={`w-3 h-3 rounded-full ${movement.color}`}
                      ></div>
                      <span className="text-gray-700">{movement.name}</span>
                    </div>
                  </div>
                ))}
              </div>
              <p className="text-xs text-gray-500 mt-4">
                UNIK Model - 82.88% Accuracy
              </p>
            </Card>
          </div>
        </div>

        {/* System Status Banner */}
        <Card
          className={`p-4 ${
            isConnected && sessions.filter((s) => s.is_active).length > 0
              ? "bg-green-50 border-green-200"
              : sessionsError
              ? "bg-red-50 border-red-200"
              : "bg-yellow-50 border-yellow-200"
          }`}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              {isConnected && sessions.filter((s) => s.is_active).length > 0 ? (
                <>
                  <CheckCircleIcon className="w-6 h-6 text-green-600" />
                  <div>
                    <p className="font-medium text-green-900">
                      System Status: All Systems Operational
                    </p>
                    <p className="text-sm text-green-700">
                      {sessions.filter((s) => s.is_active).length} active
                      session(s) • Real-time monitoring active • UNIK AI model
                      ready
                    </p>
                  </div>
                </>
              ) : sessionsError ? (
                <>
                  <ExclamationCircleIcon className="w-6 h-6 text-red-600" />
                  <div>
                    <p className="font-medium text-red-900">
                      System Status: Connection Error
                    </p>
                    <p className="text-sm text-red-700">
                      Unable to connect to backend • Check server status
                    </p>
                  </div>
                </>
              ) : (
                <>
                  <ExclamationTriangleIcon className="w-6 h-6 text-yellow-600" />
                  <div>
                    <p className="font-medium text-yellow-900">
                      System Status: Waiting for Camera Devices
                    </p>
                    <p className="text-sm text-yellow-700">
                      No active camera sessions • Waiting for devices to connect
                      and start streaming
                    </p>
                  </div>
                </>
              )}
            </div>
            {isConnected && sessions.filter((s) => s.is_active).length > 0 && (
              <Button
                variant="outline"
                size="sm"
                onClick={() => router.push("/streamingDash")}
                className="border-green-300 text-green-700 hover:bg-green-100"
              >
                View Live Cameras
              </Button>
            )}
          </div>
        </Card>
      </div>
    </DashboardLayout>
  );
}
