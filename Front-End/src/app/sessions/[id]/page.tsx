"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import {
  ambulanceSessionService,
  type AmbulanceSession,
} from "@/services/ambulanceSessionService";
import { formatDate } from "@/utils/cn";
import {
  ArrowLeftIcon,
  CalendarIcon,
  ClockIcon,
  PlayIcon,
  ServerIcon,
  VideoCameraIcon,
  DocumentTextIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { recordingService } from "@/services/videoService";

export default function SessionDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.id as string;

  const [session, setSession] = useState<AmbulanceSession | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [totalFileSize, setTotalFileSize] = useState<number>(0);

  useEffect(() => {
    const loadSession = async () => {
      if (!sessionId) return;

      try {
        setIsLoading(true);
        setError(null);

        const result = await ambulanceSessionService.getSessionById(sessionId);

        if (!result.success || !result.data) {
          setError(result.error || "Session not found");
          return;
        }

        setSession(result.data);

        // Fetch recordings to calculate total file size
        try {
          const recordingsResponse =
            await recordingService.getRecordingsBySession(sessionId);
          if (recordingsResponse.data) {
            const totalSize = recordingsResponse.data.reduce(
              (sum, recording) => {
                return sum + (recording.file_size || 0);
              },
              0
            );
            setTotalFileSize(totalSize);
          }
        } catch (err) {
          console.error("Failed to fetch recordings for file size:", err);
          // Use session file_size as fallback
          setTotalFileSize(result.data.file_size || 0);
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to load session");
      } finally {
        setIsLoading(false);
      }
    };

    loadSession();
  }, [sessionId]);

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading session details..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error || !session) {
    return (
      <DashboardLayout>
        <div className="max-w-md mx-auto mt-12">
          <Alert variant="error">{error || "Session not found"}</Alert>
          <div className="mt-6 text-center">
            <Button onClick={() => router.push("/recent-live-session")}>
              <ArrowLeftIcon className="h-4 w-4 mr-2" />
              Back to Sessions
            </Button>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  // Check is_active field (new streaming sessions table) or status field (old recordings table)
  const isActive = session.is_active ?? session.status === "active";
  const duration = ambulanceSessionService.getSessionDuration(session);
  const fileSize = ambulanceSessionService.formatFileSize(totalFileSize);
  const sessionStart =
    session.started_at || session.session_start || session.created_at;
  const sessionEnd = session.ended_at || session.session_end;

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              onClick={() => router.push("/recent-live-session")}
            >
              <ArrowLeftIcon className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                Session Details
              </h1>
              <p className="text-gray-600">
                Session ID: {sessionId.slice(0, 8)}...
              </p>
            </div>
          </div>
          <div className="flex space-x-3">
            {isActive && (
              <Button
                variant="primary"
                onClick={() =>
                  router.push(
                    `/streamingDash?ambulance=${
                      session.ambulance_id || session.session_id
                    }`
                  )
                }
              >
                <PlayIcon className="h-4 w-4 mr-2" />
                Watch Live
              </Button>
            )}
            <Button
              variant="outline"
              onClick={() =>
                router.push(`/recent-live-session/subject/${sessionId}`)
              }
            >
              <VideoCameraIcon className="h-4 w-4 mr-2" />
              Watch Recordings
            </Button>
          </div>
        </div>

        {/* Status Banner */}
        <Card
          className={`p-4 ${
            isActive
              ? "bg-green-50 border-green-200"
              : "bg-blue-50 border-blue-200"
          }`}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              {isActive ? (
                <PlayIcon className="w-6 h-6 text-green-600" />
              ) : (
                <DocumentTextIcon className="w-6 h-6 text-blue-600" />
              )}
              <div>
                <p
                  className={`font-medium ${
                    isActive ? "text-green-900" : "text-blue-900"
                  }`}
                >
                  Status:{" "}
                  {isActive ? "Recording Active" : "Recording Completed"}
                </p>
                <p
                  className={`text-sm ${
                    isActive ? "text-green-700" : "text-blue-700"
                  }`}
                >
                  {isActive
                    ? "This session is currently being recorded"
                    : "This recording session has been completed and saved"}
                </p>
              </div>
            </div>
          </div>
        </Card>

        {/* Session Info Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <CalendarIcon className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Started</p>
                <p className="text-sm font-bold text-gray-900">
                  {formatDate(sessionStart)}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <ClockIcon className="h-6 w-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Duration</p>
                <p className="text-sm font-bold text-gray-900">{duration}</p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <ServerIcon className="h-6 w-6 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">File Size</p>
                <p className="text-sm font-bold text-gray-900">{fileSize}</p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <VideoCameraIcon className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Status</p>
                <p className="text-sm font-bold text-gray-900 capitalize">
                  {isActive ? "Active" : "Completed"}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Session Details */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Technical Details */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Technical Details
            </h3>
            <div className="space-y-3">
              {session.session_id && (
                <div className="flex justify-between py-2 border-b border-gray-200">
                  <span className="text-sm font-medium text-gray-600">
                    Session ID
                  </span>
                  <span className="text-sm text-gray-900 font-mono">
                    {session.session_id}
                  </span>
                </div>
              )}
              {session.ambulance_id && (
                <div className="flex justify-between py-2 border-b border-gray-200">
                  <span className="text-sm font-medium text-gray-600">
                    Ambulance ID
                  </span>
                  <span className="text-sm text-gray-900 font-mono">
                    {session.ambulance_id}
                  </span>
                </div>
              )}
              <div className="flex justify-between py-2 border-b border-gray-200">
                <span className="text-sm font-medium text-gray-600">
                  Record ID
                </span>
                <span className="text-sm text-gray-900 font-mono">
                  {session.id}
                </span>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-200">
                <span className="text-sm font-medium text-gray-600">
                  Created At
                </span>
                <span className="text-sm text-gray-900">
                  {formatDate(session.created_at)}
                </span>
              </div>
              {session.updated_at && (
                <div className="flex justify-between py-2 border-b border-gray-200">
                  <span className="text-sm font-medium text-gray-600">
                    Updated At
                  </span>
                  <span className="text-sm text-gray-900">
                    {formatDate(session.updated_at)}
                  </span>
                </div>
              )}
            </div>
          </Card>

          {/* Recording Details */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Recording Details
            </h3>
            <div className="space-y-3">
              {session.recording_path && (
                <div className="py-2 border-b border-gray-200">
                  <span className="text-sm font-medium text-gray-600 block mb-1">
                    Recording Path
                  </span>
                  <span className="text-sm text-gray-900 break-all">
                    {session.recording_path}
                  </span>
                </div>
              )}
              {sessionEnd && (
                <div className="flex justify-between py-2 border-b border-gray-200">
                  <span className="text-sm font-medium text-gray-600">
                    Ended At
                  </span>
                  <span className="text-sm text-gray-900">
                    {formatDate(sessionEnd)}
                  </span>
                </div>
              )}
            </div>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
