"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { usePaginatedSessions } from "@/hooks/usePaginatedSessions";
import {
  ambulanceSessionService,
} from "@/services/ambulanceSessionService";
import { formatDate } from "@/utils/cn";
import {
  ArrowPathIcon,
  CalendarIcon,
  ChartBarIcon,
  ClockIcon,
  EyeIcon,
  PlayIcon,
  ServerIcon,
  StopIcon,
  TruckIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useRef, useMemo } from "react";

export default function RecentLiveSessionPage() {
  const router = useRouter();
  const observerTarget = useRef<HTMLDivElement>(null);

  // Use the pagination hook
  const {
    sessions,
    isLoading,
    isLoadingMore,
    error,
    hasMore,
    total,
    loadMore,
    refresh,
  } = usePaginatedSessions({ pageSize: 20 });

  // Infinite scroll observer
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !isLoadingMore && !isLoading) {
          loadMore();
        }
      },
      { threshold: 0.1 }
    );

    const currentTarget = observerTarget.current;
    if (currentTarget) {
      observer.observe(currentTarget);
    }

    return () => {
      if (currentTarget) {
        observer.unobserve(currentTarget);
      }
    };
  }, [hasMore, isLoadingMore, isLoading, loadMore]);

  const getStatusColor = (status: string) => {
    return status === "completed"
      ? "bg-blue-100 text-blue-800"
      : "bg-green-100 text-green-800";
  };

  const getStatusIcon = (isActive: boolean) => {
    return isActive ? (
      <PlayIcon className="h-4 w-4" />
    ) : (
      <StopIcon className="h-4 w-4" />
    );
  };

  const getStatusLabel = (status: string) => {
    return status === "completed" ? "Completed" : "Active";
  };

  // Calculate statistics
  const stats = useMemo(() => ({
    total: sessions.length,
    active: sessions.filter((s) => s.is_active).length,
    completed: sessions.filter((s) => !s.is_active && s.ended_at).length,
    totalSessions: total,
  }), [sessions, total]);

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading recent sessions..." />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Recent Recording Sessions
            </h1>
            <p className="text-gray-600">
              View recent camera recording sessions from all ambulances
            </p>
          </div>
          <div className="flex space-x-3">
            <Button
              variant="outline"
              onClick={refresh}
              disabled={isLoading}
            >
              <ArrowPathIcon
                className={`h-4 w-4 mr-2 ${isLoading ? "animate-spin" : ""}`}
              />
              Refresh
            </Button>
            <Button variant="outline">
              <ChartBarIcon className="h-4 w-4 mr-2" />
              Export Report
            </Button>
          </div>
        </div>

        {error && <Alert variant="error">{error}</Alert>}

        {/* Session Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <TruckIcon className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Total Sessions
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {stats.total}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <PlayIcon className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Active Sessions
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {stats.active}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <StopIcon className="h-6 w-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Completed</p>
                <p className="text-2xl font-bold text-gray-900">
                  {stats.completed}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Sessions List */}
        <Card className="overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">
              Recording Sessions ({sessions.length})
            </h3>
          </div>

          {sessions.length === 0 ? (
            <div className="text-center py-12">
              <TruckIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No sessions found
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                No recent recording sessions available.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-200">
              {sessions.map((session) => {
                // Calculate duration
                const startTime = new Date(session.started_at);
                const endTime = session.ended_at ? new Date(session.ended_at) : new Date();
                const durationMs = endTime.getTime() - startTime.getTime();
                const duration = `${Math.floor(durationMs / 60000)} min`;
                const isActive = session.is_active;
                const status = isActive ? "active" : "completed";

                return (
                  <div
                    key={session.id}
                    className="p-6 hover:bg-gray-50 transition-colors cursor-pointer"
                    onClick={() => router.push(`/sessions/${session.id}`)}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4 flex-1">
                        <div className="flex-shrink-0">
                          <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
                            <VideoCameraIcon className="h-6 w-6 text-blue-600" />
                          </div>
                        </div>

                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2 flex-wrap">
                            <p className="text-sm font-medium text-gray-900">
                              {session.session_name || `Session ${session.id.slice(0, 8)}...`}
                            </p>
                            <span
                              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                                status
                              )}`}
                            >
                              {getStatusIcon(isActive)}
                              <span className="ml-1">
                                {getStatusLabel(status)}
                              </span>
                            </span>
                          </div>

                          <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500 flex-wrap">
                            <div className="flex items-center">
                              <CalendarIcon className="h-4 w-4 mr-1" />
                              {formatDate(session.started_at)}
                            </div>
                            <div className="flex items-center">
                              <ClockIcon className="h-4 w-4 mr-1" />
                              {duration}
                            </div>
                            <div className="flex items-center">
                              <TruckIcon className="h-4 w-4 mr-1" />
                              {session.ambulance_id}
                            </div>
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center space-x-4 ml-4">
                        <div className="flex flex-col space-y-2">
                          {isActive && (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation();
                                router.push(
                                  `/streamingDash?ambulance=${session.ambulance_id}`
                                );
                              }}
                            >
                              <PlayIcon className="h-4 w-4 mr-1" />
                              Watch Live
                            </Button>
                          )}
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push(
                                `/recent-live-session/subject/${session.id}`
                              );
                            }}
                          >
                            <VideoCameraIcon className="h-4 w-4 mr-1" />
                            View Subject
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push(`/sessions/${session.id}`);
                            }}
                          >
                            <EyeIcon className="h-4 w-4 mr-1" />
                            View Details
                          </Button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* Infinite scroll trigger */}
          {!isLoading && hasMore && (
            <div ref={observerTarget} className="py-8 text-center">
              {isLoadingMore ? (
                <Loading size="sm" text="Loading more sessions..." />
              ) : (
                <div className="text-sm text-gray-500">Scroll for more</div>
              )}
            </div>
          )}

          {/* End of list indicator */}
          {!isLoading && !hasMore && sessions.length > 0 && (
            <div className="py-6 text-center text-sm text-gray-500 border-t border-gray-200">
              No more sessions to load
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
}
