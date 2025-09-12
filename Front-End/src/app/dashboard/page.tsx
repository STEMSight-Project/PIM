"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { useAuth } from "@/hooks/useAuth";

export default function DashboardPage() {
  const { user } = useAuth();

  const stats = [
    { label: "Total Patients", value: "24", color: "bg-blue-500" },
    { label: "Active Sessions", value: "3", color: "bg-green-500" },
    { label: "Reports Generated", value: "156", color: "bg-purple-500" },
    { label: "Critical Alerts", value: "2", color: "bg-red-500" },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
            <p className="text-gray-600">
              Welcome back, {user?.first_name || "Doctor"}
            </p>
          </div>
          <Button>New Session</Button>
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
              Recent Sessions
            </h3>
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                >
                  <div>
                    <p className="font-medium text-gray-900">Patient {i}</p>
                    <p className="text-sm text-gray-600">Session #{i}001</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium text-gray-900">
                      {new Date().toLocaleDateString()}
                    </p>
                    <p className="text-sm text-gray-600">Completed</p>
                  </div>
                </div>
              ))}
            </div>
          </Card>

          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Quick Actions
            </h3>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start">
                Start New Analysis
              </Button>
              <Button variant="outline" className="w-full justify-start">
                View Reports
              </Button>
              <Button variant="outline" className="w-full justify-start">
                Manage Patients
              </Button>
              <Button variant="outline" className="w-full justify-start">
                System Settings
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
