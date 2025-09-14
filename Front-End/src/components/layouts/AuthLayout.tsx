"use client";

import Image from "next/image";
import { cn } from "@/utils/cn";

interface AuthLayoutProps {
  children: React.ReactNode;
  title?: string;
  subtitle?: string;
  className?: string;
}

export function AuthLayout({
  children,
  title,
  subtitle,
  className,
}: AuthLayoutProps) {
  return (
    <div className={cn("min-h-screen flex", className)}>
      {/* Left side - Branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-blue-800 items-center justify-center p-12">
        <div className="text-center text-white">
          <div className="mb-8">
            <Image
              src="/STEMSight-Logo.png"
              alt="STEMSight"
              width={120}
              height={120}
              className="mx-auto"
            />
          </div>
          <h1 className="text-4xl font-bold mb-4">STEMSight PIM</h1>
          <p className="text-xl text-blue-100">
            Advanced Patient Information Management System
          </p>
          <div className="mt-8 text-blue-200">
            <p className="text-sm">
              Streamlining healthcare data management with cutting-edge
              technology
            </p>
          </div>
        </div>
      </div>

      {/* Right side - Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8 bg-gray-50">
        <div className="w-full max-w-md">
          <div className="bg-white rounded-xl shadow-lg p-8">
            {/* Mobile logo */}
            <div className="lg:hidden text-center mb-8">
              <Image
                src="/STEMSight-Logo.png"
                alt="STEMSight"
                width={80}
                height={80}
                className="mx-auto mb-4"
              />
              <h2 className="text-xl font-bold text-gray-900">STEMSight PIM</h2>
            </div>

            {title && (
              <div className="text-center mb-8">
                <h2 className="text-2xl font-bold text-gray-900">{title}</h2>
                {subtitle && <p className="mt-2 text-gray-600">{subtitle}</p>}
              </div>
            )}
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}
