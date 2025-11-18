"use client";

import { Button, ClientOnly } from "@/components/ui";
import { useAuth } from "@/hooks/useAuth";
import { cn } from "@/utils/cn";
import {
  ArrowRightOnRectangleIcon,
  Bars3Icon,
  ChevronDoubleLeftIcon,
  ChevronDoubleRightIcon,
  DocumentTextIcon,
  HomeIcon,
  PlayIcon,
  UserGroupIcon,
  UserIcon,
  VideoCameraIcon,
  XMarkIcon,
} from "@heroicons/react/24/outline";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import {
  CustomCamera,
  CustomDash,
  CustomPatient,
  CustomRecent,
  CustomReplay,
} from "../ui/CustomIcons";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: CustomDash },
  // { name: "Patients", href: "/patients", icon: CustomPatient }, // Temporarily hidden
  { name: "Live Cameras", href: "/streamingDash", icon: CustomCamera },
  {
    name: "Recent Live Session",
    href: "/recent-live-session",
    icon: CustomRecent,
  },
  { name: "Video Playback", href: "/video-playback", icon: CustomReplay },
];

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const pathname = usePathname();
  const router = useRouter();
  const { logout, user } = useAuth();
  // Derive display name/email from authenticated user to display in sidebar
  const firstName =
    (user as any)?.first_name ?? (user as any)?.user_metadata?.first_name ?? "";
  const lastName =
    (user as any)?.last_name ?? (user as any)?.user_metadata?.last_name ?? "";
  const hasName = Boolean(firstName || lastName);
  const displayName = hasName
    ? `Dr. ${[firstName, lastName].filter(Boolean).join(" ")}`
    : user?.email
    ? `Dr. ${user.email.split("@")[0]}`
    : "Doctor";
  const displayEmail = user?.email ?? "";

  // Load collapsed state from localStorage
  useEffect(() => {
    const saved = localStorage.getItem("sidebarCollapsed");
    if (saved !== null) {
      setSidebarCollapsed(JSON.parse(saved));
    }
  }, []);

  // Save collapsed state to localStorage
  const toggleSidebarCollapsed = () => {
    const newState = !sidebarCollapsed;
    setSidebarCollapsed(newState);
    localStorage.setItem("sidebarCollapsed", JSON.stringify(newState));
  };

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error("Logout error:", error);
      // Force redirect even if logout fails
      router.push("/");
    }
  };

  return (
    <div className="h-screen flex bg-transparent">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        >
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm" />
        </div>
      )}

      {/* Modern Sidebar */}
      <div
        className={cn(
          "fixed inset-y-0 left-0 z-50 bg-white/95 backdrop-blur-lg shadow-2xl border-r border-slate-200 transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0",
          sidebarOpen ? "translate-x-0" : "-translate-x-full",
          sidebarCollapsed ? "lg:w-20" : "lg:w-72"
        )}
        style={{
          width:
            sidebarOpen || !sidebarCollapsed
              ? sidebarCollapsed
                ? "5rem"
                : "18rem"
              : "5rem",
        }}
      >
        {/* Collapsed state indicator */}
        {sidebarCollapsed && (
          <div className="hidden lg:block absolute top-1/2 -right-2 w-4 h-8 bg-blue-600 rounded-r-lg shadow-lg transform -translate-y-1/2 opacity-60">
            <div className="flex items-center justify-center h-full">
              <ChevronDoubleRightIcon className="h-3 w-3 text-white" />
            </div>
          </div>
        )}

        <div className="flex flex-col h-full">
          {/* Header Section */}
          <div className="flex items-center justify-between p-4 border-b border-slate-200 bg-gradient-to-r from-blue-600 to-blue-700">
            <div
              className={cn(
                "flex items-center space-x-3 overflow-hidden transition-all duration-300",
                sidebarCollapsed && "lg:space-x-0 lg:justify-center"
              )}
            >
              {(!sidebarCollapsed || sidebarOpen) && (
                <div className="flex-shrink-0 w-10 h-10 bg-white rounded-xl shadow-lg flex items-center justify-center">
                  <Image
                    src="/STEMSight-Logo.png"
                    alt="STEMSight"
                    width={24}
                    height={24}
                    className="object-contain"
                  />
                </div>
              )}

              {(!sidebarCollapsed || sidebarOpen) && (
                <div className="transition-opacity duration-300">
                  <h1 className="text-lg font-bold text-white">STEMSight</h1>
                  <p className="text-xs text-blue-100">PIM System</p>
                </div>
              )}
            </div>

            {/* Enhanced desktop collapse toggle - only control point */}
            <div className="flex items-center space-x-2">
              <button
                onClick={toggleSidebarCollapsed}
                className="hidden lg:flex items-center justify-center w-9 h-9 rounded-xl bg-white/20 hover:bg-white/30 text-white transition-all duration-200 hover:scale-105 active:scale-95"
                title={sidebarCollapsed ? "Expand sidebar" : "Collapse sidebar"}
              >
                {sidebarCollapsed ? (
                  <ChevronDoubleRightIcon className="h-5 w-5" />
                ) : (
                  <ChevronDoubleLeftIcon className="h-5 w-5" />
                )}
              </button>

              {/* Mobile close button */}
              <button
                onClick={() => setSidebarOpen(false)}
                className="lg:hidden flex items-center justify-center w-9 h-9 rounded-xl bg-white/20 hover:bg-white/30 text-white transition-all duration-200 hover:scale-105 active:scale-95"
              >
                <XMarkIcon className="h-5 w-5" />
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-2 overflow-hidden">
            {navigation.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    "group flex items-center space-x-3 px-3 py-3 rounded-xl text-sm font-medium transition-all duration-200 relative overflow-hidden",
                    isActive
                      ? "bg-blue-600 text-white shadow-lg shadow-blue-600/30 scale-105"
                      : "text-slate-700 hover:bg-slate-100 hover:text-slate-900 hover:scale-102",
                    sidebarCollapsed &&
                      "lg:justify-center lg:space-x-0 lg:w-12 lg:h-12 lg:mx-auto lg:p-0"
                  )}
                  onClick={() => setSidebarOpen(false)}
                  title={sidebarCollapsed ? item.name : undefined}
                >
                  <div
                    className={cn(
                      "flex-shrink-0 w-6 h-6 flex items-center justify-center",
                      isActive && "text-white",
                      sidebarCollapsed && "lg:w-5 lg:h-5"
                    )}
                  >
                    <item.icon className="h-5 w-5" />
                  </div>
                  {(!sidebarCollapsed || sidebarOpen) && (
                    <span className="transition-opacity duration-300 whitespace-nowrap">
                      {item.name}
                    </span>
                  )}
                  {isActive && !sidebarCollapsed && (
                    <div className="absolute inset-y-0 left-0 w-1 bg-white rounded-r-full" />
                  )}
                  {isActive && sidebarCollapsed && (
                    <div className="absolute -right-1 top-1/2 w-2 h-2 bg-blue-600 rounded-full transform -translate-y-1/2" />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* User Profile Section */}
          <div className="border-t border-slate-200 p-4 bg-slate-50">
            <div
              className={cn(
                "flex items-center space-x-3 mb-4",
                sidebarCollapsed && "lg:justify-center lg:space-x-0 lg:mb-2"
              )}
            >
              <div className="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl shadow-lg flex items-center justify-center">
                <UserIcon className="h-5 w-5 text-white" />
              </div>
              {(!sidebarCollapsed || sidebarOpen) && (
                <div className="flex-1 min-w-0 transition-opacity duration-300">
                  <p className="text-sm font-semibold text-slate-900 truncate">
                    {displayName}
                  </p>
                  <p className="text-xs text-slate-500 truncate">
                    {displayEmail}
                  </p>
                </div>
              )}
            </div>

            {sidebarCollapsed ? (
              <div className="hidden lg:flex justify-center">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleLogout}
                  className="w-10 h-10 p-0 border-slate-300 text-slate-700 hover:bg-red-50 hover:border-red-300 hover:text-red-700 transition-all duration-200"
                  title="Sign Out"
                >
                  <ArrowRightOnRectangleIcon className="h-4 w-4" />
                </Button>
              </div>
            ) : (
              <Button
                variant="outline"
                size="sm"
                onClick={handleLogout}
                className="w-full transition-all duration-300 border-slate-300 text-slate-700 hover:bg-red-50 hover:border-red-300 hover:text-red-700"
              >
                <ArrowRightOnRectangleIcon className="h-4 w-4 mr-2" />
                <span className="transition-opacity duration-300">
                  Sign Out
                </span>
              </Button>
            )}

            {/* Mobile logout button when sidebar is open */}
            {sidebarOpen && (
              <Button
                variant="outline"
                size="sm"
                onClick={handleLogout}
                className="w-full lg:hidden transition-all duration-300 border-slate-300 text-slate-700 hover:bg-red-50 hover:border-red-300 hover:text-red-700"
              >
                <ArrowRightOnRectangleIcon className="h-4 w-4 mr-2" />
                Sign Out
              </Button>
            )}
          </div>
        </div>
      </div>

      {/* Main content area */}
      <div className="flex-1 flex flex-col overflow-hidden transition-all duration-300 ease-in-out">
        {/* Top navigation bar */}
        <header className="bg-white/80 backdrop-blur-lg shadow-sm border-b border-slate-200 px-6 py-4 transition-all duration-300">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              {/* Mobile menu button only */}
              <button
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden p-2 rounded-xl hover:bg-slate-100 transition-colors duration-200"
              >
                <Bars3Icon className="h-5 w-5 text-slate-700" />
              </button>

              <div>
                <h1 className="text-xl font-semibold text-slate-900">
                  Camera AI Monitoring System
                </h1>
                <p className="text-sm text-slate-500">
                  Real-time posture and movement analysis
                </p>
              </div>
            </div>

            <div className="hidden lg:flex items-center space-x-4">
              <ClientOnly
                fallback={
                  <div className="text-right">
                    <p className="text-sm font-medium text-slate-900">
                      Loading...
                    </p>
                    <p className="text-xs text-slate-500">--:--</p>
                  </div>
                }
              >
                <div className="text-right">
                  <p className="text-sm font-medium text-slate-900">
                    {new Date().toLocaleDateString("en-US", {
                      weekday: "short",
                      month: "short",
                      day: "numeric",
                    })}
                  </p>
                  <p className="text-xs text-slate-500">
                    {new Date().toLocaleTimeString("en-US", {
                      hour: "numeric",
                      minute: "2-digit",
                    })}
                  </p>
                </div>
              </ClientOnly>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto p-6 bg-transparent">
          {children}
        </main>
      </div>
    </div>
  );
}
