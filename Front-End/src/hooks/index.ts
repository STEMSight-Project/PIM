// Re-export all hooks for easy importing
export { AuthProvider, useAuth } from "./useAuth";
export { useIsClient, useLocalStorage } from "./useClientSide";
export { Specialization, useDoctors } from "./useDoctors";
export { useMedicalHistory } from "./useMedicalHistory";
export { useNotes } from "./useNotes";
export { usePasswordReset } from "./usePasswordReset";
export { usePatientEvents } from "./usePatientEvents";
export { usePatients } from "./usePatients";
export {
  useRealtimePatient,
  useRealtimeRooms,
  useRealtimeSessions,
  useRealtimeStatus,
  useRealtimeTest,
} from "./useRealtime";
export type {
  UseRealtimePatientOptions,
  UseRealtimeRoomsOptions,
  UseRealtimeSessionsOptions,
} from "./useRealtime";
export { useSessions } from "./useSessions";
export { useStreaming } from "./useStreaming";
export { useStreamingSessions } from "./useStreamingSessions";
export { useVideos } from "./useVideos";

// Re-export types
export type {
  Detection,
  SessionWithPatient,
} from "@/components/session-review/types";
export type { Note } from "./useNotes";
export type { PatientEvent } from "./usePatientEvents";
export type {
  PatientWithSession,
  SessionWithRooms,
  StreamingRoom,
  UseStreamingSessionsReturn,
} from "./useStreamingSessions";
export type { Video } from "./useVideos";
