import type { ApiResponse, HttpMethod } from "@/types";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000";

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

    const res = await fetch(url, {
      method,
      headers,
      credentials: "include",
      body:
        body instanceof FormData
          ? body
          : body
          ? JSON.stringify(body)
          : undefined,
      ...options,
    });

    // Handle 401 Unauthorized - attempt token refresh
    if (res.status === 401 && accessToken) {
      try {
        const refreshed = await refreshAccessToken();
        if (refreshed) {
          // Update headers with new token
          const newToken = localStorage.getItem("access_token");
          if (newToken) {
            headers.set("Authorization", `Bearer ${newToken}`);
          }

          // Retry the original request with new token
          const retryRes = await fetch(url, {
            method,
            headers,
            credentials: "include",
            body:
              body instanceof FormData
                ? body
                : body
                ? JSON.stringify(body)
                : undefined,
            ...options,
          });

          if (retryRes.ok) {
            const retryData = await retryRes.json();
            return {
              data: retryData as T,
              error: null,
              status: retryRes.status,
            };
          }
        }
      } catch {
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
      return { data: null, error: err.message, status: err.status };
    }

    const errorMessage = err instanceof Error ? err.message : "Network error";
    console.error("API request failed:", errorMessage);
    return { data: null, error: errorMessage };
  }
}

async function refreshAccessToken(): Promise<boolean> {
  try {
    const res = await fetch(`${BASE_URL}/auth/refresh`, {
      method: "POST",
      credentials: "include",
    });

    if (!res.ok) return false;

    const data = await res.json();
    localStorage.setItem("access_token", data.access_token);
    if (data.refresh_token) {
      localStorage.setItem("refresh_token", data.refresh_token);
    }
    return true;
  } catch {
    return false;
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
          credentials: "include",
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
