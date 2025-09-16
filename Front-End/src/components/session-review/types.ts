import { Video } from "@/hooks";

export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: "male" | "female" | "other";
  email?: string;
  phone?: string;
  address?: string;
  emergency_contact?: string;
  created_at: string;
  updated_at: string;
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
  id: string;
  type: string;
  timestamp: string;
  confidence: number;
  validation_status: string;
  created_at: string;
  video_id: string;
  color?: string;
}

// Updated to match what the component expects
export interface SessionWithPatient {
  patient: Patient;
  videos: Video[];
  detections: Detection[];
  startTime: Date;
  endTime: Date;
  // Additional session properties that might be used
  id?: string;
  sessionDate?: string;
  stationId?: string;
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
