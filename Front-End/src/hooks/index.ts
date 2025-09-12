// Re-export all hooks for easy importing
export { useAuth, AuthProvider } from "./useAuth";
export { usePasswordReset } from "./usePasswordReset";
export { usePatients } from "./usePatients";
export { useDoctors, Specialization } from "./useDoctors";
export { useMedicalHistory } from "./useMedicalHistory";
export { useNotes } from "./useNotes";
export { useStreaming } from "./useStreaming";
export { useVideos } from "./useVideos";
export { usePatientEvents } from "./usePatientEvents";
export { useSessions } from "./useSessions";

// Re-export types
export type { Video } from "./useVideos";
export type { PatientEvent } from "./usePatientEvents";
export type { SessionWithPatient, Detection } from "./useSessions";
export type { Note } from "./useNotes";
