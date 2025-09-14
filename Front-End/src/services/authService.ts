import type { ApiResponse } from "@/types";
import { api } from "./api";

// Auth Types
export interface User {
  id: string;
  email: string;
  first_name?: string;
  last_name?: string;
  role?: string;
  aud?: string;
  created_at?: string;
  updated_at?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  role?: string;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  user: User;
}

export interface PasswordResetRequest {
  email: string;
}

export interface PasswordConfirmRequest {
  token: string;
  new_password: string;
}

// Auth Service Functions
export const authService = {
  // Authentication
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    return api.post<LoginResponse>("/auth/login", credentials);
  },

  async register(
    userData: RegisterRequest
  ): Promise<ApiResponse<LoginResponse>> {
    return api.post<LoginResponse>("/auth/register", userData);
  },

  async logout(): Promise<ApiResponse<void>> {
    // Clear all stored tokens and user data
    this.clearTokens();

    // Optionally notify the server about logout
    try {
      await api.post<void>("/auth/logout");
    } catch (error) {
      // Even if server logout fails, we've cleared local data
      console.warn("Server logout failed, but local data cleared:", error);
    }

    return { data: null, error: null };
  },

  async getCurrentUser(): Promise<ApiResponse<User>> {
    return api.get<User>("/auth/me");
  },

  async refreshToken(
    refreshToken: string
  ): Promise<ApiResponse<LoginResponse>> {
    return api.post<LoginResponse>("/auth/refresh", {
      refresh_token: refreshToken,
    });
  },

  // Password Management
  async requestPasswordReset(
    email: string
  ): Promise<ApiResponse<{ message: string }>> {
    return api.post<{ message: string }>("/auth/request-password-reset", {
      email,
    });
  },

  async confirmPasswordReset(
    data: PasswordConfirmRequest
  ): Promise<ApiResponse<{ message: string }>> {
    return api.post<{ message: string }>("/auth/confirm-password-reset", data);
  },

  // Utility Functions
  isAuthenticated(): boolean {
    return !!localStorage.getItem("access_token");
  },

  getStoredToken(): string | null {
    return localStorage.getItem("access_token");
  },

  clearTokens(): void {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
  },
};
