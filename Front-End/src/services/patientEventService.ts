import { api } from "./api";

export interface PatientEvent {
  id: string;
  type: string;
  timestamp: string;
  confidence: number;
  validation_status: string;
  created_at: string;
  video_id: string;
}

// get all events for a specific patient id
export async function getEventsForPatient(
  patientId: string
): Promise<PatientEvent[]> {
  return await api.get<PatientEvent[]>(`/patient-events/patient/${patientId}`);
}

// get all events for a specific video id
export async function getEventsForVideo(
  videoId: string
): Promise<PatientEvent[]> {
  return await api.get<PatientEvent[]>(`/patient-events/video/${videoId}`);
}

// update the event's validation status (pending, confirmed, dismissed)
export async function updateEventStatus(
  eventId: string,
  status: "pending" | "confirmed" | "dismissed"
): Promise<PatientEvent> {
  return await api.post<PatientEvent>(`/patient-events/${eventId}/status`, {
    validation_status: status,
  });
}
