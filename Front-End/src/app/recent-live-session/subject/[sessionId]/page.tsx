"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useRecordings } from "@/hooks/useRecordings";
import {
  ArrowLeftIcon,
  CheckCircleIcon,
  ClockIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function SubjectViewPage() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;

  const { recordings, isLoading, error, fetchRecordingsBySession, clearError } =
    useRecordings();

  const [currentVideoUrl, setCurrentVideoUrl] = useState<string | null>(null);
  const [isVideoModalOpen, setIsVideoModalOpen] = useState(false);

  useEffect(() => {
    if (sessionId) {
      fetchRecordingsBySession(sessionId);
    }
  }, [sessionId, fetchRecordingsBySession]);

  const playVideo = (videoUrl: string) => {
    setCurrentVideoUrl(videoUrl);
    setIsVideoModalOpen(true);
  };

  const closeVideoModal = () => {
    setIsVideoModalOpen(false);
    setCurrentVideoUrl(null);
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return "0 B";
    const k = 1024;
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
  };

  const formatDuration = (seconds: number): string => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);

    if (hrs > 0) {
      return `${hrs}:${mins.toString().padStart(2, "0")}:${secs
        .toString()
        .padStart(2, "0")}`;
    }
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  const formatDate = (dateString: string): string => {
    const date = new Date(dateString);
    return date.toLocaleString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading subject recordings..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <div className="space-y-6">
          <Button variant="outline" onClick={() => router.back()}>
            <ArrowLeftIcon className="h-4 w-4 mr-2" />
            Back to Sessions
          </Button>
          <Alert variant="error">
            <div className="flex items-center justify-between">
              <span>{error}</span>
              <Button
                variant="outline"
                size="sm"
                onClick={() => window.location.reload()}
              >
                Try Again
              </Button>
            </div>
          </Alert>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Video Modal */}
        {isVideoModalOpen && currentVideoUrl && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75"
            onClick={closeVideoModal}
          >
            <div
              className="relative w-full max-w-6xl mx-4"
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={closeVideoModal}
                className="absolute -top-10 right-0 text-white hover:text-gray-300 text-xl font-bold"
              >
                ✕ Close
              </button>
              <video
                src={currentVideoUrl}
                controls
                autoPlay
                className="w-full rounded-lg shadow-2xl"
              >
                Your browser does not support the video tag.
              </video>
            </div>
          </div>
        )}

        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Button variant="outline" onClick={() => router.back()}>
              <ArrowLeftIcon className="h-4 w-4 mr-2" />
              Back
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                Subject Recordings
              </h1>
              <p className="text-gray-600">
                Session: {sessionId.slice(0, 8)}...
              </p>
            </div>
          </div>
        </div>

        {/* Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <VideoCameraIcon className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Total Recordings
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {recordings.length}
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
                <p className="text-sm font-medium text-gray-600">
                  Total Duration
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {formatDuration(
                    recordings.reduce((acc, r) => acc + (r.duration || 0), 0)
                  )}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <svg
                  className="h-6 w-6 text-orange-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M5 19a2 2 0 01-2-2V7a2 2 0 012-2h4l2 2h4a2 2 0 012 2v1M5 19h14a2 2 0 002-2v-5a2 2 0 00-2-2H9a2 2 0 00-2 2v5a2 2 0 01-2 2z"
                  />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Size</p>
                <p className="text-2xl font-bold text-gray-900">
                  {formatFileSize(
                    recordings.reduce((acc, r) => acc + (r.file_size || 0), 0)
                  )}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Recordings Grid */}
        {recordings.length === 0 ? (
          <Card className="p-12">
            <div className="text-center">
              <VideoCameraIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No recordings found
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                No recordings available for this session.
              </p>
            </div>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {recordings.map((recording) => {
              return (
                <Card
                  key={recording.id}
                  className="overflow-hidden transition-all hover:shadow-md"
                >
                  {/* Video Thumbnail Placeholder */}
                  <div className="relative bg-gray-900 aspect-video">
                    {recording.public_video_url ? (
                      <video
                        src={recording.public_video_url}
                        className="w-full h-full object-cover"
                        onClick={(e) => {
                          e.stopPropagation();
                          playVideo(recording.public_video_url!);
                        }}
                      />
                    ) : (
                      <div className="absolute inset-0 flex items-center justify-center">
                        <VideoCameraIcon className="h-16 w-16 text-gray-600" />
                      </div>
                    )}
                    <div className="absolute bottom-2 right-2 bg-black bg-opacity-75 px-2 py-1 rounded text-xs text-white">
                      {formatDuration(recording.duration || 0)}
                    </div>
                  </div>

                  {/* Recording Info */}
                  <div className="p-4">
                    <div className="space-y-2">
                      <div className="flex items-center justify-between">
                        <h3 className="font-semibold text-gray-900 truncate">
                          Camera {recording.camera_id || "Unknown"}
                        </h3>
                        <span className="text-xs text-gray-500">
                          {formatFileSize(recording.file_size || 0)}
                        </span>
                      </div>

                      <div className="flex items-center text-sm text-gray-600">
                        <ClockIcon className="h-4 w-4 mr-1" />
                        {formatDate(recording.created_at)}
                      </div>

                      {recording.recording_path && (
                        <div className="text-xs text-gray-400 truncate">
                          {recording.recording_path}
                        </div>
                      )}
                    </div>

                    <div className="mt-4 pt-3 border-t border-gray-200">
                      {recording.public_video_url && (
                        <Button
                          variant="primary"
                          size="sm"
                          className="w-full"
                          onClick={(e) => {
                            e.stopPropagation();
                            playVideo(recording.public_video_url!);
                          }}
                        >
                          <svg
                            className="h-4 w-4 mr-1"
                            fill="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path d="M8 5v14l11-7z" />
                          </svg>
                          Watch Video
                        </Button>
                      )}
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
