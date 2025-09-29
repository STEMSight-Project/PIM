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
        <div className="flex items-center justify-between bg-gradient-to-r from-purple-600 to-violet-600 p-6 rounded-lg shadow-lg">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              onClick={() => router.push("/patients")}
              className="p-2 text-white hover:bg-purple-500 hover:bg-opacity-20"
            >
              <ArrowLeftIcon className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-white">
                {patient.first_name} {patient.last_name}
              </h1>
              <p className="text-purple-100">Subject ID: {patient.id}</p>
            </div>
          </div>
          <div className="flex space-x-3">
            <Button 
              variant="outline"
              onClick={() => router.push(`/medical-history/${patientId}`)}
              className="bg-white text-purple-600 border-white hover:bg-purple-50"
            > 
              <DocumentTextIcon className="h-4 w-4 mr-2" />
              Full Medical History
            </Button>
            <Button 
              variant="outline"
              onClick={() => router.push('/patient-edit/${patient.id}/edit')}
              className="bg-purple-800 hover:bg-purple-900 text-white border-purple-800"
            >
              <PencilIcon className="h-4 w-4 mr-2" />
              Edit Subject
            </Button>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-gradient-to-r from-purple-50 to-violet-50 border border-purple-200 rounded-lg">
          <nav className="flex space-x-8 p-2">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`group inline-flex items-center py-3 px-4 rounded-md font-medium text-sm transition-all ${
                  activeTab === tab.id
                    ? "bg-purple-600 text-white shadow-md"
                    : "text-purple-700 hover:text-purple-900 hover:bg-purple-100"
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
          <div className="space-y-6">
            {/* Quick Stats Row */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <Card className="p-4 bg-gradient-to-br from-purple-50 to-violet-50 border-purple-200">
                <div className="flex items-center">
                  <div className="p-3 rounded-lg bg-gradient-to-br from-purple-500 to-violet-500">
                    <DocumentTextIcon className="h-6 w-6 text-white" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-purple-700">Medical Records</p>
                    <p className="text-2xl font-bold text-purple-900">{medicalHistories.length}</p>
                  </div>
                </div>
              </Card>
              <Card className="p-4 bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200">
                <div className="flex items-center">
                  <div className="p-3 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-500">
                    <VideoCameraIcon className="h-6 w-6 text-white" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-blue-700">Sessions</p>
                    <p className="text-2xl font-bold text-blue-900">12</p>
                  </div>
                </div>
              </Card>
              <Card className="p-4 bg-gradient-to-br from-green-50 to-emerald-50 border-green-200">
                <div className="flex items-center">
                  <div className="p-3 rounded-lg bg-gradient-to-br from-green-500 to-emerald-500">
                    <EyeIcon className="h-6 w-6 text-white" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-green-700">Detections</p>
                    <p className="text-2xl font-bold text-green-900">156</p>
                  </div>
                </div>
              </Card>
              <Card className="p-4 bg-gradient-to-br from-orange-50 to-amber-50 border-orange-200">
                <div className="flex items-center">
                  <div className="p-3 rounded-lg bg-gradient-to-br from-orange-500 to-amber-500">
                    <ChartBarIcon className="h-6 w-6 text-white" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-orange-700">Avg Confidence</p>
                    <p className="text-2xl font-bold text-orange-900">94.2%</p>
                  </div>
                </div>
              </Card>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Personal Information */}
              <Card className="p-6 bg-gradient-to-br from-purple-50 to-violet-50 border-purple-200 shadow-lg">
                <h3 className="text-lg font-semibold text-purple-900 mb-4 flex items-center">
                  <UserIcon className="h-5 w-5 mr-2 text-purple-600" />
                  Personal Information
                </h3>
                <div className="space-y-4">
                  <div className="flex items-center p-3 bg-white rounded-lg border border-purple-100">
                    <CalendarIcon className="h-5 w-5 text-purple-500 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-purple-900">
                        Date of Birth
                      </p>
                      <p className="text-sm text-purple-700">
                        {formatDate(patient.date_of_birth)}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center p-3 bg-white rounded-lg border border-purple-100">
                    <UserIcon className="h-5 w-5 text-purple-500 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-purple-900">Gender</p>
                      <p className="text-sm text-purple-700 capitalize">
                        {patient.gender}
                      </p>
                    </div>
                  </div>
                  {patient.email && (
                    <div className="flex items-center p-3 bg-white rounded-lg border border-purple-100">
                      <EnvelopeIcon className="h-5 w-5 text-purple-500 mr-3" />
                      <div>
                        <p className="text-sm font-medium text-purple-900">Email</p>
                        <p className="text-sm text-purple-700">{patient.email}</p>
                      </div>
                    </div>
                  )}
                  {patient.phone && (
                    <div className="flex items-center p-3 bg-white rounded-lg border border-purple-100">
                      <PhoneIcon className="h-5 w-5 text-purple-500 mr-3" />
                      <div>
                        <p className="text-sm font-medium text-purple-900">Phone</p>
                        <p className="text-sm text-purple-700">{patient.phone}</p>
                      </div>
                    </div>
                  )}
                  {patient.address && (
                    <div className="flex items-center p-3 bg-white rounded-lg border border-purple-100">
                      <MapPinIcon className="h-5 w-5 text-purple-500 mr-3" />
                      <div>
                        <p className="text-sm font-medium text-purple-900">
                          Address
                        </p>
                        <p className="text-sm text-purple-700">{patient.address}</p>
                      </div>
                    </div>
                  )}
                </div>
              </Card>

              {/* Monitoring Statistics */}
              <Card className="p-6 bg-gradient-to-br from-blue-50 to-indigo-50 border-blue-200 shadow-lg">
                <h3 className="text-lg font-semibold text-blue-900 mb-4 flex items-center">
                  <ChartBarIcon className="h-5 w-5 mr-2 text-blue-600" />
                  Monitoring Statistics
                </h3>
                <div className="grid grid-cols-2 gap-4 mb-6">
                  <div className="text-center p-4 bg-white rounded-lg border border-blue-100">
                    <p className="text-2xl font-bold text-blue-600">12</p>
                    <p className="text-sm text-blue-700">Total Sessions</p>
                  </div>
                  <div className="text-center p-4 bg-white rounded-lg border border-green-100">
                    <p className="text-2xl font-bold text-green-600">156</p>
                    <p className="text-sm text-green-700">Detection Events</p>
                  </div>
                  <div className="text-center p-4 bg-white rounded-lg border border-purple-100">
                    <p className="text-2xl font-bold text-purple-600">94.2%</p>
                    <p className="text-sm text-purple-700">Avg Confidence</p>
                  </div>
                  <div className="text-center p-4 bg-white rounded-lg border border-orange-100">
                    <p className="text-2xl font-bold text-orange-600">2.3h</p>
                    <p className="text-sm text-orange-700">Total Monitored</p>
                  </div>
                </div>
                <div className="bg-white p-4 rounded-lg border border-blue-100">
                  <p className="text-sm text-blue-700 text-center">
                    Subject added on {formatDate(patient.created_at)}
                  </p>
                </div>
              </Card>
            </div>

            {/* Recent Activity Summary */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Recent Medical History */}
              <Card className="p-6 bg-gradient-to-br from-purple-50 to-violet-50 border-purple-200 shadow-lg">
                <h3 className="text-lg font-semibold text-purple-900 mb-4 flex items-center">
                  <DocumentTextIcon className="h-5 w-5 mr-2 text-purple-600" />
                  Recent Medical History
                </h3>
                {medicalHistories.slice(0, 3).length === 0 ? (
                  <div className="text-center py-6">
                    <DocumentTextIcon className="mx-auto h-8 w-8 text-purple-400" />
                    <p className="mt-2 text-sm text-purple-600">No medical records yet</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {medicalHistories.slice(0, 3).map((record) => (
                      <div key={record.id} className="bg-white p-3 rounded-lg border border-purple-100">
                        <div className="flex justify-between items-start">
                          <h4 className="font-medium text-purple-900 text-sm">
                            {record.diagnosis}
                          </h4>
                          <span className="text-xs text-purple-600">
                            {formatDate(record.created_at)}
                          </span>
                        </div>
                        {record.note && (
                          <p className="text-xs text-purple-700 mt-1 truncate">
                            {record.note}
                          </p>
                        )}
                      </div>
                    ))}
                    <Button 
                      variant="outline" 
                      onClick={() => router.push(`/medical-history/${patientId}`)}
                      className="w-full mt-3 text-purple-700 border-purple-300 hover:bg-purple-100"
                    >
                      View All Medical Records
                    </Button>
                  </div>
                )}
              </Card>

              {/* Recent Detections */}
              <Card className="p-6 bg-gradient-to-br from-green-50 to-emerald-50 border-green-200 shadow-lg">
                <h3 className="text-lg font-semibold text-green-900 mb-4 flex items-center">
                  <EyeIcon className="h-5 w-5 mr-2 text-green-600" />
                  Recent Detections
                </h3>
                <div className="space-y-3">
                  <div className="bg-white p-3 rounded-lg border border-green-100">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
                        <span className="text-sm font-medium text-green-900">Normal Posture</span>
                      </div>
                      <span className="text-xs text-green-600">96.4%</span>
                    </div>
                    <p className="text-xs text-green-700 mt-1">2 hours ago</p>
                  </div>
                  <div className="bg-white p-3 rounded-lg border border-orange-100">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <div className="w-2 h-2 bg-orange-500 rounded-full mr-2"></div>
                        <span className="text-sm font-medium text-orange-900">Forward Head</span>
                      </div>
                      <span className="text-xs text-orange-600">89.1%</span>
                    </div>
                    <p className="text-xs text-orange-700 mt-1">3 hours ago</p>
                  </div>
                  <div className="bg-white p-3 rounded-lg border border-red-100">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <div className="w-2 h-2 bg-red-500 rounded-full mr-2"></div>
                        <span className="text-sm font-medium text-red-900">Slouching</span>
                      </div>
                      <span className="text-xs text-red-600">92.7%</span>
                    </div>
                    <p className="text-xs text-red-700 mt-1">5 hours ago</p>
                  </div>
                  <Button 
                    variant="outline" 
                    onClick={() => setActiveTab("detections")}
                    className="w-full mt-3 text-green-700 border-green-300 hover:bg-green-100"
                  >
                    View All Detections
                  </Button>
                </div>
              </Card>
            </div>
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
            
            {medicalHistories.length > 0 && (
              <div className="mt-6 text-center">
                <Button 
                  variant="outline" 
                  onClick={() => router.push(`/medical-history/${patientId}`)}
                  className="w-full"
                >
                  <DocumentTextIcon className="h-4 w-4 mr-2" />
                  View Full Medical History & Manage Records
                </Button>
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
