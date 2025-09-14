"use client";

import { useState } from "react";
import Link from "next/link";
import { Button, Input, Alert } from "@/components/ui";
import { usePasswordReset } from "@/hooks";
import { ArrowLeftIcon } from "@heroicons/react/24/outline";

export function ForgotPasswordForm() {
  const [email, setEmail] = useState("");
  const {
    requestPasswordReset,
    isLoading,
    error,
    success,
    clearError,
    clearSuccess,
  } = usePasswordReset();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();
    clearSuccess();

    if (!email.trim()) {
      return;
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return;
    }

    await requestPasswordReset(email);
  };

  if (success) {
    return (
      <div className="space-y-6">
        <Alert variant="success">{success}</Alert>
        <div className="text-center">
          <Link
            href="/"
            className="inline-flex items-center text-sm text-blue-600 hover:text-blue-500"
          >
            <ArrowLeftIcon className="h-4 w-4 mr-2" />
            Back to Sign In
          </Link>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="text-center mb-6">
        <h2 className="text-lg font-medium text-gray-900">
          Reset your password
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Enter your email address and we'll send you a link to reset your
          password.
        </p>
      </div>

      <Input
        label="Email Address"
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="doctor@stemsight.com"
        required
        autoComplete="email"
      />

      {error && <Alert variant="error">{error}</Alert>}

      <Button type="submit" isLoading={isLoading} fullWidth size="lg">
        {isLoading ? "Sending..." : "Send Reset Link"}
      </Button>

      <div className="text-center">
        <Link
          href="/"
          className="inline-flex items-center text-sm text-blue-600 hover:text-blue-500"
        >
          <ArrowLeftIcon className="h-4 w-4 mr-2" />
          Back to Sign In
        </Link>
      </div>
    </form>
  );
}
