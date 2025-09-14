// Export all service modules for easy importing
export { authService } from "./authService";
export type {
  LoginRequest,
  LoginResponse,
  PasswordConfirmRequest,
  PasswordResetRequest,
  RegisterRequest,
  User,
} from "./authService";

export { patientService } from "./patientService";
export type {
  Patient,
  PatientCreateRequest,
  PatientUpdateRequest,
} from "./patientService";

export { doctorService } from "./doctorService";
export type {
  Doctor,
  DoctorCreateRequest,
  DoctorUpdateRequest,
} from "./doctorService";

export { medicalHistoryService } from "./medicalHistoryService";
export type {
  MedicalHistory,
  MedicalHistoryCreateRequest,
  MedicalHistoryUpdateRequest,
} from "./medicalHistoryService";

export { videoService } from "./videoService";
export type {
  Video,
  VideoCreateRequest,
  VideoUpdateRequest,
  VideoUploadResponse,
} from "./videoService";

export { noteService } from "./noteService";
export type { Note, NoteCreateRequest, NoteUpdateRequest } from "./noteService";

export { streamingService } from "./streamingService";
export type {
  RoomInfo,
  SDPData,
  StreamCreateRequest,
  StreamResponse,
  StreamSession,
  StreamStats,
  StreamUpdateRequest,
} from "./streamingService";

// Re-export api and types for convenience
export type { ApiResponse } from "@/types";
export { api } from "./api";
