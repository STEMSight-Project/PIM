// types/movementDetection.ts
/**
 * Movement Detection Types
 * Types for Parkinson's involuntary movement detection system
 */

/**
 * Validation status for detected movements
 */
export type ValidationStatus = "pending" | "confirmed" | "rejected";

/**
 * Parkinson's movement types (10 classes)
 */
export type MovementType =
  | "ballistic"
  | "chorea"
  | "decerebrate"
  | "decorticate"
  | "dystonia"
  | "fencer_posture"
  | "myoclonus"
  | "normal"
  | "tremor"
  | "versive_head";

/**
 * Movement detection record from database
 */
export interface MovementDetection {
  id: number;
  timestamp: number;
  name: MovementType;
  confidence: number;
  validation_status: ValidationStatus;
  room_id: string;
  recording_id: string;
  created_at: string;
  updated_at: string;
}

/**
 * Data for creating a new movement detection
 */
export interface CreateMovementDetection {
  timestamp: number;
  name: MovementType;
  confidence: number;
  validation_status: ValidationStatus;
  room_id: string;
  recording_id: string;
}

/**
 * Data for updating an existing movement detection
 */
export interface UpdateMovementDetection {
  timestamp?: number;
  name?: MovementType;
  confidence?: number;
  validation_status?: ValidationStatus;
  room_id?: string;
  recording_id?: string;
}

/**
 * Data for updating validation status only
 */
export interface UpdateValidationStatus {
  validation_status: ValidationStatus;
}

/**
 * Statistics for movement detections
 */
export interface MovementDetectionStats {
  total_detections: number;
  by_movement_type: Record<MovementType, number>;
  by_validation_status: Record<ValidationStatus, number>;
  average_confidence: number;
  detection_timeline: Array<{
    hour: string;
    count: number;
  }>;
}

/**
 * Filters for querying movement detections
 */
export interface MovementDetectionFilters {
  room_id?: string;
  recording_id?: string;
  validation_status?: ValidationStatus;
  movement_type?: MovementType;
  min_confidence?: number;
  limit?: number;
  offset?: number;
}

/**
 * Real-time event from SSE stream
 */
export interface MovementDetectionRealtimeEvent {
  type: "connected" | "database_change" | "heartbeat" | "error";
  table?: string;
  channel?: string;
  event?: "INSERT" | "UPDATE" | "DELETE";
  new?: MovementDetection;
  old?: MovementDetection;
  id?: number;
  timestamp?: number;
  error?: string;
}

/**
 * Service response wrapper
 */
export interface MovementDetectionResponse<T> {
  success: boolean;
  data: T | null;
  error: string | null;
}
