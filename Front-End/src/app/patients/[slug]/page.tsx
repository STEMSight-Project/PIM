"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useMedicalHistory, usePatients } from "@/hooks";
import type { Patient } from "@/types/medical";
import { formatDate } from "@/utils/cn";
import {
  ArrowLeftIcon,
  CalendarIcon,
  ChartBarIcon,
  DocumentTextIcon,
  EnvelopeIcon,
  EyeIcon,
  MapPinIcon,
  PencilIcon,
  PhoneIcon,
  UserIcon,
  VideoCameraIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function PatientDetailPage() {
  const params = useParams();
  const router = useRouter();
  const patientId = params.slug as string;

  const [patient, setPatient] = useState<Patient | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<
    "overview" | "history" | "detections" | "videos"
  >("overview");

  const { getPatient } = usePatients();
  const { fetchMedicalHistoriesByPatient, medicalHistories } =
    useMedicalHistory();

  useEffect(() => {
    const fetchPatientData = async () => {
      if (!patientId) return;

      try {
        setIsLoading(true);
        setError(null);

        // Fetch patient details
        const patientResult = await getPatient(patientId);
        if (!patientResult.success || !patientResult.data) {
          setError(patientResult.error || "Patient not found");
          return;
        }
        setPatient(patientResult.data);

        // Fetch medical history
        await fetchMedicalHistoriesByPatient(patientId);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to load patient data"
        );
      } finally {
        setIsLoading(false);
      }
    };

    fetchPatientData();
  }, [patientId]);

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading patient information..." />
        </div>
      </DashboardLayout>
    );
  }

  if (error || !patient) {
    return (
      <DashboardLayout>
        <div className="max-w-md mx-auto mt-12">
          <Alert variant="error">{error || "Patient not found"}</Alert>
          <div className="mt-6 text-center">
            <Button onClick={() => router.push("/patients")}>
              <ArrowLeftIcon className="h-4 w-4 mr-2" />
              Back to Patients
            </Button>
          </div>
        </div>
      </DashboardLayout>
    );
  }

  const tabs = [
    { id: "overview", label: "Overview", icon: UserIcon },
    { id: "history", label: "Medical History", icon: DocumentTextIcon },
    { id: "detections", label: "Detection History", icon: EyeIcon },
    { id: "videos", label: "Video Sessions", icon: VideoCameraIcon },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              onClick={() => router.push("/patients")}
              className="p-2"
            >
              <ArrowLeftIcon className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                {patient.first_name} {patient.last_name}
              </h1>
              <p className="text-gray-600">Subject ID: {patient.id}</p>
            </div>
          </div>
          <div className="flex space-x-3">
            <Button variant="outline">
              <PencilIcon className="h-4 w-4 mr-2" />
              Edit Subject
            </Button>
          </div>
        </div>

        {/* Tabs */}
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`group inline-flex items-center py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? "border-blue-500 text-blue-600"
                    : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                }`}
              >
                <tab.icon className="h-5 w-5 mr-2" />
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Tab Content */}
        {activeTab === "overview" && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Personal Information */}
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <UserIcon className="h-5 w-5 mr-2" />
                Personal Information
              </h3>
              <div className="space-y-4">
                <div className="flex items-center">
                  <CalendarIcon className="h-5 w-5 text-gray-400 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      Date of Birth
                    </p>
                    <p className="text-sm text-gray-600">
                      {formatDate(patient.date_of_birth)}
                    </p>
                  </div>
                </div>
                <div className="flex items-center">
                  <UserIcon className="h-5 w-5 text-gray-400 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">Gender</p>
                    <p className="text-sm text-gray-600 capitalize">
                      {patient.gender}
                    </p>
                  </div>
                </div>
                {patient.email && (
                  <div className="flex items-center">
                    <EnvelopeIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">Email</p>
                      <p className="text-sm text-gray-600">{patient.email}</p>
                    </div>
                  </div>
                )}
                {patient.phone && (
                  <div className="flex items-center">
                    <PhoneIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">Phone</p>
                      <p className="text-sm text-gray-600">{patient.phone}</p>
                    </div>
                  </div>
                )}
                {patient.address && (
                  <div className="flex items-center">
                    <MapPinIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        Address
                      </p>
                      <p className="text-sm text-gray-600">{patient.address}</p>
                    </div>
                  </div>
                )}
              </div>
            </Card>

            {/* Monitoring Statistics */}
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <ChartBarIcon className="h-5 w-5 mr-2" />
                Monitoring Statistics
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center p-4 bg-blue-50 rounded-lg">
                  <p className="text-2xl font-bold text-blue-600">12</p>
                  <p className="text-sm text-gray-600">Total Sessions</p>
                </div>
                <div className="text-center p-4 bg-green-50 rounded-lg">
                  <p className="text-2xl font-bold text-green-600">156</p>
                  <p className="text-sm text-gray-600">Detection Events</p>
                </div>
                <div className="text-center p-4 bg-purple-50 rounded-lg">
                  <p className="text-2xl font-bold text-purple-600">94.2%</p>
                  <p className="text-sm text-gray-600">Avg Confidence</p>
                </div>
                <div className="text-center p-4 bg-orange-50 rounded-lg">
                  <p className="text-2xl font-bold text-orange-600">2.3h</p>
                  <p className="text-sm text-gray-600">Total Monitored</p>
                </div>
              </div>
              <div className="mt-4">
                <p className="text-sm text-gray-600">
                  Subject added on {formatDate(patient.created_at)}
                </p>
              </div>
            </Card>
          </div>
        )}

        {activeTab === "history" && (
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <DocumentTextIcon className="h-5 w-5 mr-2" />
              Medical History & Detection Records
            </h3>
            {medicalHistories.length === 0 ? (
              <div className="text-center py-8">
                <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-2 text-sm font-medium text-gray-900">
                  No medical history
                </h3>
                <p className="mt-1 text-sm text-gray-500">
                  No detection records or medical history available for this
                  subject.
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {medicalHistories.map((record) => (
                  <div
                    key={record.id}
                    className="border border-gray-200 rounded-lg p-4"
                  >
                    <div className="flex justify-between items-start mb-2">
                      <h4 className="font-medium text-gray-900">
                        {record.diagnosis}
                      </h4>
                      <span className="text-sm text-gray-500">
                        {formatDate(record.created_at)}
                      </span>
                    </div>
                    {record.note && (
                      <p className="text-sm text-gray-600 mb-2">
                        {record.note}
                      </p>
                    )}
                    {record.doctor_id && (
                      <p className="text-xs text-gray-500">
                        Doctor: {record.doctor_id}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            )}
          </Card>
        )}

        {activeTab === "detections" && (
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <EyeIcon className="h-5 w-5 mr-2" />
              Camera Detection History
            </h3>
            <div className="space-y-6">
              {/* Recent Detection Summary */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-blue-50 p-4 rounded-lg">
                  <div className="flex items-center">
                    <ChartBarIcon className="h-8 w-8 text-blue-600" />
                    <div className="ml-3">
                      <p className="text-sm font-medium text-gray-900">
                        Latest Session
                      </p>
                      <p className="text-xs text-gray-600">2 hours ago</p>
                    </div>
                  </div>
                </div>
                <div className="bg-green-50 p-4 rounded-lg">
                  <div className="flex items-center">
                    <EyeIcon className="h-8 w-8 text-green-600" />
                    <div className="ml-3">
                      <p className="text-sm font-medium text-gray-900">
                        Today's Detections
                      </p>
                      <p className="text-xs text-gray-600">23 movements</p>
                    </div>
                  </div>
                </div>
                <div className="bg-purple-50 p-4 rounded-lg">
                  <div className="flex items-center">
                    <UserIcon className="h-8 w-8 text-purple-600" />
                    <div className="ml-3">
                      <p className="text-sm font-medium text-gray-900">
                        Avg Confidence
                      </p>
                      <p className="text-xs text-gray-600">94.2%</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Detection Records */}
              <div className="space-y-4">
                <h4 className="text-sm font-medium text-gray-900">
                  Recent Detection Events
                </h4>

                {/* Sample detection records */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                    <div className="flex items-center space-x-4">
                      <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          Normal Posture
                        </p>
                        <p className="text-xs text-gray-600">
                          Confidence: 96.4% • Duration: 2m 34s
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-gray-500">Today 14:23</p>
                      <p className="text-xs text-gray-400">Session #12</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-4 border border-orange-200 rounded-lg bg-orange-50">
                    <div className="flex items-center space-x-4">
                      <div className="w-2 h-2 bg-orange-500 rounded-full"></div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          Forward Head Posture
                        </p>
                        <p className="text-xs text-gray-600">
                          Confidence: 89.1% • Duration: 45s
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-gray-500">Today 14:19</p>
                      <p className="text-xs text-gray-400">Session #12</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-4 border border-red-200 rounded-lg bg-red-50">
                    <div className="flex items-center space-x-4">
                      <div className="w-2 h-2 bg-red-500 rounded-full"></div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          Slouching Detected
                        </p>
                        <p className="text-xs text-gray-600">
                          Confidence: 92.7% • Duration: 1m 12s
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-gray-500">Today 13:45</p>
                      <p className="text-xs text-gray-400">Session #11</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                    <div className="flex items-center space-x-4">
                      <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          Movement - Neck Rotation
                        </p>
                        <p className="text-xs text-gray-600">
                          Confidence: 94.8% • Range: 45° left
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-gray-500">Today 13:42</p>
                      <p className="text-xs text-gray-400">Session #11</p>
                    </div>
                  </div>
                </div>

                <div className="text-center mt-6">
                  <Button variant="outline">
                    <ChartBarIcon className="h-4 w-4 mr-2" />
                    View Detailed Analytics
                  </Button>
                </div>
              </div>
            </div>
          </Card>
        )}

        {activeTab === "videos" && (
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <VideoCameraIcon className="h-5 w-5 mr-2" />
              Video Sessions & Camera Feeds
            </h3>
            <div className="text-center py-8">
              <VideoCameraIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No video sessions
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                No recorded video sessions available for this subject.
              </p>
            </div>
          </Card>
        )}
      </div>
    </DashboardLayout>
  );
}
