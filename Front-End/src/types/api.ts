// API Response Types
export interface ApiResponse<T> {
  data: T | null;
  error: string | null;
  status?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

export interface ErrorResponse {
  detail: string;
  code?: string;
  field?: string;
}

// Streaming Types
export interface StreamingRoom {
  id: string;
  patient_id: string;
  room_id: string;
  session_id: string;
  device_name: string;
  connected: boolean;
  started_at: string;
  ended_at?: string;
  last_seen: string;
  created_at: string;
  updated_at: string;
}

// Updated StreamingSession to match actual database structure
export interface StreamingSession {
  id: string;
  patient_id: string;
  status: "active" | "ended" | "error" | "disconnected";
  started_at: string;
  ended_at?: string;
  created_at: string;
  updated_at: string;
}

export interface StreamingSessionCreate {
  patient_id: string;
}

export interface StreamingSessionUpdate {
  status?: "active" | "ended" | "error" | "disconnected";
}

export interface VideoAnalysis {
  id: string;
  session_id: string;
  timestamp: number;
  detection_type: "myoclonus" | "tremor" | "decerebrate" | "decorticate";
  confidence: number;
  metadata?: Record<string, any>;
}

// Form Types
export interface FormErrors {
  [key: string]: string | undefined;
}

export interface FormState<T> {
  values: T;
  errors: FormErrors;
  isSubmitting: boolean;
  isDirty: boolean;
}

// UI Component Types
export type ButtonVariant =
  | "primary"
  | "secondary"
  | "outline"
  | "ghost"
  | "destructive";
export type ButtonSize = "sm" | "md" | "lg";
export type AlertVariant = "success" | "error" | "warning" | "info";
export type ModalSize = "sm" | "md" | "lg" | "xl";

// HTTP Methods
export type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
