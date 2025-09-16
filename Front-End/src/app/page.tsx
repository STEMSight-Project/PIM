"use client";

import { AuthLayout } from "@/components/layouts/AuthLayout";
import { ClientOnly } from "@/components/ui";
import { LoginForm } from "@/features/auth/LoginForm";

export default function HomePage() {
  return (
    <AuthLayout title="Welcome to STEMSight PIM">
      <div className="space-y-6">
        <div className="bg-white shadow-sm rounded-lg border">
          <div className="px-6 py-6">
            <ClientOnly
              fallback={
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                </div>
              }
            >
              <LoginForm />
            </ClientOnly>
          </div>
        </div>
      </div>
    </AuthLayout>
  );
}
