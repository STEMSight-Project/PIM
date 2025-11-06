"use client";

import { HybridStreamPlayer } from "@/components/HybridStreamPlayer";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import type { AmbulanceSession, CameraRoom } from "@/types";
import {
  ArrowLeftIcon,
  SignalIcon,
  TruckIcon,
  VideoCameraIcon,
  WifiIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

export default function AmbulanceStreamingPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const ambulanceId = params.slug as string;
  const roomIdFromUrl = searchParams.get("room");
  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(
    roomIdFromUrl
  );

  /**
   * Data Flow:
   * 1. Get ambulanceId from URL params (e.g., /streamingDash/AMB-001)
   * 2. Get optional roomId from URL query (e.g., ?room=AMB-001-ROOM-001)
   * 3. Fetch ALL sessions for this ambulance (active or inactive)
   * 4. Extract ALL rooms from sessions (online or offline)
   * 5. Auto-select room from URL when it becomes available
   * 6. Real-time updates handle connected/disconnected status changes
   */

  // Real-time sessions data - get ALL sessions for this ambulance (active or not)
  // We need all sessions to see all rooms, regardless of connection status
  const {
    sessions: allSessions,
    isConnected: realtimeConnected,
    isLoading,
    error: realtimeError,
  } = useRealtimeAmbulanceSessions({
    enabled: true,
    ambulanceId: ambulanceId, // Filter by ambulance ID from URL
    isActive: true,
  });

  // Extract ALL rooms for this ambulance (online or offline)
  // Deduplicate by camera_id to prevent duplicate keys in React rendering
  const availableRooms = useMemo(() => {
    const rooms = allSessions.flatMap(
      (session: AmbulanceSession) => session.camera_rooms || []
    );

    // Deduplicate by camera_id - keep the most recent/connected one
    const roomMap = new Map<string, CameraRoom>();
    for (const room of rooms) {
      const existing = roomMap.get(room.camera_id);
      if (!existing) {
        roomMap.set(room.camera_id, room);
      } else {
        // Prioritize: 1) connected rooms, 2) more recent updates
        if (room.connected && !existing.connected) {
          roomMap.set(room.camera_id, room);
        } else if (
          room.connected === existing.connected &&
          room.updated_at > existing.updated_at
        ) {
          roomMap.set(room.camera_id, room);
        }
      }
    }

    return Array.from(roomMap.values());
  }, [allSessions]);

  // Compute stats for this ambulance
  const ambulanceStats = useMemo(() => {
    const liveRooms = availableRooms.filter(
      (room: CameraRoom) => room.connected === true
    );
    return {
      totalRooms: availableRooms.length,
      liveRooms: liveRooms.length,
      totalSessions: allSessions.length,
    };
  }, [availableRooms, allSessions]);

  // Auto-select room from URL when it becomes available
  useEffect(() => {
    if (roomIdFromUrl && availableRooms.length > 0) {
      const roomExists = availableRooms.some(
        (room: CameraRoom) => room.id === roomIdFromUrl
      );
      if (roomExists && selectedRoomId !== roomIdFromUrl) {
        setSelectedRoomId(roomIdFromUrl);
      }
    } else if (!roomIdFromUrl && !selectedRoomId && availableRooms.length > 0) {
      // Auto-select first available room if no room specified
      console.log("[StreamingDash] Auto-selecting first available room");
      setSelectedRoomId(availableRooms[0].id);
    }
  }, [roomIdFromUrl, availableRooms, selectedRoomId]);

  // Monitor selected room's connection status
  const selectedRoom = useMemo(() => {
    return availableRooms.find(
      (room: CameraRoom) => room.id === selectedRoomId
    );
  }, [availableRooms, selectedRoomId]);

  const handleRoomSelect = (roomId: string) => {
    setSelectedRoomId(roomId);
    // Update URL with room.id (UUID)
    const url = new URL(window.location.href);
    url.searchParams.set("room", roomId);
    window.history.replaceState({}, "", url.toString());
  };

  // Loading state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center">
        <div className="text-center">
          <div className="relative mx-auto w-16 h-16 mb-8">
            <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
            <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
          </div>
          <h3 className="text-xl font-semibold text-slate-800 mb-2">
            Loading Camera Feed
          </h3>
          <p className="text-slate-600">Connecting to ambulance...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <div className="container mx-auto p-6 max-w-7xl">
        {/* Modern Header with Glassmorphism */}
        <div className="bg-white/80 backdrop-blur-xl rounded-2xl shadow-lg border border-white/20 p-6 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Button
                onClick={() => router.push("/streamingDash")}
                variant="outline"
                className="flex items-center gap-2 hover:bg-blue-50 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4" />
                Back
              </Button>

              <div className="flex items-center gap-3">
                <div className="p-3 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg">
                  <TruckIcon className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-slate-900">
                    {ambulanceId.substring(0, 7).toUpperCase()}
                  </h1>
                  <p className="text-sm text-slate-600">
                    {ambulanceStats.liveRooms}/{ambulanceStats.totalRooms}{" "}
                    cameras online
                  </p>
                </div>
              </div>
            </div>

            {/* Status Badges */}
            <div className="flex items-center gap-3">
              {/* Real-time Connection Badge */}
              <div
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm ${
                  realtimeConnected
                    ? "bg-green-100 text-green-700 border border-green-200"
                    : "bg-red-100 text-red-700 border border-red-200"
                }`}
              >
                <WifiIcon className="h-4 w-4" />
                {realtimeConnected ? "Connected" : "Disconnected"}
              </div>

              {/* Camera Status Badge */}
              {selectedRoom && (
                <div
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm ${
                    selectedRoom.connected
                      ? "bg-blue-100 text-blue-700 border border-blue-200"
                      : "bg-gray-100 text-gray-700 border border-gray-200"
                  }`}
                >
                  <div
                    className={`w-2 h-2 rounded-full ${
                      selectedRoom.connected
                        ? "bg-blue-600 animate-pulse"
                        : "bg-gray-400"
                    }`}
                  />
                  {selectedRoom.connected ? "Camera Live" : "Camera Offline"}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Error Alerts */}
        {realtimeError && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start gap-3 shadow-sm">
            <XCircleIcon className="h-5 w-5 text-red-500 mt-0.5 flex-shrink-0" />
            <div className="flex-1">
              <p className="font-medium text-red-800 mb-1">Connection Error</p>
              <p className="text-sm text-red-700">{realtimeError}</p>
            </div>
          </div>
        )}

        {!realtimeConnected && (
          <div className="mb-6 p-4 bg-amber-50 border border-amber-200 rounded-xl flex items-start gap-3 shadow-sm">
            <SignalIcon className="h-5 w-5 text-amber-500 mt-0.5 flex-shrink-0" />
            <div className="flex-1">
              <p className="font-medium text-amber-800 mb-1">
                Real-time Updates Paused
              </p>
              <p className="text-sm text-amber-700">
                Reconnecting to live data stream...
              </p>
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Video Stream - HybridStreamPlayer */}
          <div className="lg:col-span-2">
            <Card className="border-0 shadow-xl bg-white/90 backdrop-blur-sm">
              <CardHeader className="border-b border-slate-100 bg-gradient-to-r from-slate-50 to-blue-50">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-blue-100 rounded-lg">
                      <VideoCameraIcon className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold text-slate-900">
                        Live Camera Feed
                      </h3>
                      {selectedRoomId && (
                        <p className="text-xs text-slate-500 font-mono mt-0.5">
                          {selectedRoomId}
                        </p>
                      )}
                    </div>
                  </div>

                  {selectedRoom?.connected && (
                    <div className="flex items-center gap-2 px-3 py-1.5 bg-red-500 text-white rounded-full text-xs font-bold">
                      <span className="w-2 h-2 bg-white rounded-full animate-pulse" />
                      LIVE
                    </div>
                  )}
                </div>
              </CardHeader>

              <CardContent className="p-0">
                {selectedRoomId ? (
                  <HybridStreamPlayer
                    key={`${ambulanceId}-${selectedRoomId}`}
                    ambulanceId={ambulanceId}
                    roomId={selectedRoomId}
                    showAdvancedControls={true}
                    debug={false}
                  />
                ) : (
                  <div className="aspect-video bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center">
                    <div className="text-center text-slate-600 p-8">
                      <div className="w-20 h-20 mx-auto mb-6 bg-slate-300/50 rounded-full flex items-center justify-center">
                        <VideoCameraIcon className="h-10 w-10 text-slate-400" />
                      </div>
                      <p className="text-xl font-semibold mb-2">
                        No Camera Selected
                      </p>
                      <p className="text-sm text-slate-500 max-w-sm mx-auto">
                        Select a camera from the list to start viewing live
                        stream or playback recordings
                      </p>
                    </div>
                  </div>
                )}

                {/* Info Banner */}
                {selectedRoomId && (
                  <div className="m-4 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-xl">
                    <div className="flex items-start gap-3">
                      <div className="p-2 bg-blue-100 rounded-lg flex-shrink-0">
                        <SignalIcon className="h-5 w-5 text-blue-600" />
                      </div>
                      <div className="text-sm text-blue-900">
                        <p className="font-semibold mb-2">
                          Hybrid Stream Player
                        </p>
                        <ul className="text-xs space-y-1.5 text-blue-700">
                          <li className="flex items-start gap-2">
                            <span className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                            <span>
                              <strong>Live Mode:</strong> Real-time WebRTC
                              streaming with ultra-low latency
                            </span>
                          </li>
                          <li className="flex items-start gap-2">
                            <span className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                            <span>
                              <strong>Playback Mode:</strong> Click pause or
                              drag timeline to review recordings
                            </span>
                          </li>
                          <li className="flex items-start gap-2">
                            <span className="w-1.5 h-1.5 bg-blue-600 rounded-full mt-1.5 flex-shrink-0" />
                            <span>
                              <strong>Go Live:</strong> Jump back to real-time
                              with one click
                            </span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Camera Rooms List - Modern Design */}
          <div className="space-y-6">
            <Card className="border-0 shadow-xl bg-white/90 backdrop-blur-sm">
              <CardHeader className="border-b border-slate-100 bg-gradient-to-r from-slate-50 to-blue-50">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-semibold text-slate-900">
                    Camera Rooms
                  </h3>
                  <div className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">
                    {ambulanceStats.liveRooms} Live
                  </div>
                </div>
              </CardHeader>
              <CardContent className="p-4">
                {availableRooms.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="w-16 h-16 mx-auto mb-4 bg-slate-100 rounded-full flex items-center justify-center">
                      <VideoCameraIcon className="h-8 w-8 text-slate-400" />
                    </div>
                    <p className="text-slate-600 font-medium mb-1">
                      No Cameras Available
                    </p>
                    <p className="text-sm text-slate-500">
                      Waiting for cameras to connect...
                    </p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {availableRooms.map((room: CameraRoom) => {
                      const isSelected = selectedRoomId === room.id;
                      const isLive =
                        room.connected && !room.connection_ended_at;

                      return (
                        <button
                          key={room.id}
                          className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                            isSelected
                              ? "border-blue-500 bg-blue-50 shadow-md"
                              : "border-slate-200 bg-white hover:border-slate-300 hover:shadow-sm"
                          }`}
                          onClick={() => handleRoomSelect(room.id)}
                        >
                          <div className="flex items-center justify-between mb-3">
                            <div className="flex items-center gap-3">
                              <div
                                className={`p-2 rounded-lg ${
                                  isLive ? "bg-red-100" : "bg-slate-100"
                                }`}
                              >
                                <VideoCameraIcon
                                  className={`h-5 w-5 ${
                                    isLive ? "text-red-600" : "text-slate-500"
                                  }`}
                                />
                              </div>
                              <div>
                                <p className="font-semibold text-slate-900 text-sm">
                                  {room.camera_name || "Camera"}
                                </p>
                                <p className="text-xs text-slate-500 font-mono">
                                  {room.room_name}
                                </p>
                              </div>
                            </div>

                            <div className="flex flex-col items-end gap-2">
                              {isLive && (
                                <div className="flex items-center gap-1.5 px-2 py-1 bg-red-500 text-white rounded-md text-xs font-bold">
                                  <span className="w-1.5 h-1.5 bg-white rounded-full animate-pulse" />
                                  LIVE
                                </div>
                              )}
                              {isSelected && (
                                <div className="px-2 py-1 bg-blue-500 text-white rounded-md text-xs font-semibold">
                                  Active
                                </div>
                              )}
                            </div>
                          </div>

                          <div className="flex items-center justify-between text-xs">
                            <span
                              className={`px-2 py-1 rounded-md font-medium ${
                                isLive
                                  ? "bg-green-100 text-green-700"
                                  : "bg-slate-100 text-slate-600"
                              }`}
                            >
                              {isLive ? "● Online" : "○ Offline"}
                            </span>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Connection Status Card - Modern Design */}
            <Card className="border-0 shadow-xl bg-white/90 backdrop-blur-sm">
              <CardHeader className="border-b border-slate-100 bg-gradient-to-r from-slate-50 to-blue-50">
                <h3 className="text-lg font-semibold text-slate-900">
                  System Status
                </h3>
              </CardHeader>
              <CardContent className="p-4">
                <div className="space-y-3">
                  {/* Real-time Connection */}
                  <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <WifiIcon
                        className={`h-5 w-5 ${
                          realtimeConnected ? "text-green-600" : "text-red-600"
                        }`}
                      />
                      <span className="text-sm font-medium text-slate-700">
                        Real-time Data
                      </span>
                    </div>
                    <span
                      className={`text-sm font-semibold ${
                        realtimeConnected ? "text-green-600" : "text-red-600"
                      }`}
                    >
                      {realtimeConnected ? "Connected" : "Disconnected"}
                    </span>
                  </div>

                  {/* Active Sessions */}
                  <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <SignalIcon className="h-5 w-5 text-blue-600" />
                      <span className="text-sm font-medium text-slate-700">
                        Active Sessions
                      </span>
                    </div>
                    <span className="text-sm font-semibold text-slate-900">
                      {ambulanceStats.totalSessions}
                    </span>
                  </div>

                  {/* Camera Statistics */}
                  <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <VideoCameraIcon className="h-5 w-5 text-purple-600" />
                      <span className="text-sm font-medium text-slate-700">
                        Cameras Online
                      </span>
                    </div>
                    <span className="text-sm font-semibold text-slate-900">
                      {ambulanceStats.liveRooms}/{ambulanceStats.totalRooms}
                    </span>
                  </div>

                  {/* Selected Camera Info */}
                  {selectedRoom && (
                    <>
                      <div className="border-t border-slate-200 my-3"></div>
                      <div className="space-y-2">
                        <p className="text-xs font-semibold text-slate-600 uppercase tracking-wider">
                          Selected Camera
                        </p>
                        <div className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                          <p className="text-sm font-mono text-blue-900 mb-1">
                            {selectedRoom.room_name}
                          </p>
                          <p className="text-xs text-blue-700">
                            Status:{" "}
                            <span className="font-semibold">
                              {selectedRoom.connected ? "Live" : "Offline"}
                            </span>
                          </p>
                        </div>
                      </div>
                    </>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
