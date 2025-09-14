"use client";

import { Card, CardContent } from "@/components/ui/Card";
import type { Patient } from "@/types";

interface DashboardStatsProps {
  patients: Patient[];
}

export function DashboardStats({ patients }: DashboardStatsProps) {
  const totalPatients = patients.length;

  // Calculate age groups
  const currentYear = new Date().getFullYear();
  const ageGroups = patients.reduce(
    (acc, patient) => {
      const birthYear = new Date(patient.date_of_birth).getFullYear();
      const age = currentYear - birthYear;

      if (age < 18) acc.children++;
      else if (age < 65) acc.adults++;
      else acc.seniors++;

      return acc;
    },
    { children: 0, adults: 0, seniors: 0 }
  );

  const stats = [
    {
      label: "Total Patients",
      value: totalPatients,
      icon: (
        <svg
          className="w-5 h-5 text-blue-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857M15 11a3 3 0 11-6 0 3 3 0 016 0z"
          />
        </svg>
      ),
      bgColor: "bg-blue-100",
    },
    {
      label: "Adult Patients",
      value: ageGroups.adults,
      icon: (
        <svg
          className="w-5 h-5 text-green-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
          />
        </svg>
      ),
      bgColor: "bg-green-100",
    },
    {
      label: "Senior Patients",
      value: ageGroups.seniors,
      icon: (
        <svg
          className="w-5 h-5 text-purple-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
          />
        </svg>
      ),
      bgColor: "bg-purple-100",
    },
    {
      label: "Recent Records",
      value: patients.filter((p) => {
        const createdDate = new Date(p.created_at);
        const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        return createdDate >= weekAgo;
      }).length,
      icon: (
        <svg
          className="w-5 h-5 text-orange-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      ),
      bgColor: "bg-orange-100",
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {stats.map((stat, index) => (
        <Card key={index}>
          <CardContent className="pt-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div
                  className={`w-8 h-8 ${stat.bgColor} rounded-md flex items-center justify-center`}
                >
                  {stat.icon}
                </div>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">
                  {stat.label}
                </p>
                <p className="text-2xl font-semibold text-gray-900">
                  {stat.value}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
