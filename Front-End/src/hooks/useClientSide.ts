"use client";

import { useEffect, useState } from "react";

/**
 * Hook to safely check if code is running on client side
 * Prevents hydration mismatches
 */
export function useIsClient() {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  return isClient;
}

/**
 * Hook to safely access localStorage
 * Returns null on server side to prevent hydration issues
 */
export function useLocalStorage(
  key: string
): [string | null, (value: string | null) => void] {
  const isClient = useIsClient();
  const [value, setValue] = useState<string | null>(null);

  useEffect(() => {
    if (isClient && typeof window !== "undefined") {
      const stored = localStorage.getItem(key);
      setValue(stored);
    }
  }, [key, isClient]);

  const setStoredValue = (newValue: string | null) => {
    if (typeof window !== "undefined") {
      if (newValue === null) {
        localStorage.removeItem(key);
      } else {
        localStorage.setItem(key, newValue);
      }
      setValue(newValue);
    }
  };

  return [isClient ? value : null, setStoredValue];
}
