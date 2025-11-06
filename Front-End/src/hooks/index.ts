// ============================================================================
// STREAMING HOOKS
// ============================================================================
// - useStreaming: Live WebRTC viewer for camera feeds
// - useRealtimeAmbulanceSessions: Real-time SSE updates for sessions
// ============================================================================

export { useStreaming } from "./useStreaming";

// ============================================================================
// OTHER HOOKS
// ============================================================================

export { AuthProvider, useAuth } from "./useAuth";
export { useIsClient, useLocalStorage } from "./useClientSide";
export { Specialization, useDoctors } from "./useDoctors";
export { useMedicalHistory } from "./useMedicalHistory";
export { useMovementDetections } from "./useMovementDetections";
export type {
  UseMovementDetectionsOptions,
  UseMovementDetectionsReturn,
} from "./useMovementDetections";
export { useNotes } from "./useNotes";
export { usePasswordReset } from "./usePasswordReset";
export { usePatientEvents } from "./usePatientEvents";
export { usePatients } from "./usePatients";
export { useRealtimeAmbulanceSessions } from "./useRealtime";
export type { UseRealtimeAmbulanceOptions } from "./useRealtime";
export { useRecordings } from "./useRecordings";
export { useSessions } from "./useSessions";
export { useVideos } from "./useVideos";

// ============================================================================
// TYPES
// ============================================================================

// Re-export types
export type {
  Detection,
  SessionWithPatient,
} from "@/components/session-review/types";
export type {
  RecordingResponse,
  SessionWithRecordings,
} from "@/services/videoService";
export type { Note } from "./useNotes";
export type { PatientEvent } from "./usePatientEvents";
export type { Video } from "./useVideos";
