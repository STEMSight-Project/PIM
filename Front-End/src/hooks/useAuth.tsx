"use client";

import { api } from "@/services/api";
import type { AuthState, LoginRequest, LoginResponse, User } from "@/types";
import { useRouter } from "next/navigation";
import {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useState,
} from "react";
import { useIsClient } from "./useClientSide";

interface AuthContextType extends AuthState {
  login: (
    credentials: LoginRequest
  ) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

interface AuthProviderProps {
  children: ReactNode;
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const isClient = useIsClient();
  const router = useRouter();

  const login = async (credentials: LoginRequest) => {
    try {
      setIsLoading(true);
      const { data, error } = await api.post<LoginResponse>(
        "/auth/login",
        credentials
      );

      if (error || !data) {
        return { success: false, error: error || "Login failed" };
      }

      if (typeof window !== "undefined") {
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
      }
      setUser(data.user);

      return { success: true };
    } catch (err) {
      return {
        success: false,
        error: err instanceof Error ? err.message : "Login failed",
      };
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      setIsLoading(true);
      await api.post("/auth/logout");
    } catch (err) {
      console.error("Logout error:", err);
    } finally {
      if (typeof window !== "undefined") {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
      }
      setUser(null);
      setIsLoading(false);
      router.push("/");
    }
  };

  const refreshUser = async () => {
    try {
      const { data, error } = await api.get<User>("/auth/me");
      if (data && !error) {
        setUser(data);
      } else {
        setUser(null);
        if (typeof window !== "undefined") {
          localStorage.removeItem("access_token");
          localStorage.removeItem("refresh_token");
        }
      }
    } catch (err) {
      console.error("Failed to refresh user:", err);
      setUser(null);
      if (typeof window !== "undefined") {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
      }
    }
  };

  useEffect(() => {
    const initAuth = async () => {
      // Only run on client side
      if (typeof window !== "undefined" && isClient) {
        const token = localStorage.getItem("access_token");
        if (token) {
          await refreshUser();
        }
      }
      setIsLoading(false);
    };

    // Only initialize auth after we're on the client side
    if (isClient) {
      initAuth();
    }
  }, [isClient]);

  const value: AuthContextType = {
    user,
    isLoading,
    isAuthenticated: !!user,
    login,
    logout,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
