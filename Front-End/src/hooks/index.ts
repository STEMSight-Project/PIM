// Re-export all hooks for easy importing
export { AuthProvider, useAuth } from "./useAuth";
export { useIsClient, useLocalStorage } from "./useClientSide";
export { Specialization, useDoctors } from "./useDoctors";
export { useMedicalHistory } from "./useMedicalHistory";
export { useNotes } from "./useNotes";
export { usePasswordReset } from "./usePasswordReset";
export { usePatientEvents } from "./usePatientEvents";
export { usePatients } from "./usePatients";
export { useSessions } from "./useSessions";
export { useStreaming } from "./useStreaming";
export { useVideos } from "./useVideos";

// Re-export types
export type { Note } from "./useNotes";
export type { PatientEvent } from "./usePatientEvents";
export type { Detection, SessionWithPatient } from "./useSessions";
export type { Video } from "./useVideos";
