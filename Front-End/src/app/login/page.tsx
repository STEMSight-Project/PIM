"use client";

import { AuthLayout } from "@/components/layouts/AuthLayout";
import { LoginForm } from "@/features/auth/LoginForm";
import Link from "next/link";

export default function LoginPage() {
  return (
    <AuthLayout
      title="Welcome Back"
      subtitle="Sign in to your STEMSight PIM account"
    >
      <LoginForm />

      <div className="mt-6 text-center">
        <Link
          href="/forgot-password"
          className="text-sm text-blue-600 hover:text-blue-500"
        >
          Forgot your password?
        </Link>
      </div>
    </AuthLayout>
  );
}
