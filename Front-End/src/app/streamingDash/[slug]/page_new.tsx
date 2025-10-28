"use client";

import { HybridStreamPlayer } from "@/components/HybridStreamPlayer";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import type { CameraRoom } from "@/types";
import {
  ArrowLeftIcon,
  ExclamationTriangleIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import { useMemo, useState } from "react";

export default function SimpleAmbulanceStreamingPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const ambulanceId = params.slug as string;
  const roomIdFromUrl = searchParams.get("room");

  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(
    roomIdFromUrl
  );

  // Real-time sessions and rooms data
  const {
    sessions: realtimeSessions,
    isConnected: realtimeConnected,
    error: realtimeError,
  } = useRealtimeAmbulanceSessions({
    enabled: true,
    ambulanceId: ambulanceId,
  });

  // Extract rooms for this ambulance
  const availableRooms = useMemo(() => {
    const rooms = realtimeSessions
      .filter((session) => session.ambulance_id === ambulanceId)
      .flatMap((session) => session.camera_rooms || []);

    return rooms;
  }, [realtimeSessions, ambulanceId]);

  // Monitor selected room's connection status
  const selectedRoom = useMemo(() => {
    return availableRooms.find((room) => room.room_id === selectedRoomId);
  }, [availableRooms, selectedRoomId]);

  const handleRoomSelect = (roomId: string) => {
    setSelectedRoomId(roomId);
    // Update URL
    const url = new URL(window.location.href);
    url.searchParams.set("room", roomId);
    window.history.replaceState({}, "", url.toString());
  };

  return (
    <div className="container mx-auto p-6">
      {/* Simple Header */}
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
            Ambulance Camera Viewer
          </h1>
          <p className="text-gray-600 mt-1">
            {availableRooms.filter((r) => r.connected).length}/
            {availableRooms.length} rooms online
          </p>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-600">
            {selectedRoom?.connected ? (
              <span className="flex items-center gap-2">
                <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                Camera Online
              </span>
            ) : (
              <span className="flex items-center gap-2">
                <span className="w-2 h-2 bg-gray-400 rounded-full" />
                {selectedRoomId ? "Camera Offline" : "No Camera Selected"}
              </span>
            )}
          </span>
        </div>
      </div>

      {/* Error Messages */}
      {realtimeError && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-red-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-red-700">{realtimeError}</p>
          </div>
        </div>
      )}

      {/* Real-time connection warning */}
      {!realtimeConnected && (
        <div className="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-yellow-700">
              Real-time connection issues detected. Camera data may not be live.
            </p>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Video Stream - HybridStreamPlayer */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">
                  Ambulance Camera Stream
                </h3>
                {selectedRoomId && (
                  <span className="text-xs text-gray-500 font-mono">
                    {selectedRoomId}
                  </span>
                )}
              </div>
            </CardHeader>

            <CardContent>
              {selectedRoomId ? (
                <HybridStreamPlayer
                  ambulanceId={ambulanceId}
                  roomId={selectedRoomId}
                  showAdvancedControls={true}
                  debug={false}
                />
              ) : (
                <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
                  <div className="text-center text-gray-500">
                    <VideoCameraIcon className="h-16 w-16 mx-auto mb-4 opacity-50" />
                    <p className="text-lg font-medium">No Room Selected</p>
                    <p className="text-sm opacity-75">
                      Select a camera room from the list to start streaming
                    </p>
                  </div>
                </div>
              )}

              {/* Info Banner */}
              {selectedRoomId && (
                <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                  <div className="text-sm text-blue-700">
                    <p className="font-medium mb-1">💡 Hybrid Stream Player</p>
                    <ul className="text-xs space-y-1 ml-4 list-disc">
                      <li>
                        <strong>Live Mode:</strong> Real-time WebRTC streaming
                        (low latency)
                      </li>
                      <li>
                        <strong>Playback Mode:</strong> Click pause or scrub
                        timeline to review recording
                      </li>
                      <li>
                        <strong>Go Live:</strong> Click "Go Live" button to
                        return to real-time stream
                      </li>
                    </ul>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Camera Rooms List */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Available Camera Rooms</h3>
            </CardHeader>
            <CardContent>
              {availableRooms.length === 0 ? (
                <p className="text-gray-500 text-sm">
                  No camera rooms available.
                </p>
              ) : (
                <div className="space-y-3">
                  {availableRooms.map((room: CameraRoom) => (
                    <div
                      key={room.id}
                      className={`p-3 rounded-lg border cursor-pointer transition-all ${
                        selectedRoomId === room.room_id
                          ? "border-blue-300 bg-blue-50 shadow-sm"
                          : "border-gray-200 bg-gray-50 hover:bg-gray-100"
                      }`}
                      onClick={() => handleRoomSelect(room.room_id)}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-2">
                          <VideoCameraIcon className="h-5 w-5 text-gray-500" />
                          <span className="text-sm font-medium">
                            {room.room_id || "Room"}
                          </span>
                          {selectedRoomId === room.room_id && (
                            <span className="text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded">
                              Selected
                            </span>
                          )}
                        </div>

                        <div className="flex items-center space-x-2">
                          <div
                            className={`h-3 w-3 rounded-full ${
                              room.connected
                                ? "bg-green-500 animate-pulse"
                                : "bg-gray-400"
                            }`}
                          />
                          <span
                            className={`text-xs px-2 py-1 rounded ${
                              room.connected
                                ? "bg-green-100 text-green-800"
                                : "bg-gray-100 text-gray-800"
                            }`}
                          >
                            {room.connected ? "Online" : "Offline"}
                          </span>
                        </div>
                      </div>

                      <div className="text-xs text-gray-600">
                        {room.camera_id && <p>Camera: {room.camera_id}</p>}
                        <p>
                          Last Seen:{" "}
                          {room.last_seen
                            ? new Date(room.last_seen).toLocaleString()
                            : "Never"}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Simple Connection Info */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Connection Status</h3>
            </CardHeader>
            <CardContent className="text-sm space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-500">Real-time Data:</span>
                <span
                  className={
                    realtimeConnected ? "text-green-600" : "text-red-600"
                  }
                >
                  {realtimeConnected ? "Connected" : "Disconnected"}
                </span>
              </div>
              {selectedRoomId && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Selected Room:</span>
                  <span className="text-gray-900">{selectedRoomId}</span>
                </div>
              )}
              {selectedRoom && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Camera Status:</span>
                  <span
                    className={
                      selectedRoom.connected
                        ? "text-green-600"
                        : "text-red-600"
                    }
                  >
                    {selectedRoom.connected ? "Online" : "Offline"}
                  </span>
                </div>
              )}
              <div className="flex justify-between">
                <span className="text-gray-500">Available Rooms:</span>
                <span>{availableRooms.length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Online Rooms:</span>
                <span className="text-green-600">
                  {availableRooms.filter((r) => r.connected).length}
                </span>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
