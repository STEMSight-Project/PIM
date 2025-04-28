// services/sessionService.ts

import { getAllPatients } from "./patientService";
import { getVideosForPatient } from "./videoService";
import { getEventsForVideo } from "./patientEventService";

import {
  formatDateTime,
  mapEventToDetection,
} from "@/components/session-review/utils";
import {
  Detection,
  SessionWithPatient,
} from "@/components/session-review/types";

export async function fetchStitchedSessions(): Promise<SessionWithPatient[]> {
  const sessions: SessionWithPatient[] = [];

  const patients = await getAllPatients();
  if (!patients) {
    console.error("Failed to fetch patients", patients);
    return [];
  }

  for (const patient of patients) {
    const videos = (await getVideosForPatient(patient.id)).sort(
      (a, b) =>
        new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    if (videos.length === 0) continue;

    const allDetections: Detection[] = [];
    let latestEventTimestamp = 0;

    for (const video of videos) {
      const events = await getEventsForVideo(video.id);
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

    const { date, time: startTime } = formatDateTime(firstVideo.created_at);
    const endTime = endDate.toLocaleTimeString("en-US", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: true,
    });

    const stationId = `S-${Math.floor(Math.random() * 1000)
      .toString()
      .padStart(3, "0")}`;

    sessions.push({
      session: {
        id: `session-${patient.id}`,
        patientId: patient.id,
        sessionDate: date,
        startTime,
        endTime,
        stationId,
        videos,
      },
      patient,
      detections: allDetections,
    });
  }

  return sessions;
}
