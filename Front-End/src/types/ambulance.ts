/**
 * Ambulance Streaming Types
 *
 * Type definitions for the ambulance-based streaming system.
 * Updated September 2025 to match backend ambulance_streaming.py API.
 */

// ============================================================================
// AMBULANCE TYPES
// ============================================================================

export interface Ambulance {
  id: string;
  ambulance_number: string;
  license_plate: string;
  vehicle_model: string;
  manufacturer: string;
  year_manufactured: number;
  status: "active" | "inactive" | "maintenance";
  current_location?: string;
  assigned_hospital_id?: string;
  assigned_team?: string;
  equipment_list?: string[];
  camera_count: number;
  max_camera_capacity: number;
  mileage?: number;
  last_maintenance?: string;
  next_maintenance?: string;
  insurance_info?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface AmbulanceCamera {
  id: string;
  camera_id: string;
  ambulance_id: string;
  camera_name?: string;
  camera_type?: string;
  position_in_ambulance?: string;
  device_model?: string;
  resolution?: string;
  max_fps?: number;
  has_night_vision: boolean;
  has_audio: boolean;
  mac_address?: string;
  ip_address?: string;
  streaming_port?: number;
  rtc_config?: object;
  status: "active" | "inactive" | "error";
  last_seen?: string;
  connection_quality?: number;
  ai_enabled: boolean;
  detection_types?: string[];
  processing_mode?: string;
  installation_date?: string;
  warranty_expires?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// SESSION TYPES
// ============================================================================

export interface AmbulanceSession {
  id: string;
  ambulance_id: string;
  session_name?: string;
  session_type: "emergency" | "routine" | "training" | "maintenance";
  incident_id?: string;
  priority_level: number;
  is_active: boolean;
  started_at: string;
  ended_at?: string;
  created_at: string;
  updated_at: string;
  camera_rooms?: CameraRoom[];
}

export interface AmbulanceSessionCreate {
  ambulance_id: string;
  session_name?: string;
  session_type?: "emergency" | "routine" | "training" | "maintenance";
  incident_id?: string;
  priority_level?: number;
}

export interface AmbulanceSessionUpdate {
  session_name?: string;
  session_type?: "emergency" | "routine" | "training" | "maintenance";
  incident_id?: string;
  priority_level?: number;
  is_active?: boolean;
}

// ============================================================================
// CAMERA ROOM TYPES
// ============================================================================

export interface CameraRoom {
  id: string;
  session_id: string;
  camera_id: string;
  room_id: string;
  camera_name: string;
  connected: boolean;
  connection_started_at: string;
  connection_ended_at?: string;
  last_seen?: string;
  current_fps?: number;
  current_bitrate?: number;
  packet_loss_rate?: number;
  latency_ms?: number;
  ai_processing_active: boolean;
  detections_count: number;
  last_detection_at?: string;
  created_at: string;
  updated_at: string;
}

export interface CameraRoomCreate {
  camera_id: string;
  room_id?: string;
  device_name?: string;
}

export interface CameraRoomUpdate {
  connected?: boolean;
  ended_at?: string;
}

// ============================================================================
// STREAMING TYPES
// ============================================================================

export interface SDPData {
  sdp: string;
  type: "offer" | "answer" | "pranswer" | "rollback";
}

export interface StreamResponse {
  sdp: string;
  type: "offer" | "answer" | "pranswer" | "rollback";
}

// ============================================================================
// DASHBOARD TYPES
// ============================================================================

export interface AmbulanceStreamingStatus {
  ambulance_id: string;
  ambulance_number: string;
  status: string;
  session_id: string;
  session_type: string;
  session_started: string;
  is_active: boolean;
  total_camera_rooms: number;
  connected_camera_rooms: number;
  camera_rooms: CameraRoom[];
}

// ============================================================================
// REAL-TIME EVENT TYPES
// ============================================================================

export interface AmbulanceSessionEvent {
  name: string;
  event_type: "UPDATE" | "DELETE" | "INSERT";
  session: AmbulanceSession;
  timestamp: string;
}

export interface CameraRoomEvent {
  name: string;
  event_type: "UPDATE" | "DELETE" | "INSERT";
  room: CameraRoom;
  timestamp: string;
}
