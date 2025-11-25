"use client";

import { setApiErrorCallback } from "@/services/api";
import { useApiErrors } from "@/contexts/ApiErrorContext";
import { useEffect } from "react";

export function ApiErrorInitializer() {
  const { addError } = useApiErrors();

  useEffect(() => {
    // Set up the global error callback
    setApiErrorCallback((error) => {
      addError(error);
    });

    return () => {
      // Clean up on unmount
      setApiErrorCallback(() => {});
    };
  }, [addError]);

  return null;
}
