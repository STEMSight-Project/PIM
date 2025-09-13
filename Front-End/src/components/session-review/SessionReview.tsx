"use client";

import { Card, CardContent, CardHeader } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import type { Note, SessionWithPatient } from "@/hooks";
import { useNotes, usePatients, useSessions } from "@/hooks";
import React, { useEffect, useState } from "react";
import TabsContainer from "./Tabs/TabsContainer";
import VideoPlayer from "./VideoPlayer";

type ViewMode = "gallery" | "player";

const SessionReview: React.FC = () => {
  const [viewMode, setViewMode] = useState<ViewMode>("gallery");
  const [selectedSession, setSelectedSession] =
    useState<SessionWithPatient | null>(null);
  const [selectedVideoIndex, setSelectedVideoIndex] = useState(0);
  const [currentTimestamp, setCurrentTimestamp] = useState(0);
  const [notes, setNotes] = useState<Note[]>([]);

  const {
    sessions,
    loading: sessionsLoading,
    error: sessionsError,
    fetchStitchedSessions,
  } = useSessions();

  const {
    notes: hookNotes,
    loading: notesLoading,
    error: notesError,
    fetchNotesForPatient,
    fetchNotesForVideo,
  } = useNotes();

  const { patients, isLoading: patientsLoading } = usePatients();

  useEffect(() => {
    fetchStitchedSessions();
  }, [fetchStitchedSessions]);

  useEffect(() => {
    if (selectedSession) {
      fetchNotesForPatient(selectedSession.patient.id);
    }
  }, [selectedSession, fetchNotesForPatient]);

  useEffect(() => {
    setNotes(hookNotes);
  }, [hookNotes]);

  const handleSessionSelect = (session: SessionWithPatient) => {
    setSelectedSession(session);
    setSelectedVideoIndex(0);
    setCurrentTimestamp(0);
    setViewMode("player");
  };

  const handleBackToGallery = () => {
    setViewMode("gallery");
    setSelectedSession(null);
    setSelectedVideoIndex(0);
    setCurrentTimestamp(0);
  };

  const handleVideoSelect = (videoIndex: number) => {
    setSelectedVideoIndex(videoIndex);
    setCurrentTimestamp(0);
  };

  const handleTimeUpdate = (time: number) => {
    setCurrentTimestamp(time);
  };

  if (sessionsLoading || patientsLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4">
        <Loading size="lg" text="Loading session data..." />
      </div>
    );
  }

  if (sessionsError) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4">
        <Card className="max-w-md w-full">
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
              <p className="text-gray-600 mb-4">{sessionsError}</p>
              <button
                onClick={() => fetchStitchedSessions()}
                className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors"
              >
                Try Again
              </button>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Gallery View - Session Selection
  if (viewMode === "gallery") {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Page Header */}
        <div className="mb-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-gray-900 mb-2">
                Session Gallery
              </h2>
              <p className="text-gray-600">
                Select a session to review video recordings and analysis data
              </p>
            </div>
            <div className="mt-4 sm:mt-0 flex items-center space-x-3">
              <div className="bg-blue-50 text-blue-700 px-3 py-1 rounded-full text-sm font-medium flex items-center space-x-2">
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                  />
                </svg>
                <span>{sessions.length} Sessions Available</span>
              </div>
              <button className="inline-flex items-center px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500">
                <svg
                  className="w-4 h-4 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.414A1 1 0 013 6.707V4z"
                  />
                </svg>
                Filter
              </button>
            </div>
          </div>
        </div>

        {/* Sessions Grid */}
        {sessions.length === 0 ? (
          <Card>
            <CardContent className="py-12">
              <div className="text-center">
                <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                  <svg
                    className="w-8 h-8 text-gray-400"
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
                <h3 className="text-lg font-medium text-gray-900 mb-2">
                  No Sessions Found
                </h3>
                <p className="text-gray-500 mb-4">
                  There are no recorded sessions available at the moment.
                </p>
                <button
                  onClick={() => fetchStitchedSessions()}
                  className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                >
                  <svg
                    className="w-4 h-4 mr-2"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                    />
                  </svg>
                  Refresh Sessions
                </button>
              </div>
            </CardContent>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {sessions.map((session, index) => (
              <Card
                key={session.patient.id + index}
                className="group cursor-pointer hover:shadow-lg hover:border-purple-300 transition-all duration-200"
                onClick={() => handleSessionSelect(session)}
              >
                {/* Session Preview */}
                <div className="relative h-48 bg-gradient-to-br from-purple-500 to-blue-600 flex items-center justify-center">
                  <div className="text-white text-center">
                    <svg
                      className="w-12 h-12 mx-auto mb-2 opacity-80"
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
                    <div className="text-sm font-medium opacity-90">
                      Session Recording
                    </div>
                  </div>
                  <div className="absolute top-3 right-3 bg-white/20 backdrop-blur-sm rounded-lg px-2 py-1 text-xs text-white font-medium">
                    {session.videos.length} Video
                    {session.videos.length !== 1 ? "s" : ""}
                  </div>
                  <div className="absolute top-3 left-3 bg-white/20 backdrop-blur-sm rounded-lg px-2 py-1 text-xs text-white font-medium">
                    {session.detections.length} Detection
                    {session.detections.length !== 1 ? "s" : ""}
                  </div>
                </div>

                {/* Session Details */}
                <CardContent className="p-5">
                  <h3 className="font-semibold text-lg text-gray-900 mb-3 group-hover:text-purple-600 transition-colors">
                    {session.patient.first_name} {session.patient.last_name}
                  </h3>

                  <div className="space-y-2 text-sm text-gray-600 mb-4">
                    <div className="flex items-center">
                      <svg
                        className="w-4 h-4 mr-2 text-gray-400"
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
                      <span>
                        {new Date(session.startTime).toLocaleDateString(
                          "en-US",
                          {
                            year: "numeric",
                            month: "short",
                            day: "numeric",
                          }
                        )}
                      </span>
                    </div>

                    <div className="flex items-center">
                      <svg
                        className="w-4 h-4 mr-2 text-gray-400"
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
                      <span>
                        {new Date(session.startTime).toLocaleTimeString([], {
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
                        {" - "}
                        {new Date(session.endTime).toLocaleTimeString([], {
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
                      </span>
                    </div>

                    <div className="flex items-center">
                      <svg
                        className="w-4 h-4 mr-2 text-gray-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                        />
                      </svg>
                      <span>Patient ID: {session.patient.id.slice(-8)}</span>
                    </div>
                  </div>

                  {/* Session Stats */}
                  <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                    <span className="text-xs text-gray-500 uppercase tracking-wide font-medium">
                      Duration
                    </span>
                    <span className="text-sm font-semibold text-gray-900">
                      {Math.round(
                        (new Date(session.endTime).getTime() -
                          new Date(session.startTime).getTime()) /
                          60000
                      )}
                      m
                    </span>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    );
  }

  // Player View - Video Playback
  const currentVideo = selectedSession?.videos[selectedVideoIndex];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      {/* Back Navigation */}
      <div className="mb-6">
        <button
          onClick={handleBackToGallery}
          className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors"
        >
          <svg
            className="w-4 h-4 mr-2"
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
          Back to Gallery
        </button>
      </div>

      {/* Session Header */}
      {selectedSession && (
        <div className="mb-6">
          <Card>
            <CardContent className="py-4">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <svg
                      className="w-6 h-6 text-purple-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                      />
                    </svg>
                  </div>
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900">
                      {selectedSession.patient.first_name}{" "}
                      {selectedSession.patient.last_name}
                    </h2>
                    <p className="text-sm text-gray-600">
                      Session from{" "}
                      {new Date(selectedSession.startTime).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                <div className="mt-4 sm:mt-0 flex items-center space-x-4 text-sm text-gray-600">
                  <div className="flex items-center space-x-1">
                    <svg
                      className="w-4 h-4"
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
                    <span>{selectedSession.videos.length} Videos</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <svg
                      className="w-4 h-4"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                      />
                    </svg>
                    <span>{selectedSession.detections.length} Detections</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-6">
        {/* Video Player Section */}
        <div className="xl:col-span-3">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-gray-900">
                  Video Playback
                </h3>
                {currentVideo && selectedSession && (
                  <div className="text-sm text-gray-600">
                    Video {selectedVideoIndex + 1} of{" "}
                    {selectedSession.videos.length}
                  </div>
                )}
              </div>
            </CardHeader>
            <CardContent>
              {currentVideo ? (
                <div className="space-y-4">
                  <div className="bg-gray-900 rounded-lg overflow-hidden aspect-video">
                    <VideoPlayer
                      videoUrl={currentVideo.file_path || null}
                      currentTimestamp={currentTimestamp}
                      onTimeUpdate={handleTimeUpdate}
                    />
                  </div>
                  <div className="flex items-center justify-between text-sm text-gray-600">
                    <div className="flex items-center space-x-4">
                      <span>
                        <strong>File:</strong>{" "}
                        {currentVideo.file_path?.split("/").pop() || "Unknown"}
                      </span>
                      <span>
                        <strong>Timestamp:</strong>{" "}
                        {Math.floor(currentTimestamp)}s
                      </span>
                    </div>
                    <div className="flex space-x-2">
                      <button className="px-3 py-1 border border-gray-300 rounded text-xs hover:bg-gray-50 transition-colors">
                        <svg
                          className="w-3 h-3 mr-1 inline"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"
                          />
                        </svg>
                        Full Screen
                      </button>
                      <button className="px-3 py-1 border border-gray-300 rounded text-xs hover:bg-gray-50 transition-colors">
                        <svg
                          className="w-3 h-3 mr-1 inline"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                          />
                        </svg>
                        Download
                      </button>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
                  <div className="text-center">
                    <svg
                      className="w-12 h-12 mx-auto mb-3 text-gray-400"
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
                    <p className="text-gray-500">No video available</p>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Video Selection Grid */}
          {selectedSession && selectedSession.videos.length > 1 && (
            <Card className="mt-6">
              <CardHeader>
                <h3 className="text-lg font-semibold text-gray-900">
                  Video Selection
                </h3>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3">
                  {selectedSession.videos.map((video, index) => (
                    <button
                      key={video.id}
                      onClick={() => handleVideoSelect(index)}
                      className={`relative p-4 rounded-lg border-2 transition-all text-sm font-medium ${
                        index === selectedVideoIndex
                          ? "border-purple-500 bg-purple-50 text-purple-700"
                          : "border-gray-200 bg-white text-gray-700 hover:border-gray-300 hover:bg-gray-50"
                      }`}
                    >
                      <div className="text-center">
                        <svg
                          className="w-6 h-6 mx-auto mb-1"
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
                        Video {index + 1}
                      </div>
                      {index === selectedVideoIndex && (
                        <div className="absolute -top-1 -right-1 w-3 h-3 bg-purple-500 rounded-full"></div>
                      )}
                    </button>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Sidebar with Tabs */}
        <div className="xl:col-span-1">
          <Card className="h-fit">
            <TabsContainer
              sessionId={selectedSession?.patient.id || ""}
              notes={notes}
              setNotes={setNotes}
              setCurrentTimestamp={setCurrentTimestamp}
              currentVideoTime={currentTimestamp}
              videoId={currentVideo?.id || ""}
              patientId={selectedSession?.patient.id || ""}
            />
          </Card>
        </div>
      </div>
    </div>
  );
};

export default SessionReview;
