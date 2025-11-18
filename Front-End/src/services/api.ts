import type { ApiResponse, HttpMethod } from "@/types";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000";
const DEFAULT_TIMEOUT = 10000; // 10 seconds
const REFRESH_IN_PROGRESS_KEY = "_token_refresh_in_progress";

// Global error callback for API errors
type ErrorCallback = (error: {
  message: string;
  endpoint: string;
  timestamp: number;
  status?: number;
}) => void;

let globalErrorCallback: ErrorCallback | null = null;

export function setApiErrorCallback(callback: ErrorCallback) {
  globalErrorCallback = callback;
}

// Rate limiting
const lastRequestTime = new Map<string, number>();
const MIN_REQUEST_INTERVAL = 50; // Minimum 50ms between requests to same endpoint

class ApiError extends Error {
  constructor(message: string, public status: number, public details?: any) {
    super(message);
    this.name = "ApiError";
  }
}

async function request<T>(
  endpoint: string,
  method: HttpMethod,
  body?: unknown,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  // Rate limiting - prevent rapid repeated requests
  const endpointKey = `${method}:${endpoint}`;
  const lastTime = lastRequestTime.get(endpointKey) || 0;
  const timeSinceLastRequest = Date.now() - lastTime;

  if (timeSinceLastRequest < MIN_REQUEST_INTERVAL) {
    const waitTime = MIN_REQUEST_INTERVAL - timeSinceLastRequest;
    console.log(
      `⏱️ Rate limiting ${method} ${endpoint} - waiting ${waitTime}ms`
    );
    await new Promise((resolve) => setTimeout(resolve, waitTime));
  }

  lastRequestTime.set(endpointKey, Date.now());

  // Create abort controller for timeout
  const controller = new AbortController();
  const timeout = options.signal
    ? undefined
    : setTimeout(() => controller.abort(), DEFAULT_TIMEOUT);

  try {
    const headers = new Headers(options.headers);
    headers.set("Accept", "application/json");

    if (body && !(body instanceof FormData)) {
      headers.set("Content-Type", "application/json");
    }

    const accessToken = localStorage.getItem("access_token");
    if (accessToken) {
      headers.set("Authorization", `Bearer ${accessToken}`);
    }

    const url = endpoint.startsWith("http")
      ? endpoint
      : `${BASE_URL}${endpoint.startsWith("/") ? "" : "/"}${endpoint}`;

    const fetchOptions: RequestInit = {
      method,
      headers,
      body:
        body instanceof FormData
          ? body
          : body
          ? JSON.stringify(body)
          : undefined,
      signal: options.signal || controller.signal,
      ...options,
    };

    const res = await fetch(url, fetchOptions);

    // Handle 401 Unauthorized - attempt token refresh (but prevent infinite loops)
    if (
      res.status === 401 &&
      accessToken &&
      !endpoint.includes("/auth/refresh")
    ) {
      try {
        const refreshed = await refreshAccessToken();
        if (refreshed) {
          // Update headers with new token
          const newToken = localStorage.getItem("access_token");
          if (newToken) {
            headers.set("Authorization", `Bearer ${newToken}`);
          }

          // Retry the original request with new token (only once)
          const retryRes = await fetch(url, {
            ...fetchOptions,
            headers,
          });

          if (retryRes.ok) {
            const retryData = await retryRes.json();
            return {
              data: retryData as T,
              error: null,
              status: retryRes.status,
            };
          }

          // If retry also fails, fall through to normal error handling
          const retryData = await retryRes.json().catch(() => null);
          const retryErrorMessage =
            retryData?.detail ||
            retryData?.message ||
            `${retryRes.status} ${retryRes.statusText}`;
          throw new ApiError(retryErrorMessage, retryRes.status, retryData);
        }
      } catch (refreshError) {
        // If refresh fails, clear tokens and redirect to login
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        if (typeof window !== "undefined") {
          window.location.href = "/";
        }
        return { data: null, error: "Session expired", status: 401 };
      }
    }

    let data: any = null;
    const contentType = res.headers.get("content-type");

    if (contentType && contentType.includes("application/json")) {
      data = await res.json();
    } else if (res.status !== 204) {
      // No content
      data = await res.text();
    }

    if (!res.ok) {
      const errorMessage =
        data?.detail || data?.message || `${res.status} ${res.statusText}`;
      throw new ApiError(errorMessage, res.status, data);
    }

    return { data: data as T, error: null, status: res.status };
  } catch (err) {
    if (err instanceof ApiError) {
      // Report error to global handler
      if (globalErrorCallback) {
        globalErrorCallback({
          message: err.message,
          endpoint,
          timestamp: Date.now(),
          status: err.status,
        });
      }
      return { data: null, error: err.message, status: err.status };
    }

    // Handle abort/timeout errors
    if (err instanceof Error && err.name === "AbortError") {
      console.error("API request timeout:", endpoint);
      // Report timeout to global handler
      if (globalErrorCallback) {
        console.log("📞 Calling global error callback for timeout");
        globalErrorCallback({
          message: "Request timeout",
          endpoint,
          timestamp: Date.now(),
          status: 408,
        });
      }
      return { data: null, error: "Request timeout", status: 408 };
    }

    const errorMessage = err instanceof Error ? err.message : "Network error";
    console.error("API request failed:", errorMessage, err);

    // Report network error to global handler
    if (globalErrorCallback) {
      globalErrorCallback({
        message: errorMessage,
        endpoint,
        timestamp: Date.now(),
        status: 0,
      });
    }

    return { data: null, error: errorMessage, status: 0 };
  } finally {
    // Clear timeout
    if (timeout) {
      clearTimeout(timeout);
    }
  }
}

