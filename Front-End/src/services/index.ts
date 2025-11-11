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

export { realtimeService } from "./realtimeService";
export type {
  RealtimeConnection,
  RealtimeEvent,
  RealtimeEventHandler,
  RealtimeOptions,
  RealtimeService,
} from "./realtimeService";

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

export { hlsService } from "./hlsService";
export type { HLSRecordingInfo, HLSRecordingStatus } from "./hlsService";

export { noteService } from "./noteService";
export type { Note, NoteCreateRequest, NoteUpdateRequest } from "./noteService";

// Movement detection service for Parkinson's involuntary movements
export type {
  CreateMovementDetection,
  MovementDetection,
  MovementDetectionRealtimeEvent,
  MovementDetectionStats,
  MovementType,
  UpdateMovementDetection,
  UpdateValidationStatus,
  ValidationStatus,
} from "@/types/movementDetection";
export { movementDetectionService } from "./movementDetectionService";

// Live streaming services for real-time video sessions
// Ambulance streaming service (new)
export type {
  AmbulanceCamera,
  AmbulanceSession,
  AmbulanceSessionCreate,
  AmbulanceSessionUpdate,
  AmbulanceStreamingStatus,
  CameraRoom,
  CameraRoomCreate,
  SDPData,
  StreamResponse,
} from "@/types";
export {
  ambulanceStreamingService,
  streamingService,
} from "./streamingService";

// Historical session review services for post-session analysis
export { fetchStitchedSessions } from "./sessionService";

// Re-export api and types for convenience
export type { ApiResponse } from "@/types";
export { api } from "./api";
