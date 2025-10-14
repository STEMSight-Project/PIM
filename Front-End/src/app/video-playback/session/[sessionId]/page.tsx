"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Card, CardContent, CardHeader } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useRecordings } from "@/hooks";
import {
  formatDate,
  formatDuration,
  formatFileSize,
  formatTime,
} from "@/lib/utils";
import type { RecordingResponse } from "@/services/videoService";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";

export default function SessionDetailPage() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;

  const { recordings, isLoading, error, fetchRecordingsBySession, clearError } =
    useRecordings();

  const [selectedRecording, setSelectedRecording] =
    useState<RecordingResponse | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (sessionId) {
      fetchRecordingsBySession(sessionId);
    }
  }, [sessionId, fetchRecordingsBySession]);

  useEffect(() => {
    // Auto-select first recording when data loads
    if (recordings.length > 0 && !selectedRecording) {
      setSelectedRecording(recordings[0]);
    }
  }, [recordings, selectedRecording]);

  const handleRecordingSelect = (recording: RecordingResponse) => {
    setSelectedRecording(recording);
    // Scroll video player into view on mobile
    if (videoRef.current) {
      videoRef.current.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const handleBackToSessions = () => {
    router.push("/video-playback");
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-20">
          <Loading size="lg" text="Loading session recordings..." />
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
                  Error Loading Recordings
                </h3>
                <p className="text-gray-600 mb-4">{error}</p>
                <div className="flex gap-3 justify-center">
                  <button
                    onClick={handleBackToSessions}
                    className="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
                  >
                    Back to Sessions
                  </button>
                  <button
                    onClick={() => {
                      clearError();
                      fetchRecordingsBySession(sessionId);
                    }}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Try Again
                  </button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  if (recordings.length === 0) {
    return (
      <DashboardLayout>
        <div className="px-4 py-8">
          <Card className="max-w-2xl mx-auto">
            <CardContent className="pt-6">
              <div className="text-center py-12">
                <div className="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-10 h-10 text-gray-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  No Recordings Found
                </h3>
                <p className="text-gray-600 mb-6">
                  This session doesn't have any recordings available.
                </p>
                <button
                  onClick={handleBackToSessions}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Back to Sessions
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  const sessionInfo = recordings[0];
  const totalDuration = recordings.reduce(
    (sum, rec) => sum + (rec.duration || 0),
    0
  );

  return (
    <DashboardLayout>
      <div className="px-4 py-8">
        <div className="max-w-7xl mx-auto">
          {/* Back Button */}
          <button
            onClick={handleBackToSessions}
            className="mb-6 flex items-center text-gray-600 hover:text-gray-900 transition-colors"
          >
            <svg
              className="w-5 h-5 mr-2"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Sessions
          </button>

          {/* Session Header */}
          <div className="mb-8">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                  {sessionInfo.session_name || "Session Recordings"}
                </h1>
                <p className="text-gray-600">
                  Ambulance {sessionInfo.ambulance_number}
                </p>
              </div>
              <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                <svg
                  className="w-4 h-4 mr-1"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clipRule="evenodd"
                  />
                </svg>
                Archived
              </span>
            </div>

            {/* Session Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-blue-600 mr-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                  />
                </svg>
                <div>
                  <p className="text-sm text-gray-600">Total Recordings</p>
                  <p className="text-xl font-bold text-gray-900">
                    {recordings.length}
                  </p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-purple-600 mr-3"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                <div>
                  <p className="text-sm text-gray-600">Total Duration</p>
                  <p className="text-xl font-bold text-gray-900">
                    {formatDuration(totalDuration)}
                  </p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <svg
                  className="w-8 h-8 text-green-600 mr-3"
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
                <div>
                  <p className="text-sm text-gray-600">Recorded On</p>
                  <p className="text-xl font-bold text-gray-900">
                    {formatDate(sessionInfo.created_at)
                      .split(" ")
                      .slice(0, 3)
                      .join(" ")}
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Video Player - Takes 2/3 width on large screens */}
            <div className="lg:col-span-2">
              <Card>
                <CardHeader>
                  <h2 className="text-xl font-semibold text-gray-900">
                    {selectedRecording
                      ? `Recording ${recordings.indexOf(selectedRecording) + 1}`
                      : "Select a Recording"}
                  </h2>
                  {selectedRecording && (
                    <p className="text-sm text-gray-600">
                      {formatDate(selectedRecording.created_at)}
                    </p>
                  )}
                </CardHeader>
                <CardContent>
                  {selectedRecording?.public_video_url ? (
                    <div className="space-y-4">
                      <video
                        ref={videoRef}
                        key={selectedRecording.id}
                        controls
                        className="w-full rounded-lg bg-black"
                        src={selectedRecording.public_video_url}
                      >
                        Your browser does not support the video tag.
                      </video>

                      {/* Recording Info */}
                      <div className="grid grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm text-gray-600">Duration</p>
                          <p className="text-lg font-semibold text-gray-900">
                            {formatDuration(selectedRecording.duration)}
                          </p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">File Size</p>
                          <p className="text-lg font-semibold text-gray-900">
                            {formatFileSize(selectedRecording.file_size)}
                          </p>
                        </div>
                        {selectedRecording.session_start && (
                          <div>
                            <p className="text-sm text-gray-600">Started</p>
                            <p className="text-lg font-semibold text-gray-900">
                              {formatTime(selectedRecording.session_start)}
                            </p>
                          </div>
                        )}
                        {selectedRecording.session_end && (
                          <div>
                            <p className="text-sm text-gray-600">Ended</p>
                            <p className="text-lg font-semibold text-gray-900">
                              {formatTime(selectedRecording.session_end)}
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  ) : (
                    <div className="flex items-center justify-center h-64 bg-gray-100 rounded-lg">
                      <p className="text-gray-500">
                        No video URL available for this recording
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Recording List - Takes 1/3 width on large screens */}
            <div className="lg:col-span-1">
              <Card>
                <CardHeader>
                  <h2 className="text-xl font-semibold text-gray-900">
                    All Recordings
                  </h2>
                  <p className="text-sm text-gray-600">
                    {recordings.length}{" "}
                    {recordings.length === 1 ? "recording" : "recordings"}
                  </p>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2 max-h-[600px] overflow-y-auto">
                    {recordings.map((recording, index) => (
                      <button
                        key={recording.id}
                        onClick={() => handleRecordingSelect(recording)}
                        className={`w-full text-left p-4 rounded-lg border-2 transition-all ${
                          selectedRecording?.id === recording.id
                            ? "border-blue-500 bg-blue-50"
                            : "border-gray-200 hover:border-gray-300 bg-white"
                        }`}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <p className="font-semibold text-gray-900 mb-1">
                              Recording {index + 1}
                            </p>
                            <p className="text-xs text-gray-500 mb-2">
                              {formatDate(recording.created_at)}
                            </p>
                            <div className="flex items-center text-xs text-gray-600">
                              <svg
                                className="w-3 h-3 mr-1"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                                />
                              </svg>
                              {formatDuration(recording.duration)}
                            </div>
                          </div>
                          {selectedRecording?.id === recording.id && (
                            <div className="flex-shrink-0">
                              <svg
                                className="w-5 h-5 text-blue-600"
                                fill="currentColor"
                                viewBox="0 0 20 20"
                              >
                                <path
                                  fillRule="evenodd"
                                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                                  clipRule="evenodd"
                                />
                              </svg>
                            </div>
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
