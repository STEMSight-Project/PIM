"use client";

import { useState } from "react";
import { Button, Input, Alert } from "@/components/ui";
import { usePasswordReset } from "@/hooks";
import { EyeIcon, EyeSlashIcon } from "@heroicons/react/24/outline";

export function PasswordResetForm() {
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const {
    resetPassword,
    isLoading,
    error,
    success,
    hasValidToken,
    clearError,
  } = usePasswordReset();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();
    await resetPassword(password, confirmPassword);
  };

  if (!hasValidToken) {
    return (
      <Alert variant="error">
        Invalid or missing reset token. Please check your reset link or request
        a new password reset email.
      </Alert>
    );
  }

  if (success) {
    return <Alert variant="success">{success}</Alert>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="relative">
        <Input
          label="New Password"
          type={showPassword ? "text" : "password"}
          autoComplete="new-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Enter your new password"
          helperText="Password must be at least 8 characters with uppercase, lowercase, number, and special character"
          required
        />
        <button
          type="button"
          className="absolute right-3 top-8 text-gray-400 hover:text-gray-600"
          onClick={() => setShowPassword(!showPassword)}
        >
          {showPassword ? (
            <EyeSlashIcon className="h-5 w-5" />
          ) : (
            <EyeIcon className="h-5 w-5" />
          )}
        </button>
      </div>

      <div className="relative">
        <Input
          label="Confirm Password"
          type={showConfirmPassword ? "text" : "password"}
          autoComplete="new-password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          placeholder="Confirm your new password"
          required
        />
        <button
          type="button"
          className="absolute right-3 top-8 text-gray-400 hover:text-gray-600"
          onClick={() => setShowConfirmPassword(!showConfirmPassword)}
        >
          {showConfirmPassword ? (
            <EyeSlashIcon className="h-5 w-5" />
          ) : (
            <EyeIcon className="h-5 w-5" />
          )}
        </button>
      </div>

      {error && <Alert variant="error">{error}</Alert>}

      <Button type="submit" isLoading={isLoading} fullWidth size="lg">
        {isLoading ? "Resetting Password..." : "Reset Password"}
      </Button>
    </form>
  );
}
