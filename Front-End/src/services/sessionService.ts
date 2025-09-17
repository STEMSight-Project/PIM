/**
 * SESSION SERVICE
 *
 * Handles historical session data aggregation for post-session analysis:
 * - Stitches together videos, events, and detections into session views
 * - Provides session review and analysis capabilities
 * - Aggregates data from multiple sources for comprehensive session insights
 *
 * Use this service for:
 * - Session review pages
 * - Historical data analysis
 * - Post-session reporting
 * - Patient progress tracking over time
 *
 * Note: This is separate from streamingService which handles live streaming.
 */

// services/sessionService.ts

import { api } from "./api";
import { patientService } from "./patientService";
import { videoService } from "./videoService";

import {
  Detection,
  SessionWithPatient,
} from "@/components/session-review/types";
import { Video as SessionVideo } from "@/hooks/useVideos"; // Import the expected Video type

// Helper function to map new Video service type to old Video hook type
function mapVideoToSessionVideo(video: any): SessionVideo {
  return {
    id: video.id,
    patient_id: video.patient_id,
    description: null, // New video service doesn't have description
    file_path: video.video_url || video.filename || "", // Map video_url to file_path
    public_video_url: video.video_url || "", // Use video_url as public_video_url
    created_at: video.created_at,
  };
}

// Helper function to map PatientEvent to Detection
function mapEventToDetection(event: any): Detection {
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

export async function fetchStitchedSessions(): Promise<SessionWithPatient[]> {
  const sessions: SessionWithPatient[] = [];

  const patientsResponse = await patientService.getAll();
  if (!patientsResponse.data) {
    console.error("Failed to fetch patients", patientsResponse.error);
    return [];
  }

  for (const patient of patientsResponse.data) {
    const videosResponse = await videoService.getByPatientId(patient.id);
    if (!videosResponse.data) continue;

    const videos = videosResponse.data.sort(
      (a, b) =>
        new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    if (videos.length === 0) continue;

    // Map to the expected Video type for session review
    const mappedVideos = videos.map(mapVideoToSessionVideo);

    const allDetections: Detection[] = [];
    let latestEventTimestamp = 0;

    for (const video of videos) {
      // Get events for this video using direct API call
      const eventsResponse = await api.get<any[]>(
        `/patient_event/video/${video.id}`
      );
      const events = eventsResponse.data || [];
      const detections = events.map(mapEventToDetection) || [];
      allDetections.push(...detections);

      const maxEvent = Math.max(
        ...(events.map((e) => Number(e.timestamp)) || [0])
      );

      latestEventTimestamp = Math.max(latestEventTimestamp, maxEvent);
    }

    const firstVideo = videos[0];
    const lastVideo = videos[videos.length - 1];

    const startDate = new Date(firstVideo.created_at);
    let endDate = new Date(startDate.getTime() + 15 * 60 * 1000);

    if (latestEventTimestamp > 0) {
      endDate = new Date(startDate.getTime() + latestEventTimestamp * 1000);
    } else {
      const fallbackEnd = new Date(lastVideo.created_at);
      endDate = new Date(fallbackEnd.getTime() + 15 * 60 * 1000);
    }

    const stationId = `S-${Math.floor(Math.random() * 1000)
      .toString()
      .padStart(3, "0")}`;

    // Return in the format expected by the component
    sessions.push({
      patient,
      videos: mappedVideos,
      detections: allDetections,
      startTime: startDate,
      endTime: endDate,
      id: `session-${patient.id}`,
      sessionDate: firstVideo.created_at.split("T")[0],
      stationId,
    });
  }

  return sessions;
}
