"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { useAuth } from "@/hooks/useAuth";
import {
  ChartBarIcon,
  CheckCircleIcon,
  ClockIcon,
  Cog6ToothIcon,
  CpuChipIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  EyeIcon,
  PlayIcon,
  SignalIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function DashboardPage() {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push("/");
    }
  }, [isAuthenticated, isLoading, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  const stats = [
    {
      label: "Active Cameras",
      value: "8",
      color: "bg-blue-500",
      icon: VideoCameraIcon,
      trend: "+2 from yesterday",
      status: "online",
    },
    {
      label: "Live Streams",
      value: "3",
      color: "bg-green-500",
      icon: PlayIcon,
      trend: "Currently streaming",
      status: "active",
    },
    {
      label: "Detection Events",
      value: "156",
      color: "bg-purple-500",
      icon: ChartBarIcon,
      trend: "+23 today",
      status: "normal",
    },
    {
      label: "Model Accuracy",
      value: "94.2%",
      color: "bg-orange-500",
      icon: CpuChipIcon,
      trend: "+1.2% improved",
      status: "excellent",
    },
  ];

  const quickActions = [
    {
      title: "View Live Camera Feeds",
      description: "Monitor real-time video streams from all active cameras",
      icon: VideoCameraIcon,
      color: "bg-blue-500",
      onClick: () => router.push("/streamingDash"),
    },
    {
      title: "Recent Live Session",
      description: "View analytics and data from recent camera sessions",
      icon: DocumentTextIcon,
      color: "bg-green-500",
      onClick: () => router.push("/recent-live-session"),
    },
    {
      title: "Detection Event History",
      description: "Browse historical AI detection events and analysis",
      icon: ChartBarIcon,
      color: "bg-purple-500",
      onClick: () => router.push("/patients"),
    },
    {
      title: "Camera Device Status",
      description: "Check health and configuration of all camera devices",
      icon: Cog6ToothIcon,
      color: "bg-orange-500",
      onClick: () => console.log("Camera device status clicked"),
    },
  ];

  const recentDetections = [
    {
      id: 1,
      camera: "RPi-1",
      event: "Pose Detection Event",
      confidence: 93,
      time: new Date(Date.now() - 5 * 60 * 1000),
      status: "normal",
    },
    {
      id: 2,
      camera: "RPi-2",
      event: "Movement Pattern Alert",
      confidence: 95,
      time: new Date(Date.now() - 12 * 60 * 1000),
      status: "alert",
    },
    {
      id: 3,
      camera: "RPi-3",
      event: "Posture Classification",
      confidence: 94,
      time: new Date(Date.now() - 18 * 60 * 1000),
      status: "normal",
    },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Header Section */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              AI Monitoring Dashboard
            </h1>
            <p className="text-gray-600 mt-1">
              Camera AI system status and real-time detection monitoring
            </p>
          </div>
          <div className="flex space-x-3">
            <Button
              variant="outline"
              onClick={() => router.push("/streamingDash")}
              className="flex items-center space-x-2"
            >
              <EyeIcon className="w-4 h-4" />
              <span>View Live Cameras</span>
            </Button>
            <Button
              onClick={() => router.push("/recent-live-session")}
              className="flex items-center space-x-2"
            >
              <ChartBarIcon className="w-4 h-4" />
              <span>Session Analytics</span>
            </Button>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => {
            const IconComponent = stat.icon;
            return (
              <Card
                key={index}
                className="p-6 hover:shadow-lg transition-shadow cursor-pointer"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className={`p-3 rounded-lg ${stat.color}`}>
                      <IconComponent className="w-6 h-6 text-white" />
                    </div>
                    <div className="ml-4">
                      <p className="text-sm font-medium text-gray-600">
                        {stat.label}
                      </p>
                      <p className="text-2xl font-bold text-gray-900">
                        {stat.value}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">{stat.trend}</p>
                    </div>
                  </div>
                  <div className="flex items-center">
                    {stat.status === "online" && (
                      <div className="flex items-center text-green-600">
                        <div className="w-2 h-2 bg-green-600 rounded-full mr-1 animate-pulse"></div>
                        <span className="text-xs font-medium">Online</span>
                      </div>
                    )}
                    {stat.status === "active" && (
                      <div className="flex items-center text-blue-600">
                        <SignalIcon className="w-4 h-4 mr-1" />
                        <span className="text-xs font-medium">Active</span>
                      </div>
                    )}
                    {stat.status === "normal" && (
                      <CheckCircleIcon className="w-5 h-5 text-green-600" />
                    )}
                    {stat.status === "excellent" && (
                      <div className="flex items-center text-green-600">
                        <CheckCircleIcon className="w-4 h-4 mr-1" />
                        <span className="text-xs font-medium">Excellent</span>
                      </div>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Recent AI Detections */}
          <div className="lg:col-span-2">
            <Card className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-semibold text-gray-900">
                  Recent AI Detections
                </h3>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => router.push("/patients")}
                  className="flex items-center space-x-1"
                >
                  <DocumentTextIcon className="w-4 h-4" />
                  <span>View All</span>
                </Button>
              </div>
              <div className="space-y-4">
                {recentDetections.map((detection) => (
                  <div
                    key={detection.id}
                    className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer"
                    onClick={() =>
                      console.log(`Detection ${detection.id} clicked`)
                    }
                  >
                    <div className="flex items-center space-x-4">
                      <div
                        className={`p-2 rounded-lg ${
                          detection.status === "alert"
                            ? "bg-yellow-500"
                            : "bg-green-500"
                        }`}
                      >
                        {detection.status === "alert" ? (
                          <ExclamationTriangleIcon className="w-5 h-5 text-white" />
                        ) : (
                          <CpuChipIcon className="w-5 h-5 text-white" />
                        )}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">
                          Camera {detection.camera}
                        </p>
                        <p className="text-sm text-gray-600">
                          {detection.event}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="flex items-center space-x-2">
                        <span
                          className={`px-2 py-1 rounded-full text-xs font-medium ${
                            detection.confidence >= 95
                              ? "bg-green-100 text-green-800"
                              : detection.confidence >= 90
                              ? "bg-yellow-100 text-yellow-800"
                              : "bg-red-100 text-red-800"
                          }`}
                        >
                          {detection.confidence}%
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mt-1 flex items-center">
                        <ClockIcon className="w-3 h-3 mr-1" />
                        {detection.time.toLocaleTimeString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Quick Actions */}
          <div>
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-6">
                Quick Actions
              </h3>
              <div className="space-y-4">
                {quickActions.map((action, index) => {
                  const IconComponent = action.icon;
                  return (
                    <Button
                      key={index}
                      variant="outline"
                      className="w-full justify-start h-auto p-4 hover:shadow-md transition-all"
                      onClick={action.onClick}
                    >
                      <div className="flex items-start space-x-3 text-left">
                        <div
                          className={`p-2 rounded-lg ${action.color} flex-shrink-0`}
                        >
                          <IconComponent className="w-5 h-5 text-white" />
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">
                            {action.title}
                          </p>
                          <p className="text-sm text-gray-600 mt-1">
                            {action.description}
                          </p>
                        </div>
                      </div>
                    </Button>
                  );
                })}
              </div>
            </Card>
          </div>
        </div>

        {/* System Status Banner */}
        <Card className="p-4 bg-green-50 border-green-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <CheckCircleIcon className="w-6 h-6 text-green-600" />
              <div>
                <p className="font-medium text-green-900">
                  System Status: All Systems Operational
                </p>
                <p className="text-sm text-green-700">
                  All cameras online • AI models running • Data pipeline healthy
                </p>
              </div>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => console.log("System status details clicked")}
              className="border-green-300 text-green-700 hover:bg-green-100"
            >
              View Details
            </Button>
          </div>
        </Card>
      </div>
    </DashboardLayout>
  );
}
