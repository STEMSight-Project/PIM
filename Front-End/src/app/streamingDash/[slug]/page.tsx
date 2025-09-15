"use client";

import { ConnectionStatus } from "@/components/ConnectionStatus";
import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useStreaming } from "@/hooks/useStreaming";
import { patientService, streamingService } from "@/services";
import type { Patient, StreamingSession } from "@/types";
import {
  ArrowLeftIcon,
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
  const [sessions, setSessions] = useState<StreamingSession[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(roomId);

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
      fetchPatientSessions();
    }
  }, [patientId]);

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
    }
  };

  const fetchPatientSessions = async () => {
    try {
      setLoading(true);
      const response = await streamingService.getSessions({
        patient_id: patientId,
        is_live: true,
      });

      if (response.error) {
        setError(response.error);
        return;
      }

      setSessions(response.data || []);
    } catch (err) {
      setError("Failed to load streaming sessions");
    } finally {
      setLoading(false);
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
            Live streaming session with enhanced reconnection
            {selectedRoomId && (
              <span className="ml-2 text-blue-600 font-medium">
                • Room: {selectedRoomId.split("-")[0]}...
              </span>
            )}
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
                fetchPatientSessions();
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
                        Start streaming to begin monitoring
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
                    Start Stream
                  </Button>
                ) : (
                  <Button
                    onClick={handleStopStream}
                    variant="outline"
                    className="flex items-center gap-2"
                  >
                    <StopIcon className="h-4 w-4" />
                    Stop Stream
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

          {/* Active Sessions */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Active Sessions</h3>
            </CardHeader>
            <CardContent>
              {sessions.length === 0 ? (
                <p className="text-gray-500 text-sm">No active sessions</p>
              ) : (
                <div className="space-y-3">
                  {sessions.map((session) => (
                    <div
                      key={session.id}
                      className={`p-3 rounded-lg cursor-pointer transition-colors ${
                        selectedRoomId === session.room_id
                          ? "bg-blue-50 border-2 border-blue-200"
                          : "bg-gray-50 hover:bg-gray-100"
                      }`}
                      onClick={() => setSelectedRoomId(session.room_id)}
                      title="Click to select this room for streaming"
                    >
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm font-medium">
                          Session {session.id.split("-")[0]}
                          {selectedRoomId === session.room_id && (
                            <span className="ml-2 text-blue-600">
                              ● Selected
                            </span>
                          )}
                        </span>
                        <Badge
                          variant={
                            session.status === "active"
                              ? "default"
                              : "secondary"
                          }
                          className={
                            session.status === "active"
                              ? "bg-green-500 text-white"
                              : ""
                          }
                        >
                          {session.status}
                        </Badge>
                      </div>
                      <div className="text-xs text-gray-600 space-y-1">
                        <p>Room: {session.room_id}</p>
                        <p>
                          Started:{" "}
                          {new Date(session.started_at).toLocaleString()}
                        </p>
                        {session.device_name && (
                          <p>Device: {session.device_name}</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Connection Info */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold">Connection Status</h3>
            </CardHeader>
            <CardContent className="text-sm space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-500">Status:</span>
                <span className={getStatusColor()}>
                  {getConnectionStatus()}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Reconnect Attempts:</span>
                <span>{reconnectAttempts}/5</span>
              </div>
              {currentSession && (
                <div className="flex justify-between">
                  <span className="text-gray-500">Session ID:</span>
                  <span className="font-mono text-xs">
                    {currentSession.id.split("-")[0]}...
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
