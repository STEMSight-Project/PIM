"use client";

import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { patientService, streamingService } from "@/services";
import type { StreamingSession } from "@/types";
import {
  ArrowPathIcon,
  CameraIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  PlayIcon,
  StopIcon,
  UserIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface PatientWithSession {
  id: string;
  first_name: string;
  last_name: string;
  sessions: StreamingSession[];
}

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
  const [activePatients, setActivePatients] = useState<PatientWithSession[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    fetchActivePatients();
    const interval = setInterval(fetchActivePatients, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchActivePatients = async () => {
    try {
      setError(null);
      const response = await streamingService.getSessions({ is_live: true });

      if (response.error) {
        setError(response.error);
        return;
      }

      // Safely check if response.data exists and is an array
      if (!response.data || !Array.isArray(response.data)) {
        console.log("No valid session data received:", response.data);
        setActivePatients([]);
        return;
      }

      if (response.data.length === 0) {
        setActivePatients([]);
        return;
      }

      // Filter sessions that have patient_id and get unique patient IDs
      const validSessions = response.data.filter(
        (session) => session && session.patient_id
      );
      const patientIds = [
        ...new Set(validSessions.map((session) => session.patient_id)),
      ];

      if (patientIds.length === 0) {
        setActivePatients([]);
        return;
      }

      // Fetch patient data for each ID
      const patientPromises = patientIds.map(async (patientId) => {
        try {
          const patientResponse = await patientService.getById(patientId);
          if (patientResponse.error || !patientResponse.data) {
            return null;
          }

          const patientSessions = validSessions.filter(
            (session) => session.patient_id === patientId
          );

          return {
            id: patientResponse.data.id,
            first_name: patientResponse.data.first_name,
            last_name: patientResponse.data.last_name,
            sessions: patientSessions,
          };
        } catch (err) {
          console.error(`Error fetching patient ${patientId}:`, err);
          return null;
        }
      });

      const patients = await Promise.all(patientPromises);
      setActivePatients(patients.filter(Boolean) as PatientWithSession[]);
    } catch (err) {
      console.error("Error in fetchActivePatients:", err);
      setError(
        err instanceof Error ? err.message : "Failed to fetch active sessions"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleViewStream = (patientId: string) => {
    router.push(`/streamingDash/${patientId}`);
  };

  const handleJoinRoom = (roomId: string, patientId: string) => {
    // Navigate to streaming room with room ID parameter
    router.push(`/streamingDash/${patientId}?room=${roomId}`);
  };

  const getSessionStatusBadge = (sessions: StreamingSession[]) => {
    const activeCount = sessions.filter((s) => s.status === "active").length;
    const totalCount = sessions.length;

    if (activeCount === 0)
      return (
        <Badge variant="secondary">
          <StopIcon className="w-3 h-3" />
          Offline
        </Badge>
      );

    if (activeCount === totalCount)
      return (
        <Badge variant="live">
          <div className="w-2 h-2 bg-white rounded-full animate-pulse" />
          LIVE
        </Badge>
      );

    return (
      <Badge variant="warning">
        <PlayIcon className="w-3 h-3" />
        {activeCount}/{totalCount} Active
      </Badge>
    );
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-transparent">
        <div className="container mx-auto px-6 py-8">
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
                Connecting to camera feeds and patient sessions...
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
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-slate-50">
        <div className="container mx-auto px-6 py-8">
          <div className="flex items-center justify-center h-96">
            <div className="text-center max-w-md">
              <div className="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-6">
                <ExclamationTriangleIcon className="w-8 h-8 text-red-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-3">
                Connection Failed
              </h3>
              <p className="text-slate-600 mb-6">
                Unable to connect to streaming service. Please check your
                internet connection and try again.
              </p>
              <div className="bg-red-50 border border-red-200 rounded-xl p-4 mb-6">
                <p className="text-red-800 text-sm font-medium">
                  Error Details:
                </p>
                <p className="text-red-700 text-sm mt-1">{error}</p>
              </div>
              <button
                onClick={() => window.location.reload()}
                className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-xl transition-colors duration-200"
              >
                <ArrowPathIcon className="w-5 h-5" />
                Retry Connection
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-transparent">
      <div className="container mx-auto px-6 py-8">
        {/* Standard page header following UI design system */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden mb-8">
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
                    Real-time camera monitoring and patient session management
                  </p>
                </div>
              </div>
              <div className="hidden lg:flex items-center space-x-6">
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {activePatients.length}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Patients
                  </div>
                </div>
                <div className="text-center bg-white/10 rounded-lg px-4 py-2 backdrop-blur-sm">
                  <div className="text-2xl font-bold text-white">
                    {activePatients.reduce(
                      (acc, p) =>
                        acc +
                        p.sessions.filter((s) => s.status === "active").length,
                      0
                    )}
                  </div>
                  <div className="text-blue-200 text-sm font-medium">
                    Live Now
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
                    {activePatients.reduce(
                      (acc, p) => acc + p.sessions.length,
                      0
                    )}{" "}
                    total sessions
                  </span>
                </div>
                <div className="flex items-center space-x-2">
                  <ClockIcon className="h-4 w-4 text-slate-500" />
                  <span className="text-sm text-slate-600">
                    Last updated: {new Date().toLocaleTimeString()}
                  </span>
                </div>
              </div>
              <Button
                onClick={fetchActivePatients}
                className="border border-blue-200 text-blue-700 hover:bg-blue-50 font-medium px-4 py-2 rounded-lg transition-colors duration-200"
              >
                <ArrowPathIcon className="h-4 w-4 mr-2" />
                Refresh
              </Button>
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
            <Button
              onClick={fetchActivePatients}
              variant="outline"
              size="sm"
              className="mt-3 border-red-300 text-red-700 hover:bg-red-50"
            >
              Try Again
            </Button>
          </div>
        )}

        {activePatients.length === 0 ? (
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
                No patients are currently streaming. Active camera feeds will
                appear here automatically.
              </p>
              <Button
                onClick={fetchActivePatients}
                className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-xl transition-colors duration-200"
              >
                <ArrowPathIcon className="h-5 w-5" />
                Refresh Dashboard
              </Button>
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
                      <p className="text-sm text-slate-500">Active Patients</p>
                      <p className="text-xl font-semibold text-slate-800">
                        {activePatients.length}
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
                        {activePatients.reduce(
                          (acc, p) =>
                            acc +
                            p.sessions.filter((s) => s.status === "active")
                              .length,
                          0
                        )}
                      </p>
                    </div>
                  </div>
                </div>
                <Button
                  onClick={fetchActivePatients}
                  className="flex items-center gap-2 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl transition-colors duration-200"
                >
                  <ArrowPathIcon className="h-4 w-4" />
                  Refresh
                </Button>
              </div>
            </div>

            {/* Patient Cards Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {activePatients.map((patient) => (
                <Card
                  key={patient.id}
                  className="bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-200 overflow-hidden"
                >
                  <CardHeader className="border-b border-slate-100 bg-slate-50">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                          <UserIcon className="h-5 w-5 text-blue-600" />
                        </div>
                        <h3 className="text-lg font-semibold text-slate-800 truncate">
                          {patient.first_name} {patient.last_name}
                        </h3>
                      </div>
                      {getSessionStatusBadge(patient.sessions)}
                    </div>
                  </CardHeader>

                  <CardContent className="p-6 space-y-4">
                    <div className="bg-blue-50 border border-blue-100 rounded-xl p-4">
                      <div className="flex items-center justify-between text-sm">
                        <div className="flex items-center space-x-2">
                          <CameraIcon className="h-4 w-4 text-blue-600" />
                          <span className="font-medium text-slate-700">
                            {patient.sessions.length} session
                            {patient.sessions.length !== 1 ? "s" : ""}
                          </span>
                        </div>
                        <div className="flex items-center space-x-1 text-slate-500">
                          <ClockIcon className="h-4 w-4" />
                          <span className="text-xs">
                            {new Date(
                              patient.sessions[0]?.updated_at || ""
                            ).toLocaleTimeString()}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-3">
                      {patient.sessions.slice(0, 2).map((session) => (
                        <div
                          key={session.id}
                          onClick={() =>
                            handleJoinRoom(session.room_id, patient.id)
                          }
                          className="flex items-center justify-between p-3 bg-slate-50 hover:bg-slate-100 rounded-xl cursor-pointer transition-colors duration-200 border border-slate-200"
                          title={`Click to join room ${session.room_id}`}
                        >
                          <div className="flex items-center space-x-3">
                            <div
                              className={`w-3 h-3 rounded-full ${
                                session.status === "active"
                                  ? "bg-green-500 animate-pulse"
                                  : "bg-slate-400"
                              }`}
                            ></div>
                            <span className="text-sm font-medium text-slate-700 truncate">
                              Room: {session.room_id.split("-")[0]}...
                            </span>
                          </div>
                          <Badge
                            variant={
                              session.status === "active" ? "live" : "secondary"
                            }
                          >
                            {session.status === "active" ? (
                              <>
                                <PlayIcon className="h-3 w-3" />
                                Live
                              </>
                            ) : (
                              <>
                                <StopIcon className="h-3 w-3" />
                                Stopped
                              </>
                            )}
                          </Badge>
                        </div>
                      ))}

                      {patient.sessions.length > 2 && (
                        <div className="text-center">
                          <Badge variant="secondary" className="text-xs">
                            +{patient.sessions.length - 2} more sessions
                          </Badge>
                        </div>
                      )}
                    </div>

                    <Button
                      onClick={() => handleViewStream(patient.id)}
                      className="w-full inline-flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-xl transition-colors duration-200"
                    >
                      <EyeIcon className="h-4 w-4" />
                      View Live Stream
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
