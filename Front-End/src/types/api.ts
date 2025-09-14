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
  name: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface StreamingSession {
  id: string;
  room_id: string;
  viewer_count: number;
  started_at: string;
  ended_at?: string;
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
