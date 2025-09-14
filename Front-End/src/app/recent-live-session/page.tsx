"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { formatDate } from "@/utils/cn";
import {
  CalendarIcon,
  ChartBarIcon,
  ClockIcon,
  EyeIcon,
  PlayIcon,
  StopIcon,
  UserIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface LiveSession {
  id: string;
  patient_id: string;
  patient_name: string;
  start_time: string;
  end_time?: string;
  duration: string;
  status: "active" | "completed" | "interrupted";
  detections_count: number;
  alerts_count: number;
  confidence_avg: number;
  camera_device: string;
}

export default function RecentLiveSessionPage() {
  const router = useRouter();
  const [sessions, setSessions] = useState<LiveSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Simulate loading recent live sessions
    const loadSessions = async () => {
      try {
        setIsLoading(true);

        // Mock data - replace with actual API call
        const mockSessions: LiveSession[] = [
          {
            id: "session_001",
            patient_id: "patient_123",
            patient_name: "John Doe",
            start_time: "2025-09-14T14:30:00Z",
            end_time: "2025-09-14T15:15:00Z",
            duration: "45m",
            status: "completed",
            detections_count: 23,
            alerts_count: 3,
            confidence_avg: 94.2,
            camera_device: "RPi Camera Module 1",
          },
          {
            id: "session_002",
            patient_id: "patient_124",
            patient_name: "Jane Smith",
            start_time: "2025-09-14T13:00:00Z",
            end_time: "2025-09-14T13:30:00Z",
            duration: "30m",
            status: "completed",
            detections_count: 15,
            alerts_count: 1,
            confidence_avg: 96.8,
            camera_device: "RPi Camera Module 2",
          },
          {
            id: "session_003",
            patient_id: "patient_125",
            patient_name: "Bob Johnson",
            start_time: "2025-09-14T15:45:00Z",
            duration: "12m",
            status: "active",
            detections_count: 8,
            alerts_count: 0,
            confidence_avg: 92.1,
            camera_device: "RPi Camera Module 3",
          },
          {
            id: "session_004",
            patient_id: "patient_126",
            patient_name: "Alice Brown",
            start_time: "2025-09-14T11:20:00Z",
            end_time: "2025-09-14T12:05:00Z",
            duration: "45m",
            status: "interrupted",
            detections_count: 18,
            alerts_count: 2,
            confidence_avg: 89.3,
            camera_device: "RPi Camera Module 4",
          },
        ];

        await new Promise((resolve) => setTimeout(resolve, 1000)); // Simulate loading
        setSessions(mockSessions);
      } catch (err) {
        setError("Failed to load recent live sessions");
      } finally {
        setIsLoading(false);
      }
    };

    loadSessions();
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800";
      case "completed":
        return "bg-blue-100 text-blue-800";
      case "interrupted":
        return "bg-red-100 text-red-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "active":
        return <PlayIcon className="h-4 w-4" />;
      case "completed":
        return <StopIcon className="h-4 w-4" />;
      case "interrupted":
        return <StopIcon className="h-4 w-4" />;
      default:
        return <ClockIcon className="h-4 w-4" />;
    }
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading recent live sessions..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <div className="max-w-md mx-auto mt-12">
          <Alert variant="error">{error}</Alert>
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
              Recent Live Sessions
            </h1>
            <p className="text-gray-600">
              Camera AI monitoring sessions from all subjects
            </p>
          </div>
          <div className="flex space-x-3">
            <Button variant="outline">
              <ChartBarIcon className="h-4 w-4 mr-2" />
              Export Report
            </Button>
          </div>
        </div>

        {/* Session Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <VideoCameraIcon className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Total Sessions Today
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {sessions.length}
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
                  {sessions.filter((s) => s.status === "active").length}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <EyeIcon className="h-6 w-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Total Detections
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {sessions.reduce((acc, s) => acc + s.detections_count, 0)}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <ChartBarIcon className="h-6 w-6 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">
                  Avg Confidence
                </p>
                <p className="text-2xl font-bold text-gray-900">
                  {(
                    sessions.reduce((acc, s) => acc + s.confidence_avg, 0) /
                    sessions.length
                  ).toFixed(1)}
                  %
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Sessions List */}
        <Card className="overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">
              Recent Live Sessions
            </h3>
          </div>

          {sessions.length === 0 ? (
            <div className="text-center py-12">
              <VideoCameraIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No live sessions
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                No recent camera monitoring sessions found.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-200">
              {sessions.map((session) => (
                <div key={session.id} className="p-6 hover:bg-gray-50">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="flex-shrink-0">
                        <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
                          <VideoCameraIcon className="h-6 w-6 text-blue-600" />
                        </div>
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-center space-x-2">
                          <p className="text-sm font-medium text-gray-900 truncate">
                            {session.patient_name}
                          </p>
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                              session.status
                            )}`}
                          >
                            {getStatusIcon(session.status)}
                            <span className="ml-1 capitalize">
                              {session.status}
                            </span>
                          </span>
                        </div>

                        <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                          <div className="flex items-center">
                            <CalendarIcon className="h-4 w-4 mr-1" />
                            {formatDate(session.start_time)}
                          </div>
                          <div className="flex items-center">
                            <ClockIcon className="h-4 w-4 mr-1" />
                            {session.duration}
                          </div>
                          <div className="flex items-center">
                            <EyeIcon className="h-4 w-4 mr-1" />
                            {session.camera_device}
                          </div>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-6">
                      <div className="text-right">
                        <p className="text-sm font-medium text-gray-900">
                          {session.detections_count} detections
                        </p>
                        <p className="text-sm text-gray-500">
                          {session.alerts_count} alerts •{" "}
                          {session.confidence_avg}% confidence
                        </p>
                      </div>

                      <div className="flex space-x-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() =>
                            router.push(`/patients/${session.patient_id}`)
                          }
                        >
                          <UserIcon className="h-4 w-4 mr-1" />
                          View Subject
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => router.push(`/sessions/${session.id}`)}
                        >
                          <EyeIcon className="h-4 w-4 mr-1" />
                          View Details
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
}
