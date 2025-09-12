"use client";

import React, { useState, useEffect } from "react";
import { useSessions, useNotes, usePatients } from "@/hooks";
import SessionHeader from "./SessionHeader";
import VideoPlayer from "./VideoPlayer";
import TabsContainer from "./Tabs/TabsContainer";
import type { SessionWithPatient } from "@/hooks";
import type { Note } from "@/hooks";

type ViewMode = "gallery" | "player";

export const SessionReview: React.FC = () => {
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

  // Load sessions on mount
  useEffect(() => {
    fetchStitchedSessions();
  }, [fetchStitchedSessions]);

  // Load notes when session is selected
  useEffect(() => {
    if (selectedSession) {
      fetchNotesForPatient(selectedSession.patient.id);
    }
  }, [selectedSession, fetchNotesForPatient]);

  // Update local notes when hook notes change
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
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="bg-white rounded-2xl shadow-xl p-8 flex flex-col items-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
          <div className="text-lg font-medium text-gray-700">
            Loading sessions...
          </div>
          <div className="text-sm text-gray-500 mt-2">
            Please wait while we fetch your data
          </div>
        </div>
      </div>
    );
  }

  if (sessionsError) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-red-50 to-pink-100 flex items-center justify-center">
        <div className="bg-white rounded-2xl shadow-xl p-8 text-center max-w-md">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
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
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.99-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"
              />
            </svg>
          </div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Error Loading Sessions
          </h3>
          <p className="text-gray-600 mb-4">{sessionsError}</p>
          <button
            onClick={() => fetchStitchedSessions()}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  if (viewMode === "gallery") {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200 shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold text-gray-900">
                  Session Review
                </h1>
                <p className="text-gray-600 mt-1">
                  Review and analyze patient sessions
                </p>
              </div>
              <div className="flex items-center space-x-4">
                <div className="bg-blue-50 text-blue-700 px-3 py-1 rounded-full text-sm font-medium">
                  {sessions.length} Sessions Available
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {sessions.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg
                  className="w-12 h-12 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M7 4V2a1 1 0 011-1h8a1 1 0 011 1v2m-9 0h10m-9 0a2 2 0 00-2 2v12a2 2 0 002 2h8a2 2 0 002-2V6a2 2 0 00-2-2"
                  />
                </svg>
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                No Sessions Found
              </h3>
              <p className="text-gray-500">
                There are no recorded sessions available at the moment.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {sessions.map((session, index) => (
                <div
                  key={session.patient.id + index}
                  onClick={() => handleSessionSelect(session)}
                  className="bg-white rounded-xl shadow-sm border border-gray-200 hover:shadow-lg hover:border-blue-300 transition-all duration-200 cursor-pointer group overflow-hidden"
                >
                  {/* Session Image/Video Preview */}
                  <div className="relative h-48 bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center">
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
                          d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1.01M15 10h1.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      </svg>
                      <div className="text-sm font-medium opacity-90">
                        Patient Session
                      </div>
                    </div>
                    <div className="absolute top-3 right-3 bg-white/20 backdrop-blur-sm rounded-lg px-2 py-1 text-xs text-white font-medium">
                      {session.videos.length} Video
                      {session.videos.length !== 1 ? "s" : ""}
                    </div>
                  </div>

                  {/* Session Details */}
                  <div className="p-5">
                    <h3 className="font-semibold text-lg text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                      {session.patient.first_name} {session.patient.last_name}
                    </h3>

                    <div className="space-y-2 text-sm text-gray-600">
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
                            d="M8 7V3a1 1 0 011-1h6a1 1 0 011 1v4m-6 0h6m-6 0a2 2 0 00-2 2v12a2 2 0 002 2h6a2 2 0 002-2V6a2 2 0 00-2-2"
                          />
                        </svg>
                        {new Date(session.startTime).toLocaleDateString()}
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
                        {new Date(session.startTime).toLocaleTimeString([], {
                          hour: "2-digit",
                          minute: "2-digit",
                        })}{" "}
                        -{" "}
                        {new Date(session.endTime).toLocaleTimeString([], {
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
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
                            d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                          />
                        </svg>
                        {session.detections.length} Detection
                        {session.detections.length !== 1 ? "s" : ""}
                      </div>
                    </div>

                    {/* Action Button */}
                    <div className="mt-4 pt-3 border-t border-gray-100">
                      <div className="flex items-center justify-between">
                        <span className="text-xs text-gray-500 uppercase tracking-wide font-medium">
                          Patient ID
                        </span>
                        <span className="text-xs text-blue-600 font-mono">
                          {session.patient.id.slice(-8)}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }

  if (!selectedSession) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center">
        <div className="bg-white rounded-2xl shadow-xl p-8 text-center max-w-md">
          <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg
              className="w-8 h-8 text-blue-600"
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
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            No Session Selected
          </h3>
          <p className="text-gray-600 mb-4">
            Please select a session from the gallery to begin review.
          </p>
          <button
            onClick={() => setViewMode("gallery")}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Back to Gallery
          </button>
        </div>
      </div>
    );
  }

  const currentVideo = selectedSession.videos[selectedVideoIndex];
  const sessionDate = new Date(selectedSession.startTime).toLocaleDateString();
  const startTime = new Date(selectedSession.startTime).toLocaleTimeString();
  const endTime = new Date(selectedSession.endTime).toLocaleTimeString();

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Header with Session Info */}
      <div className="bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={handleBackToGallery}
                className="flex items-center px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
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
                Back to Gallery
              </button>

              <div className="h-6 border-l border-gray-300"></div>

              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {selectedSession.patient.first_name}{" "}
                  {selectedSession.patient.last_name}
                </h1>
                <p className="text-sm text-gray-600">
                  {sessionDate} • {startTime} - {endTime}
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <div className="bg-green-50 text-green-700 px-3 py-1 rounded-full text-sm font-medium">
                Station 1
              </div>
              <div className="bg-blue-50 text-blue-700 px-3 py-1 rounded-full text-sm font-medium">
                {selectedSession.videos.length} Video
                {selectedSession.videos.length !== 1 ? "s" : ""}
              </div>
              <div className="bg-purple-50 text-purple-700 px-3 py-1 rounded-full text-sm font-medium">
                {selectedSession.detections.length} Detection
                {selectedSession.detections.length !== 1 ? "s" : ""}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="grid grid-cols-1 xl:grid-cols-4 gap-6">
          {/* Video Player Section */}
          <div className="xl:col-span-3">
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
              {/* Video Player Header */}
              <div className="bg-gray-50 px-6 py-4 border-b border-gray-200">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg font-semibold text-gray-900">
                    Video Playback
                  </h2>
                  {currentVideo && (
                    <div className="text-sm text-gray-600">
                      Video {selectedVideoIndex + 1} of{" "}
                      {selectedSession.videos.length}
                    </div>
                  )}
                </div>
              </div>

              {/* Video Player */}
              <div className="p-6">
                {currentVideo ? (
                  <div className="space-y-4">
                    <div className="bg-gray-900 rounded-lg overflow-hidden aspect-video">
                      <VideoPlayer
                        videoUrl={currentVideo.file_path || null}
                        currentTimestamp={currentTimestamp}
                        onTimeUpdate={handleTimeUpdate}
                      />
                    </div>

                    {/* Video Info */}
                    <div className="flex items-center justify-between text-sm text-gray-600">
                      <div>
                        <span className="font-medium">File:</span>{" "}
                        {currentVideo.file_path?.split("/").pop() || "Unknown"}
                      </div>
                      <div>
                        <span className="font-medium">Timestamp:</span>{" "}
                        {Math.floor(currentTimestamp)}s
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
              </div>
            </div>

            {/* Video Selection */}
            {selectedSession.videos.length > 1 && (
              <div className="mt-6 bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Video Selection
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3">
                  {selectedSession.videos.map((video, index) => (
                    <button
                      key={video.id}
                      onClick={() => handleVideoSelect(index)}
                      className={`relative p-4 rounded-lg border-2 transition-all text-sm font-medium ${
                        index === selectedVideoIndex
                          ? "border-blue-500 bg-blue-50 text-blue-700"
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
                            d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1.01M15 10h1.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                          />
                        </svg>
                        Video {index + 1}
                      </div>
                      {index === selectedVideoIndex && (
                        <div className="absolute -top-1 -right-1 w-3 h-3 bg-blue-500 rounded-full"></div>
                      )}
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="xl:col-span-1">
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
              <TabsContainer
                sessionId={selectedSession.patient.id}
                notes={notes}
                setNotes={setNotes}
                setCurrentTimestamp={setCurrentTimestamp}
                currentVideoTime={currentTimestamp}
                videoId={currentVideo?.id || ""}
                patientId={selectedSession.patient.id}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SessionReview;
