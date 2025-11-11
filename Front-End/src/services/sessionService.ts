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

export interface SessionGalleryItem {
  id: string;
  patientId: string;
  patientName: string;
  videoCount: number;
  lastSessionDate: string;
  duration: string;
}
// Helper function to map new Video service type to old Video hook type
function mapVideoToSessionVideo(video: any): SessionVideo {
  return {
    id: video.id,
    patient_id: video.patient_id,
    description: null, // New video service doesn't have description
    file_path: video.video_url || video.filename || "", // Map video_url to file_path
    public_video_url: video.public_video_url || "", // Use video_url as public_video_url
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
//  to make the loading time shorter
export async function fetchSessionsGalleryFast(): Promise<SessionGalleryItem[]> {
  console.log("🚀 Loading gallery (parallel mode)...");
  const startTime = Date.now();

  const patientsResponse = await patientService.getAll();
  if (!patientsResponse.data) {
    console.error("Failed to fetch patients", patientsResponse.error);
    return [];
  }

  // Run ALL video fetches in parallel instead of sequentially
  const galleryPromises = patientsResponse.data.map(async (patient) => {
    try {
      const videosResponse = await videoService.getByPatientId(patient.id);
      if (!videosResponse.data || videosResponse.data.length === 0) return null;

      const videos = videosResponse.data;
      const firstVideo = videos[0];
      const lastVideo = videos[videos.length - 1];
      
      // Calculate estimated duration
      const startTime = new Date(firstVideo.created_at);
      const endTime = videos.length > 1 
        ? new Date(lastVideo.created_at) 
        : new Date(startTime.getTime() + 15 * 60 * 1000);
      
      const durationMinutes = Math.round((endTime.getTime() - startTime.getTime()) / 60000);

      return {
        id: `session-${patient.id}`,
        patientId: patient.id,
        patientName: `${patient.first_name} ${patient.last_name}`,
        videoCount: videos.length,
        lastSessionDate: firstVideo.created_at,
        duration: `${durationMinutes}m`,
      };
    } catch (error) {
      console.warn(`Failed to fetch videos for patient ${patient.id}:`, error);
      return null;
    }
  });

  // Wait for ALL requests to complete at once
  const results = await Promise.all(galleryPromises);
  
  // Filter out nulls (patients with no videos or errors)
  const galleryItems = results.filter((item): item is SessionGalleryItem => item !== null);

  const loadTime = Date.now() - startTime;
  console.log(`✅ Gallery loaded in ${loadTime}ms (${galleryItems.length} sessions)`);
  
  return galleryItems;
}
//convert gallery item to session format 
export function galleryItemToSession(item: SessionGalleryItem): SessionWithPatient {
  // With this:
return {
  id: item.id,
  patient: {
    id: item.patientId,
    first_name: item.patientName.split(' ')[0],
    last_name: item.patientName.split(' ').slice(1).join(' '),
  } as any,
  startTime: new Date(item.lastSessionDate),
  endTime: new Date(new Date(item.lastSessionDate).getTime() + 15 * 60 * 1000),
  sessionDate: item.lastSessionDate.split("T")[0],
  stationId: `S-${Math.floor(Math.random() * 1000).toString().padStart(3, "0")}`,
  // Empty until session is selected
  videos: [],
  detections: [],

  videoCount: item.videoCount,
  duration: item.duration,
  patientName: item.patientName,
} as SessionWithPatient & { videoCount: number; duration: string; patientName: string };
}
// Load full session details once the card is clicked
export async function fetchFullSessionDetails(sessionId: string): Promise<SessionWithPatient | null> {
  console.log("🔄 Loading full session details...", sessionId);
  const startTime = Date.now();

  const patientId = sessionId.replace('session-', '');
  
  const patientsResponse = await patientService.getAll();
  if (!patientsResponse.data) return null;
  
  const patient = patientsResponse.data.find(p => p.id === patientId);
  if (!patient) return null;

  const videosResponse = await videoService.getByPatientId(patient.id);
  if (!videosResponse.data) return null;

  const videos = videosResponse.data.sort(
    (a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  );

  const mappedVideos: SessionVideo[] = videos.map(video => ({
    id: video.id,
    patient_id: video.patient_id,
    description: video.description || null,
    file_path: video.file_path || "",
    public_video_url: video.public_video_url || "",
    created_at: video.created_at,
  }));

  // Fetch all events
  const allDetections: Detection[] = [];
  for (const video of videos) {
    try {
      const eventsResponse = await api.get<any[]>(`/patient_event/video/${video.id}`);
      const events = eventsResponse.data || [];
      
      const detections = events.map((event: any): Detection => ({
        id: event.id,
        type: event.type,
        timestamp: event.timestamp,
        confidence: event.confidence,
        validation_status: event.validation_status,
        created_at: event.created_at,
        video_id: event.video_id,
      }));
      
      allDetections.push(...detections);
    } catch (error) {
      console.warn(`Failed to fetch events for video ${video.id}:`, error);
    }
  }

  const firstVideo = videos[0];
  const startDate = new Date(firstVideo.created_at);
  let endDate = new Date(startDate.getTime() + 15 * 60 * 1000);
  
  if (allDetections.length > 0) {
    const latestEventTimestamp = Math.max(...allDetections.map(d => Number(d.timestamp) || 0));
    if (latestEventTimestamp > 0) {
      endDate = new Date(startDate.getTime() + latestEventTimestamp * 1000);
    }
  }

  const stationId = `S-${Math.floor(Math.random() * 1000).toString().padStart(3, "0")}`;

  const fullSession: SessionWithPatient = {
    patient,
    videos: mappedVideos,
    detections: allDetections,
    startTime: startDate,
    endTime: endDate,
    id: sessionId,
    sessionDate: firstVideo.created_at.split("T")[0],
    stationId,
  };

  const loadTime = Date.now() - startTime;
  console.log(`Full session loaded in ${loadTime}ms (${allDetections.length} events)`);

  return fullSession;
}