"use client";

import {
  createContext,
  useContext,
  useState,
  useCallback,
  ReactNode,
} from "react";

interface ApiError {
  message: string;
  endpoint: string;
  timestamp: number;
  status?: number;
}

interface ApiErrorContextType {
  errors: ApiError[];
  addError: (error: ApiError) => void;
  clearErrors: () => void;
  hasTimeoutError: boolean;
  hasNetworkError: boolean;
}

const ApiErrorContext = createContext<ApiErrorContextType | undefined>(
  undefined
);

const TIMEOUT_THRESHOLD = 2; // Show banner after 2 timeout/server errors
const ERROR_RETENTION_TIME = 30000; // Keep errors for 30 seconds

export function ApiErrorProvider({ children }: { children: ReactNode }) {
  const [errors, setErrors] = useState<ApiError[]>([]);

  const addError = useCallback((error: ApiError) => {
    console.log("🚨 API Error added:", error);
    setErrors((prev) => {
      const newErrors = [...prev, error];
      // Keep only errors from last 30 seconds
      const cutoff = Date.now() - ERROR_RETENTION_TIME;
      const filtered = newErrors.filter((e) => e.timestamp > cutoff);
      console.log(`📊 Total errors: ${filtered.length}`, filtered);
      return filtered;
    });
  }, []);

  const clearErrors = useCallback(() => {
    setErrors([]);
  }, []);

  // Check if we have significant timeout errors (408) or network errors (0)
  const recentTimeouts = errors.filter(
    (e) =>
      e.status === 408 ||
      e.status === 0 ||
      e.message.toLowerCase().includes("timeout")
  );
  const hasTimeoutError = recentTimeouts.length >= TIMEOUT_THRESHOLD;

  // Check for server errors (500+) or critical errors
  const serverErrors = errors.filter(
    (e) => (e.status && e.status >= 500) || e.status === 0
  );
  const hasNetworkError = serverErrors.length >= TIMEOUT_THRESHOLD;

  console.log("🔍 Error Check:", {
    totalErrors: errors.length,
    timeoutErrors: recentTimeouts.length,
    serverErrors: serverErrors.length,
    hasTimeoutError,
    hasNetworkError,
    threshold: TIMEOUT_THRESHOLD,
    recentTimeouts,
  });

  return (
    <ApiErrorContext.Provider
      value={{
        errors,
        addError,
        clearErrors,
        hasTimeoutError,
        hasNetworkError,
      }}
    >
      {children}
    </ApiErrorContext.Provider>
  );
}

export function useApiErrors() {
  const context = useContext(ApiErrorContext);
  if (!context) {
    throw new Error("useApiErrors must be used within ApiErrorProvider");
  }
  return context;
}
