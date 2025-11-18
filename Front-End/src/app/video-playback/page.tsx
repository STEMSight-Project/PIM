"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Card, CardContent, CardHeader } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useRecordings } from "@/hooks";
import { formatDate, formatDuration } from "@/lib/utils";
import {
  ChevronDownIcon,
  ChevronUpIcon,
  ClockIcon,
  TruckIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

interface AmbulanceGroup {
  ambulance_number: string;
  sessions: any[];
  totalRecordings: number;
  totalDuration: number;
}

// Helper function to format session display name
const formatSessionName = (session: any): string => {
  if (!session.recordings || session.recordings.length === 0) {
    return "Unknown Session";
  }

  const firstRecording = session.recordings[0];
  const date = new Date(firstRecording.session_start || firstRecording.created_at);
  
  // Format: "Nov 17, 2025 • 2:30 PM"
  const formattedDate = date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric' 
  });
  const formattedTime = date.toLocaleTimeString('en-US', { 
    hour: 'numeric', 
    minute: '2-digit',
    hour12: true 
  });

  return `${formattedDate} • ${formattedTime}`;
};

export default function VideoPlaybackPage() {
  const router = useRouter();
  const {
    sessions,
    isLoading,
    error,
    fetchSessionsWithRecordings,
    clearError,
  } = useRecordings();

  const [expandedAmbulances, setExpandedAmbulances] = useState<Set<string>>(
    new Set()
  );

  useEffect(() => {
    fetchSessionsWithRecordings();
  }, [fetchSessionsWithRecordings]);

  // Group sessions by ambulance and sort by ambulance number
  const ambulanceGroups = useMemo((): AmbulanceGroup[] => {
    const grouped = sessions.reduce((acc, session) => {
      const ambulanceNumber = session.ambulance_number || "Unknown";

      if (!acc[ambulanceNumber]) {
        acc[ambulanceNumber] = {
          ambulance_number: ambulanceNumber,
          sessions: [],
          totalRecordings: 0,
          totalDuration: 0,
        };
      }

      acc[ambulanceNumber].sessions.push(session);
      acc[ambulanceNumber].totalRecordings += session.total_recordings || 0;
      acc[ambulanceNumber].totalDuration += session.total_duration || 0;

      return acc;
    }, {} as Record<string, AmbulanceGroup>);

    // Convert to array and sort by ambulance number
    return Object.values(grouped).sort((a, b) => {
      // Extract numeric part from ambulance number (e.g., "AMB-001" -> 1)
      const getNumber = (num: string) => {
        const match = num.match(/\d+/);
        return match ? parseInt(match[0], 10) : 0;
      };
      return getNumber(a.ambulance_number) - getNumber(b.ambulance_number);
    });
  }, [sessions]);

  const toggleAmbulance = (ambulanceNumber: string) => {
    setExpandedAmbulances((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(ambulanceNumber)) {
        newSet.delete(ambulanceNumber);
      } else {
        newSet.add(ambulanceNumber);
      }
      return newSet;
    });
  };

  const handleSessionClick = (sessionId: string) => {
    router.push(`/video-playback/session/${sessionId}`);
  };

  // Calculate overall statistics
  const totalStats = useMemo(() => {
    return {
      totalAmbulances: ambulanceGroups.length,
      totalSessions: sessions.length,
      totalRecordings: sessions.reduce((sum, s) => sum + s.total_recordings, 0),
      totalDuration: sessions.reduce((sum, s) => sum + s.total_duration, 0),
    };
  }, [ambulanceGroups, sessions]);

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-20">
          <Loading size="lg" text="Loading recorded sessions..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <div className="px-4">
          <Card className="max-w-md mx-auto">
            <CardContent className="pt-6">
              <div className="text-center">
                <div className="w-16 h-16 mx-auto mb-4 bg-red-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-8 h-8 text-red-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z"
                    />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  Error Loading Sessions
                </h3>
                <p className="text-gray-600 mb-4">{error}</p>
                <button
                  onClick={() => {
                    clearError();
                    fetchSessionsWithRecordings();
                  }}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Try Again
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  if (sessions.length === 0) {
    return (
      <DashboardLayout>
        <div className="px-4 py-8">
          <Card className="max-w-2xl mx-auto">
            <CardContent className="pt-6">
              <div className="text-center py-12">
                <div className="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                  <VideoCameraIcon className="w-10 h-10 text-gray-400" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  No Archived Recordings
                </h3>
                <p className="text-gray-600 mb-6">
                  No archived recordings available yet. Recordings will appear here
                  after ambulance sessions are completed and uploaded to storage.
                </p>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="px-4 py-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              Archived Camera Recordings
            </h1>
            <p className="text-gray-600">
              View past ambulance session recordings grouped by vehicle
            </p>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                      <TruckIcon className="w-6 h-6 text-blue-600" />
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">
                      Ambulances
                    </p>
                    <p className="text-2xl font-bold text-gray-900">
                      {totalStats.totalAmbulances}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                      <VideoCameraIcon className="w-6 h-6 text-purple-600" />
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">
                      Total Sessions
                    </p>
                    <p className="text-2xl font-bold text-gray-900">
                      {totalStats.totalSessions}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <svg
                        className="w-6 h-6 text-green-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                        />
                      </svg>
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">
                      Total Recordings
                    </p>
                    <p className="text-2xl font-bold text-gray-900">
                      {totalStats.totalRecordings}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                      <ClockIcon className="w-6 h-6 text-orange-600" />
                    </div>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">
                      Total Duration
                    </p>
                    <p className="text-2xl font-bold text-gray-900">
                      {formatDuration(totalStats.totalDuration)}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Ambulance Groups */}
          <div className="space-y-4">
            {ambulanceGroups.map((ambulanceGroup) => {
              const isExpanded = expandedAmbulances.has(
                ambulanceGroup.ambulance_number
              );

              return (
                <Card key={ambulanceGroup.ambulance_number}>
                  {/* Ambulance Header - Collapsible */}
                  <CardHeader
                    className="cursor-pointer hover:bg-gray-50 transition-colors"
                    onClick={() =>
                      toggleAmbulance(ambulanceGroup.ambulance_number)
                    }
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="flex-shrink-0">
                          <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                            <TruckIcon className="w-6 h-6 text-blue-600" />
                          </div>
                        </div>
                        <div>
                          <h2 className="text-xl font-semibold text-gray-900">
                            {ambulanceGroup.ambulance_number}
                          </h2>
                          <p className="text-sm text-gray-500">
                            {ambulanceGroup.sessions.length} session
                            {ambulanceGroup.sessions.length !== 1
                              ? "s"
                              : ""} • {ambulanceGroup.totalRecordings} recording
                            {ambulanceGroup.totalRecordings !== 1
                              ? "s"
                              : ""} •{" "}
                            {formatDuration(ambulanceGroup.totalDuration)}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-3">
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                          {ambulanceGroup.sessions.length} Session
                          {ambulanceGroup.sessions.length !== 1 ? "s" : ""}
                        </span>
                        {isExpanded ? (
                          <ChevronUpIcon className="w-6 h-6 text-gray-400" />
                        ) : (
                          <ChevronDownIcon className="w-6 h-6 text-gray-400" />
                        )}
                      </div>
                    </div>
                  </CardHeader>

                  {/* Sessions List - Collapsible */}
                  {isExpanded && (
                    <CardContent>
                      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-4">
                        {ambulanceGroup.sessions.map((session) => (
                          <Card
                            key={session.session_id}
                            className="hover:shadow-md transition-shadow cursor-pointer border border-gray-200"
                            onClick={(e) => {
                              e.stopPropagation();
                              handleSessionClick(session.session_id);
                            }}
                          >
                            <CardHeader className="pb-3">
                              <div className="flex items-start justify-between">
                                <div className="flex-1">
                                  <h3 className="text-base font-semibold text-gray-900 mb-1">
                                    {formatSessionName(session)}
                                  </h3>
                                  <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                                    Archived
                                  </span>
                                </div>
                              </div>
                            </CardHeader>
                            <CardContent>
                              <div className="space-y-2">
                                {/* Recording Count */}
                                <div className="flex items-center text-sm">
                                  <VideoCameraIcon className="w-4 h-4 text-gray-400 mr-2" />
                                  <span className="text-gray-600">
                                    {session.total_recordings}{" "}
                                    {session.total_recordings === 1
                                      ? "recording"
                                      : "recordings"}
                                  </span>
                                </div>

                                {/* Duration */}
                                <div className="flex items-center text-sm">
                                  <ClockIcon className="w-4 h-4 text-gray-400 mr-2" />
                                  <span className="text-gray-600">
                                    {formatDuration(session.total_duration)}
                                  </span>
                                </div>

                                {/* Date */}
                                {session.recordings[0] && (
                                  <div className="flex items-center text-sm">
                                    <svg
                                      className="w-4 h-4 text-gray-400 mr-2"
                                      fill="none"
                                      stroke="currentColor"
                                      viewBox="0 0 24 24"
                                    >
                                      <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth={2}
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                                      />
                                    </svg>
                                    <span className="text-gray-600">
                                      {formatDate(
                                        session.recordings[0].created_at
                                      )}
                                    </span>
                                  </div>
                                )}
                              </div>

                              <div className="mt-4 pt-3 border-t border-gray-200">
                                <button className="w-full px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
                                  View Recordings
                                </button>
                              </div>
                            </CardContent>
                          </Card>
                        ))}
                      </div>
                    </CardContent>
                  )}
                </Card>
              );
            })}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