async function refreshAccessToken(): Promise<boolean> {
  // Prevent multiple simultaneous refresh attempts
  if (sessionStorage.getItem(REFRESH_IN_PROGRESS_KEY) === "true") {
    // Wait a bit and return false to avoid race conditions
    await new Promise((resolve) => setTimeout(resolve, 100));
    return false;
  }

  try {
    sessionStorage.setItem(REFRESH_IN_PROGRESS_KEY, "true");

    const refreshToken = localStorage.getItem("refresh_token");
    if (!refreshToken) return false;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000); // 10s timeout for refresh

    try {
      const res = await fetch(`${BASE_URL}/auth/refresh`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refresh_token: refreshToken,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeout);

      if (!res.ok) return false;

      const data = await res.json();
      localStorage.setItem("access_token", data.access_token);
      if (data.refresh_token) {
        localStorage.setItem("refresh_token", data.refresh_token);
      }
      return true;
    } catch (err) {
      clearTimeout(timeout);
      console.error("Token refresh failed:", err);
      return false;
    }
  } finally {
    sessionStorage.removeItem(REFRESH_IN_PROGRESS_KEY);
  }
}

export const api = {
  get: <T>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, "GET", undefined, options),
  post: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    request<T>(endpoint, "POST", body, options),
  put: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    request<T>(endpoint, "PUT", body, options),
  patch: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    request<T>(endpoint, "PATCH", body, options),
  delete: <T>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, "DELETE", undefined, options),

  // Create requests with custom timeout
  withTimeout: (timeoutMs: number) => ({
    get: <T>(endpoint: string, options?: RequestInit) => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);
      return request<T>(endpoint, "GET", undefined, {
        ...options,
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));
    },
    post: <T>(endpoint: string, body?: unknown, options?: RequestInit) => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);
      return request<T>(endpoint, "POST", body, {
        ...options,
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));
    },
    put: <T>(endpoint: string, body?: unknown, options?: RequestInit) => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);
      return request<T>(endpoint, "PUT", body, {
        ...options,
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));
    },
    patch: <T>(endpoint: string, body?: unknown, options?: RequestInit) => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);
      return request<T>(endpoint, "PATCH", body, {
        ...options,
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));
    },
    delete: <T>(endpoint: string, options?: RequestInit) => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), timeoutMs);
      return request<T>(endpoint, "DELETE", undefined, {
        ...options,
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));
    },
  }),
};

// Helper functions for common API patterns
export const apiHelpers = {
  // Upload file
  uploadFile: async <T>(
    endpoint: string,
    file: File,
    additionalData?: Record<string, string>
  ) => {
    const formData = new FormData();
    formData.append("file", file);

    if (additionalData) {
      Object.entries(additionalData).forEach(([key, value]) => {
        formData.append(key, value);
      });
    }

    return api.post<T>(endpoint, formData);
  },

  // Download file
  downloadFile: async (endpoint: string, filename?: string) => {
    try {
      const response = await fetch(
        `${BASE_URL}${endpoint.startsWith("/") ? "" : "/"}${endpoint}`,
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("access_token")}`,
          },
        }
      );

      if (!response.ok) throw new Error("Download failed");

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = filename || "download";
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      return { success: true, error: null };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Download failed",
      };
    }
  },
};
