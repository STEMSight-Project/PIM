"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { PatientList } from "@/features/patients/PatientList";

export default function PatientsPage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Monitoring Subjects
          </h1>
          <p className="text-gray-600">
            Manage subjects for camera AI monitoring and pose detection
          </p>
        </div>

        <PatientList />
      </div>
    </DashboardLayout>
  );
}
