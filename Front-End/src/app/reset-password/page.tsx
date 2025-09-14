"use client";

import { AuthLayout } from "@/components/layouts/AuthLayout";
import { PasswordResetForm } from "@/features/auth/PasswordResetForm";
import Link from "next/link";

export default function ResetPasswordPage() {
  return (
    <AuthLayout
      title="Set New Password"
      subtitle="Enter your new password below"
    >
      <PasswordResetForm />

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
