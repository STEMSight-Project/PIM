"use client";

import { useState, useCallback } from "react";
import { usePatients } from "./usePatients";
import { useVideos } from "./useVideos";
import { usePatientEvents } from "./usePatientEvents";
import type { Patient } from "@/types";
import type { Video } from "./useVideos";
import type { PatientEvent } from "./usePatientEvents";

// Types from session review components
export interface Detection {
  id: string;
  type: string;
  timestamp: string;
  confidence: number;
  validation_status: string;
  created_at: string;
  video_id: string;
}

export interface SessionWithPatient {
  patient: Patient;
  videos: Video[];
  detections: Detection[];
  startTime: Date;
  endTime: Date;
}

interface UseSessionsReturn {
  sessions: SessionWithPatient[];
  selectedSession: SessionWithPatient | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchStitchedSessions: () => Promise<void>;
  selectSession: (session: SessionWithPatient | null) => void;
  clearError: () => void;
  clearSessions: () => void;
}

// Utility functions from session-review/utils
function formatDateTime(dateString: string): string {
  return new Date(dateString).toLocaleString();
}

function mapEventToDetection(event: PatientEvent): Detection {
  return {
    id: event.id,
    type: event.type,
    timestamp: event.timestamp,
    confidence: event.confidence,
    validation_status: event.validation_status,
    created_at: event.created_at,
    video_id: event.video_id,
  };
}

export function useSessions(): UseSessionsReturn {
  const [sessions, setSessions] = useState<SessionWithPatient[]>([]);
  const [selectedSession, setSelectedSession] =
    useState<SessionWithPatient | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { patients, fetchPatients } = usePatients();
  const { videos, fetchVideosForPatient } = useVideos();
  const { events, fetchEventsForVideo } = usePatientEvents();

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const clearSessions = useCallback(() => {
    setSessions([]);
    setSelectedSession(null);
  }, []);

  const selectSession = useCallback((session: SessionWithPatient | null) => {
    setSelectedSession(session);
  }, []);

  const fetchStitchedSessions = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all patients first
      await fetchPatients();

      if (!patients || patients.length === 0) {
        console.error("Failed to fetch patients");
        setSessions([]);
        return;
      }

      const stitchedSessions: SessionWithPatient[] = [];

      for (const patient of patients) {
        try {
          // Fetch videos for this patient
          await fetchVideosForPatient(patient.id);

          const patientVideos = videos.sort(
            (a, b) =>
              new Date(a.created_at).getTime() -
              new Date(b.created_at).getTime()
          );

          if (patientVideos.length === 0) continue;

          // Group videos into sessions (videos within 1 hour are considered same session)
          const sessions: Video[][] = [];
          let currentSession: Video[] = [patientVideos[0]];

          for (let i = 1; i < patientVideos.length; i++) {
            const currentVideo = patientVideos[i];
            const lastVideo = currentSession[currentSession.length - 1];

            const timeDiff =
              new Date(currentVideo.created_at).getTime() -
              new Date(lastVideo.created_at).getTime();

            if (timeDiff <= 60 * 60 * 1000) {
              // 1 hour in milliseconds
              currentSession.push(currentVideo);
            } else {
              sessions.push(currentSession);
              currentSession = [currentVideo];
            }
          }
          sessions.push(currentSession);

          // Create SessionWithPatient objects
          for (const sessionVideos of sessions) {
            const allDetections: Detection[] = [];

            // Fetch events for all videos in this session
            for (const video of sessionVideos) {
              await fetchEventsForVideo(video.id);
              const videoDetections = events.map(mapEventToDetection);
              allDetections.push(...videoDetections);
            }

            const startTime = new Date(sessionVideos[0].created_at);
            const endTime = new Date(
              sessionVideos[sessionVideos.length - 1].created_at
            );

            stitchedSessions.push({
              patient,
              videos: sessionVideos,
              detections: allDetections,
              startTime,
              endTime,
            });
          }
        } catch (err) {
          console.error(`Error processing patient ${patient.id}:`, err);
        }
      }

      setSessions(stitchedSessions);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch sessions";
      setError(message);
      console.error("Error fetching stitched sessions:", err);
    } finally {
      setLoading(false);
    }
  }, [
    patients,
    videos,
    events,
    fetchPatients,
    fetchVideosForPatient,
    fetchEventsForVideo,
  ]);

  return {
    sessions,
    selectedSession,
    loading,
    error,
    fetchStitchedSessions,
    selectSession,
    clearError,
    clearSessions,
  };
}
