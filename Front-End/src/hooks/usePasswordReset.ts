"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import type { PasswordResetRequest } from "@/types";
import { api } from "@/services/api";

export function usePasswordReset() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Extract token from URL hash on component mount
    if (typeof window !== "undefined") {
      const hash = window.location.hash.substring(1);
      const params = new URLSearchParams(hash);
      const accessToken = params.get("access_token");

      if (accessToken) {
        setToken(accessToken);
        // Remove token from URL for security
        window.history.replaceState(null, "", window.location.pathname);
      }
    }
  }, []);

  const resetPassword = async (password: string, confirmPassword: string) => {
    setIsLoading(true);
    setError(null);
    setSuccess(null);

    if (!token) {
      setError("Missing access token. Please check the reset link.");
      setIsLoading(false);
      return false;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      setIsLoading(false);
      return false;
    }

    if (password.length < 8) {
      setError("Password must be at least 8 characters long.");
      setIsLoading(false);
      return false;
    }

    // Basic password strength validation
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

    if (!hasUpperCase || !hasLowerCase || !hasNumbers || !hasSpecialChar) {
      setError(
        "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character."
      );
      setIsLoading(false);
      return false;
    }

    try {
      const resetData: PasswordResetRequest = { token, password };
      const { data, error } = await api.post("/auth/reset-password", resetData);

      if (error) {
        throw new Error(error);
      }

      setSuccess("Password successfully reset! Redirecting to login...");

      // Redirect after a delay
      setTimeout(() => {
        router.push("/");
      }, 3000);

      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error
          ? err.message
          : "Failed to reset password. Please try again.";
      setError(errorMessage);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const requestPasswordReset = async (email: string) => {
    setIsLoading(true);
    setError(null);
    setSuccess(null);

    try {
      const { error } = await api.post("/auth/forgot-password", { email });

      if (error) {
        throw new Error(error);
      }

      setSuccess("Password reset link has been sent to your email address.");
      return true;
    } catch (err) {
      const errorMessage =
        err instanceof Error
          ? err.message
          : "Failed to send reset email. Please try again.";
      setError(errorMessage);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    resetPassword,
    requestPasswordReset,
    isLoading,
    error,
    success,
    hasValidToken: !!token,
    clearError: () => setError(null),
    clearSuccess: () => setSuccess(null),
  };
}
