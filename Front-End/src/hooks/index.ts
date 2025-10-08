// Re-export all hooks for easy importing
export { useAmbulanceStreaming } from "./useAmbulanceStreaming";
export { AuthProvider, useAuth } from "./useAuth";
export { useIsClient, useLocalStorage } from "./useClientSide";
export { Specialization, useDoctors } from "./useDoctors";
export { useMedicalHistory } from "./useMedicalHistory";
export { useNotes } from "./useNotes";
export { usePasswordReset } from "./usePasswordReset";
export { usePatientEvents } from "./usePatientEvents";
export { usePatients } from "./usePatients";
export { useRealtimeAmbulanceSessions } from "./useRealtime";
export type { UseRealtimeAmbulanceOptions } from "./useRealtime";
export { useSessions } from "./useSessions";
export { useStreaming } from "./useStreaming";
export { useVideos } from "./useVideos";

// Re-export types
export type {
  Detection,
  SessionWithPatient,
} from "@/components/session-review/types";
export type { AmbulanceWithSession } from "./useAmbulanceStreaming";
export type { Note } from "./useNotes";
export type { PatientEvent } from "./usePatientEvents";
export type { Video } from "./useVideos";
