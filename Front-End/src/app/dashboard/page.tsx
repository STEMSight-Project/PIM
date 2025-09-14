"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { useAuth } from "@/hooks/useAuth";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function DashboardPage() {
  const { user, isAuthenticated, isLoading } = useAuth();
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
    { label: "Active Cameras", value: "8", color: "bg-blue-500" },
    { label: "Live Streams", value: "3", color: "bg-green-500" },
    { label: "Detection Events", value: "156", color: "bg-purple-500" },
    { label: "Model Accuracy", value: "94.2%", color: "bg-orange-500" },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              AI Monitoring Dashboard
            </h1>
            <p className="text-gray-600">
              Camera AI system status and real-time detection monitoring
            </p>
          </div>
          <div className="flex space-x-3">
            <Button variant="outline">View Live Cameras</Button>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => (
            <Card key={index} className="p-6">
              <div className="flex items-center">
                <div className={`p-2 rounded-lg ${stat.color}`}>
                  <div className="w-6 h-6 bg-white rounded" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-600">
                    {stat.label}
                  </p>
                  <p className="text-2xl font-bold text-gray-900">
                    {stat.value}
                  </p>
                </div>
              </div>
            </Card>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Recent AI Detections
            </h3>
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                >
                  <div>
                    <p className="font-medium text-gray-900">Camera RPi-{i}</p>
                    <p className="text-sm text-gray-600">
                      Pose Detection Event
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium text-gray-900">
                      Confidence: {92 + i}%
                    </p>
                    <p className="text-sm text-gray-600">
                      {new Date().toLocaleTimeString()}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </Card>

          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Quick Navigation
            </h3>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start">
                View Live Camera Feeds
              </Button>
              <Button variant="outline" className="w-full justify-start">
                Detection Event History
              </Button>
              <Button variant="outline" className="w-full justify-start">
                Camera Device Status
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
