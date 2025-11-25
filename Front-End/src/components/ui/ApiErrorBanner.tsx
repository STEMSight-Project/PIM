"use client";

import { useApiErrors } from "@/contexts/ApiErrorContext";
import {
  XMarkIcon,
  ArrowPathIcon,
  ExclamationTriangleIcon,
} from "@heroicons/react/24/outline";
import { useState } from "react";

export function ApiErrorBanner() {
  const { hasTimeoutError, hasNetworkError, clearErrors, errors } =
    useApiErrors();
  const [dismissed, setDismissed] = useState(false);

  const showBanner = (hasTimeoutError || hasNetworkError) && !dismissed;

  console.log("🎨 Banner render:", {
    hasTimeoutError,
    hasNetworkError,
    dismissed,
    showBanner,
    errorCount: errors?.length,
  });

  if (!showBanner) return null;

  const handleRefresh = () => {
    clearErrors();
    window.location.reload();
  };

  const handleDismiss = () => {
    setDismissed(true);
    clearErrors();
  };

  return (
    <div className="fixed top-0 left-0 right-0 z-[9999] animate-slide-down">
      <div className="bg-gradient-to-r from-red-500 to-orange-500 text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3 flex-1">
              <ExclamationTriangleIcon className="h-6 w-6 flex-shrink-0 animate-pulse" />
              <div className="flex-1">
                <p className="font-semibold text-sm sm:text-base">
                  {hasTimeoutError
                    ? "Connection Issue Detected"
                    : "Network Error"}
                </p>
                <p className="text-xs sm:text-sm opacity-90 mt-0.5">
                  {hasTimeoutError
                    ? "Multiple requests are timing out. Please refresh the page to restore connection."
                    : "Unable to reach the server. Check your internet connection."}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2 ml-4">
              <button
                onClick={handleRefresh}
                className="flex items-center gap-2 px-4 py-2 bg-white text-red-600 rounded-lg hover:bg-gray-100 transition-colors font-medium text-sm shadow-md hover:shadow-lg"
              >
                <ArrowPathIcon className="h-4 w-4" />
                <span className="hidden sm:inline">Refresh Page</span>
                <span className="sm:hidden">Refresh</span>
              </button>

              <button
                onClick={handleDismiss}
                className="p-2 hover:bg-white/20 rounded-lg transition-colors"
                aria-label="Dismiss"
              >
                <XMarkIcon className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
