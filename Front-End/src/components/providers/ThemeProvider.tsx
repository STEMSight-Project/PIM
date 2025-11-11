"use client";

import { useEffect } from "react";

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // Ensure light mode is set after hydration
    document.documentElement.classList.remove("dark");
    document.documentElement.classList.add("light");
    document.documentElement.style.colorScheme = "light";

    // Set localStorage to prevent theme switching
    try {
      localStorage.setItem("theme", "light");
    } catch {
      // Ignore localStorage errors
    }
  }, []);

  return <>{children}</>;
}
