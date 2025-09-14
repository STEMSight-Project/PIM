"use client";

import { AuthLayout } from "@/components/layouts/AuthLayout";
import { ForgotPasswordForm } from "@/features/auth/ForgotPasswordForm";
import Link from "next/link";

export default function ForgotPasswordPage() {
  return (
    <AuthLayout
      title="Reset Password"
      subtitle="Enter your email to receive reset instructions"
    >
      <ForgotPasswordForm />

      <div className="mt-6 text-center">
        <Link
          href="/login"
          className="text-sm text-blue-600 hover:text-blue-500"
        >
          Back to sign in
        </Link>
      </div>
    </AuthLayout>
  );
}
