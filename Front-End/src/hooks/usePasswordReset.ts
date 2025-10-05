"use client";

import { authService } from "@/services/authService";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export function usePasswordReset() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Extract token from URL query parameters on component mount
    if (typeof window !== "undefined") {
      const urlParams = new URLSearchParams(window.location.search);
      const resetToken = urlParams.get("token");

      if (resetToken) {
        setToken(resetToken);
        // Keep token in URL for now - user might refresh page
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
      const resetData = { token, new_password: password };
      const response = await authService.confirmPasswordReset(resetData);

      if (response.error) {
        throw new Error(response.error);
      }

      setSuccess("Password successfully reset! Redirecting to login...");

      // Clear the token from URL
      if (typeof window !== "undefined") {
        window.history.replaceState(null, "", window.location.pathname);
      }

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
      const { error } = await authService.requestPasswordReset(email);

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
