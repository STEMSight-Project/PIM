"use client";

import { HLSPlayer } from "@/components/HLSPlayer";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useRealtimeAmbulanceSessions } from "@/hooks/useRealtime";
import { useStreaming } from "@/hooks/useStreaming";
import type { CameraRoom } from "@/types";
import {
  ArrowLeftIcon,
  ExclamationTriangleIcon,
  FilmIcon,
  SignalIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

export default function SimpleAmbulanceStreamingPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const ambulanceId = params.slug as string;
  const roomIdFromUrl = searchParams.get("room");

  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(
    roomIdFromUrl
  );
  const [viewMode, setViewMode] = useState<"live" | "playback">("live");

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

  // Get the active session ID for this ambulance (for HLS playback)
  const currentSessionId = useMemo(() => {
    const activeSession = realtimeSessions.find(
      (session) => session.ambulance_id === ambulanceId && session.is_active
    );
    return activeSession?.id || null;
  }, [realtimeSessions, ambulanceId]);

  // Streaming functionality
  const {
    isConnected: isStreaming,
    isConnecting,
    error: streamingError,
    videoRef,
    startStreaming,
    stopStreaming,
    isWaitingForData, // NEW: Get waiting for data state
  } = useStreaming();

  // NEW: Monitor selected room's connection status
  const selectedRoom = useMemo(() => {
    return availableRooms.find((room) => room.room_id === selectedRoomId);
  }, [availableRooms, selectedRoomId]);

  // AUTO-START: Automatically start streaming when a room is selected
  useEffect(() => {
    if (
      selectedRoomId &&
      !isStreaming &&
      !isConnecting &&
      viewMode === "live"
    ) {
      // Auto-start streaming when room is selected
      startStreaming(ambulanceId, selectedRoomId);
    }
  }, [selectedRoomId, ambulanceId, viewMode]);

  // AUTO-CLEANUP: Stop streaming when component unmounts or room changes
  useEffect(() => {
    return () => {
      if (isStreaming) {
        stopStreaming();
      }
    };
  }, [selectedRoomId]); // Stop when room changes

  // NEW: Check if room disconnected while streaming
  useEffect(() => {
    if (isStreaming && selectedRoom && !selectedRoom.connected) {
      // Room has disconnected while we're streaming
      // The UI will automatically show the disconnection message
    }
  }, [isStreaming, selectedRoom, selectedRoomId]);

  const handleRoomSelect = (roomId: string) => {
    // Stop current stream before switching
    if (isStreaming) {
      stopStreaming();
    }

    setSelectedRoomId(roomId);
    // Update URL
    const url = new URL(window.location.href);
    url.searchParams.set("room", roomId);
    window.history.replaceState({}, "", url.toString());

    // The auto-start effect will handle starting the new stream
  };

  const getConnectionStatus = () => {
    if (isConnecting) return "Connecting...";
    if (isStreaming && selectedRoom && !selectedRoom.connected)
      return "Camera Offline";
    if (isStreaming && isWaitingForData) return "Waiting for Data";
    if (isStreaming) return "Connected";
    if (streamingError) return "Error";
    return "Disconnected";
  };

  const getStatusColor = () => {
    if (isConnecting) return "text-yellow-600";
    if (isStreaming && selectedRoom && !selectedRoom.connected)
      return "text-red-600";
    if (isStreaming && isWaitingForData) return "text-yellow-500";
    if (isStreaming) return "text-green-600";
    if (streamingError) return "text-red-600";
    return "text-gray-600";
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
          <SignalIcon className={`h-5 w-5 ${getStatusColor()}`} />
          <span className={`text-sm font-medium ${getStatusColor()}`}>
            {getConnectionStatus()}
          </span>
        </div>
      </div>

      {/* Mode Toggle */}
      <div className="mb-6 flex items-center gap-4 p-4 bg-white rounded-lg border border-gray-200">
        <span className="text-sm font-medium text-gray-700">View Mode:</span>
        <div className="flex gap-2">
          <button
            onClick={() => {
              setViewMode("live");
              if (isStreaming) stopStreaming();
            }}
            className={`flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              viewMode === "live"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            <SignalIcon className="h-4 w-4" />
            Live Stream
          </button>
          <button
            onClick={() => {
              setViewMode("playback");
              if (isStreaming) stopStreaming();
            }}
            className={`flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              viewMode === "playback"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            <FilmIcon className="h-4 w-4" />
            Playback (HLS)
          </button>
        </div>
        {viewMode === "playback" && currentSessionId && (
          <div className="flex-1 flex items-center gap-2 text-sm text-gray-600">
            <span>
              Session:{" "}
              <span className="font-mono text-gray-900">
                {currentSessionId}
              </span>
            </span>
          </div>
        )}
        {viewMode === "playback" && !currentSessionId && (
          <div className="flex-1 flex items-center gap-2 text-sm text-yellow-600">
            <ExclamationTriangleIcon className="h-4 w-4" />
            <span>No active session found for playback</span>
          </div>
        )}
      </div>

      {/* Error Messages */}
      {(streamingError || realtimeError) && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
          <ExclamationTriangleIcon className="h-5 w-5 text-red-500 mt-0.5" />
          <div className="flex-1">
            <p className="text-red-700">{streamingError || realtimeError}</p>
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
        {/* Video Stream */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">
                  {viewMode === "live" ? "Live Video Stream" : "HLS Playback"}
                </h3>
                {viewMode === "live" && isStreaming && (
                  <span className="bg-red-500 text-white px-2 py-1 rounded text-xs animate-pulse">
                    ● LIVE
                  </span>
                )}
              </div>
            </CardHeader>

            <CardContent>
              {/* Live Stream Mode */}
              {viewMode === "live" && (
                <div className="relative aspect-video bg-gray-900 rounded-lg overflow-hidden">
                  <video
                    ref={videoRef}
                    className="w-full h-full object-contain"
                    autoPlay
                    playsInline
                    controls={false}
                  />

                  {/* NEW: Show message when room is disconnected */}
                  {isStreaming && selectedRoom && !selectedRoom.connected && (
                    <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-90">
                      <div className="text-center text-white">
                        <ExclamationTriangleIcon className="h-16 w-16 mx-auto mb-4 text-red-400" />
                        <p className="text-lg font-medium text-red-400">
                          Camera Disconnected
                        </p>
                        <p className="text-sm opacity-75 mt-2">
                          The camera room has gone offline
                        </p>
                        <p className="text-xs opacity-50 mt-1">
                          Room: {selectedRoomId}
                        </p>
                        <p className="text-xs opacity-50 mt-1">
                          Last seen:{" "}
                          {selectedRoom.last_seen
                            ? new Date(selectedRoom.last_seen).toLocaleString()
                            : "Never"}
                        </p>
                      </div>
                    </div>
                  )}

                  {/* Show waiting for data message (only if room is connected) */}
                  {isStreaming &&
                    isWaitingForData &&
                    (!selectedRoom || selectedRoom.connected) && (
                      <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-75">
                        <div className="text-center text-white">
                          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-yellow-400 mx-auto mb-4"></div>
                          <p className="text-lg font-medium">
                            Waiting for video data...
                          </p>
                          <p className="text-sm opacity-75 mt-2">
                            Camera is connected but no video stream yet
                          </p>
                          <p className="text-xs opacity-50 mt-1">
                            Please check if the camera is transmitting
                          </p>
                        </div>
                      </div>
                    )}

                  {!isStreaming && !isConnecting && (
                    <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-75">
                      <div className="text-center text-white">
                        <VideoCameraIcon className="h-16 w-16 mx-auto mb-4 opacity-50" />
                        {selectedRoomId ? (
                          <>
                            <p className="text-lg font-medium">
                              Initializing Camera
                            </p>
                            <p className="text-sm opacity-75 mb-2">
                              Room: {selectedRoomId}
                            </p>
                            <p className="text-sm opacity-75">
                              Auto-streaming will begin shortly...
                            </p>
                          </>
                        ) : (
                          <>
                            <p className="text-lg font-medium">
                              Select a Camera Room
                            </p>
                            <p className="text-sm opacity-75">
                              Choose a camera room to start auto-streaming
                            </p>
                          </>
                        )}
                      </div>
                    </div>
                  )}

                  {isConnecting && (
                    <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-75">
                      <div className="text-center text-white">
                        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-400 mx-auto mb-4"></div>
                        <p className="text-lg font-medium">
                          Connecting to camera...
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* HLS Playback Mode */}
              {viewMode === "playback" && (
                <div>
                  {currentSessionId ? (
                    <HLSPlayer
                      sessionId={currentSessionId}
                      autoPlay={false}
                      showControls={true}
                      showStatus={true}
                      showStats={true}
                      className="w-full"
                    />
                  ) : (
                    <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
                      <div className="text-center text-gray-500">
                        <FilmIcon className="h-16 w-16 mx-auto mb-4 opacity-50" />
                        <p className="text-lg font-medium">No Active Session</p>
                        <p className="text-sm opacity-75">
                          No active streaming session found for this ambulance
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Mode-specific Status Info */}
              {viewMode === "live" && (
                <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                  <div className="flex items-center justify-center gap-2 text-sm text-blue-700">
                    <SignalIcon className="h-4 w-4" />
                    <span>
                      {isStreaming && selectedRoomId
                        ? `Auto-streaming from ${selectedRoomId}`
                        : selectedRoomId
                        ? "Connecting to camera..."
                        : "Select a camera room to begin auto-streaming"}
                    </span>
                  </div>
                </div>
              )}

              {viewMode === "playback" && currentSessionId && (
                <div className="mt-4 p-3 bg-purple-50 border border-purple-200 rounded-lg">
                  <div className="flex items-center justify-center gap-2 text-sm text-purple-700">
                    <FilmIcon className="h-4 w-4" />
                    <span>Playing back recording: {currentSessionId}</span>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Camera Rooms List - Only show in live mode */}
        {viewMode === "live" && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <h3 className="text-lg font-semibold">
                  Available Camera Rooms
                </h3>
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
                  <span className="text-gray-500">Stream Status:</span>
                  <span className={getStatusColor()}>
                    {getConnectionStatus()}
                  </span>
                </div>
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
        )}

        {/* Playback Info - Show in playback mode */}
        {viewMode === "playback" && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <h3 className="text-lg font-semibold">Playback Information</h3>
              </CardHeader>
              <CardContent className="text-sm space-y-2">
                <div className="p-3 bg-purple-50 border border-purple-200 rounded-lg">
                  <p className="text-purple-700 text-xs mb-2">
                    💡 <strong>HLS Playback Mode:</strong>
                  </p>
                  <ul className="text-purple-600 text-xs space-y-1 ml-4 list-disc">
                    <li>Automatically uses the current active session</li>
                    <li>HLS segments load from the ongoing recording</li>
                    <li>Use video controls to play/pause/seek</li>
                    <li>Works for both live and completed recordings</li>
                  </ul>
                </div>
                {currentSessionId && (
                  <>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Session ID:</span>
                      <span className="text-xs font-mono">
                        {currentSessionId}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Mode:</span>
                      <span className="text-purple-600">HLS Playback</span>
                    </div>
                  </>
                )}
              </CardContent>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
