import { Video } from "@/services/videoService";
export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
}

export interface SessionData {
  id: string;
  stationId: string;
  patientId: string;
  sessionDate: string;
  startTime: string;
  endTime: string;
  videos: Video[];
}

export interface Detection {
  type: string;
  color: string;
}

export interface SessionWithPatient {
  session: SessionData;
  patient?: Patient;
  detections: Detection[];
}

export interface PatientEvent {
  id: string;
  type: string;
  timestamp: number;
  confidence: number;
  validation_status: string;
  created_at: string;
  video_id: string;
}
