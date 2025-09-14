"use client";

import React from "react";
import { cn } from "@/utils/cn";
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";

type AlertVariant = "success" | "error" | "warning" | "info";

interface AlertProps {
  variant: AlertVariant;
  children: React.ReactNode;
  className?: string;
  onClose?: () => void;
}

const alertConfig = {
  success: {
    icon: CheckCircleIcon,
    className: "bg-green-50 border-green-200 text-green-800",
  },
  error: {
    icon: XCircleIcon,
    className: "bg-red-50 border-red-200 text-red-800",
  },
  warning: {
    icon: ExclamationTriangleIcon,
    className: "bg-yellow-50 border-yellow-200 text-yellow-800",
  },
  info: {
    icon: InformationCircleIcon,
    className: "bg-blue-50 border-blue-200 text-blue-800",
  },
};

export function Alert({ variant, children, className, onClose }: AlertProps) {
  const config = alertConfig[variant];
  const Icon = config.icon;

  return (
    <div
      className={cn(
        "flex items-start space-x-3 rounded-md border p-4",
        config.className,
        className
      )}
    >
      <Icon className="h-5 w-5 flex-shrink-0 mt-0.5" />
      <div className="flex-1">{children}</div>
      {onClose && (
        <button
          onClick={onClose}
          className="flex-shrink-0 ml-2 text-current hover:opacity-70"
        >
          <XCircleIcon className="h-5 w-5" />
        </button>
      )}
    </div>
  );
}
