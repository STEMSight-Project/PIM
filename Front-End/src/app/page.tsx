"use client";

import { AuthLayout } from "@/components/layouts/AuthLayout";
import { LoginForm } from "@/features/auth/LoginForm";

export default function HomePage() {
  return (
    <AuthLayout title="Welcome to STEMSight PIM">
      <div className="space-y-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900">STEMSight PIM</h1>
          <p className="mt-2 text-gray-600">
            Posture and Movement Analysis Platform
          </p>
        </div>

        <div className="bg-white shadow-sm rounded-lg border">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">Sign In</h2>
          </div>
          <div className="px-6 py-6">
            <LoginForm />
          </div>
        </div>
      </div>
    </AuthLayout>
  );
}
