"use client";

import EnhancedMedicalHistoryForm from "@/components/EnhancedMedicalHistoryForm";
import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { MedicalHistoryFilters } from "@/components/MedicalHistoryFilters";
import { MedicalHistoryStats } from "@/components/MedicalHistoryStats";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { useMedicalHistory, usePatients } from "@/hooks";
import type { MedicalHistory } from "@/services/medicalHistoryService";
import type { Patient } from "@/types/medical";
import { formatDate } from "@/utils/cn";
import {
    ArrowLeftIcon,
    CalendarIcon,
    DocumentTextIcon,
    PencilIcon,
    PlusIcon,
    TrashIcon,
    UserIcon,
} from "@heroicons/react/24/outline";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function MedicalHistoryPage() {
  const params = useParams();
  const router = useRouter();
  const patientId = params.patientId as string;

  const [patient, setPatient] = useState<Patient | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingRecord, setEditingRecord] = useState<MedicalHistory | null>(null);
  
  // Filtering states
  const [filteredRecords, setFilteredRecords] = useState<MedicalHistory[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedDoctor, setSelectedDoctor] = useState("");
  const [dateRange, setDateRange] = useState<{ start: string; end: string } | null>(null);

  const { getPatient } = usePatients();
  const {
    fetchMedicalHistoriesByPatient,
    medicalHistories,
    createMedicalHistory,
    updateMedicalHistory,
    deleteMedicalHistory,
    loading,
    error: medicalHistoryError
  } = useMedicalHistory();

  useEffect(() => {
    const fetchData = async () => {
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

    fetchData();
  }, [patientId]);

  // Update filtered records when medical histories or filters change
  useEffect(() => {
    let filtered = [...medicalHistories];

    // Apply search filter
    if (searchTerm) {
      filtered = filtered.filter(record => 
        record.diagnosis.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (record.note && record.note.toLowerCase().includes(searchTerm.toLowerCase()))
      );
    }

    // Apply doctor filter
    if (selectedDoctor) {
      filtered = filtered.filter(record => record.doctor_id === selectedDoctor);
    }

    // Apply date range filter
    if (dateRange) {
      filtered = filtered.filter(record => {
        const recordDate = new Date(record.created_at);
        const startDate = new Date(dateRange.start);
        const endDate = new Date(dateRange.end);
        return recordDate >= startDate && recordDate <= endDate;
      });
    }

    setFilteredRecords(filtered);
  }, [medicalHistories, searchTerm, selectedDoctor, dateRange]);

  // Get unique doctors for filter dropdown
  const uniqueDoctors = [...new Set(medicalHistories.map(record => record.doctor_id))];

  const handleSearch = (term: string) => {
    setSearchTerm(term);
  };

  const handleDoctorFilter = (doctorId: string) => {
    setSelectedDoctor(doctorId);
  };

  const handleDateFilter = (range: { start: string; end: string }) => {
    setDateRange(range);
  };

  const handleClearFilters = () => {
    setSearchTerm("");
    setSelectedDoctor("");
    setDateRange(null);
  };

  const handleAddMedicalHistory = async (formData: {
    doctor_id: string;
    diagnosis: string;
    note: string;
  }) => {
    const result = await createMedicalHistory({
      patient_id: patientId,
      ...formData,
    });
    
    if (result) {
      setShowAddForm(false);
    }
  };

  const handleEditMedicalHistory = async (formData: {
    doctor_id: string;
    diagnosis: string;
    note: string;
  }) => {
    if (!editingRecord) return;

    const result = await updateMedicalHistory(editingRecord.id, formData);
    
    if (result) {
      setEditingRecord(null);
    }
  };

  const handleDeleteRecord = async (id: string) => {
    if (window.confirm("Are you sure you want to delete this medical history record?")) {
      await deleteMedicalHistory(id);
    }
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center py-12">
          <Loading size="lg" text="Loading medical history..." />
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

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center space-x-4 mb-2">
              <Button
                variant="ghost"
                onClick={() => router.push(`/patients/${patientId}`)}
                className="p-2"
              >
                <ArrowLeftIcon className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  Medical History
                </h1>
                <p className="text-gray-600">
                  {patient.first_name} {patient.last_name}
                </p>
              </div>
            </div>
          </div>
          <Button
            onClick={() => setShowAddForm(!showAddForm)}
            variant={showAddForm ? "outline" : "primary"}
            className="flex items-center"
          >
            <PlusIcon className="h-4 w-4 mr-2" />
            {showAddForm ? "Cancel" : "Add New Record"}
          </Button>
        </div>

        {/* Patient Info Summary */}
        <Card className="p-4">
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
              <UserIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-900">
                {patient.first_name} {patient.last_name}
              </h3>
              <div className="flex items-center space-x-4 text-sm text-gray-600">
                <div className="flex items-center">
                  <CalendarIcon className="h-4 w-4 mr-1" />
                  Born {formatDate(patient.date_of_birth)}
                </div>
                <div>Gender: {patient.gender}</div>
                {patient.email && <div>Email: {patient.email}</div>}
              </div>
            </div>
          </div>
        </Card>

        {/* Medical History Stats */}
        <MedicalHistoryStats medicalHistories={medicalHistories} />

        {/* Filters */}
        {medicalHistories.length > 0 && (
          <MedicalHistoryFilters
            onSearch={handleSearch}
            onDoctorFilter={handleDoctorFilter}
            onDateFilter={handleDateFilter}
            onClearFilters={handleClearFilters}
            doctorOptions={uniqueDoctors}
          />
        )}

        {/* Add Form */}
        {showAddForm && (
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Add New Medical Record
            </h3>
            <EnhancedMedicalHistoryForm
              onSubmit={handleAddMedicalHistory}
              onCancel={() => setShowAddForm(false)}
              isLoading={loading}
              submitLabel="Add Medical Record"
            />
          </Card>
        )}

        {/* Error Alert */}
        {medicalHistoryError && (
          <Alert variant="error">{medicalHistoryError}</Alert>
        )}

        {/* Medical History Records */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-semibold text-gray-900 flex items-center">
              <DocumentTextIcon className="h-5 w-5 mr-2" />
              Medical History Records
            </h3>
            <div className="text-sm text-gray-500">
              {filteredRecords.length} of {medicalHistories.length} record{medicalHistories.length !== 1 ? 's' : ''}
              {filteredRecords.length !== medicalHistories.length && " (filtered)"}
            </div>
          </div>

          {filteredRecords.length === 0 ? (
            <div className="text-center py-12">
              <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                {medicalHistories.length === 0 ? "No medical history" : "No matching records"}
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                {medicalHistories.length === 0 
                  ? "No medical history records available for this patient." 
                  : "Try adjusting your filters to see more results."}
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredRecords.map((record) => (
                <div key={record.id}>
                  {editingRecord?.id === record.id ? (
                    /* Edit Form */
                    <div className="border border-blue-200 rounded-lg p-4 bg-blue-50">
                      <h4 className="font-medium text-gray-900 mb-4">
                        Edit Medical Record
                      </h4>
                      <EnhancedMedicalHistoryForm
                        initialData={{
                          doctor_id: record.doctor_id,
                          diagnosis: record.diagnosis,
                          note: record.note || "",
                        }}
                        onSubmit={handleEditMedicalHistory}
                        onCancel={() => setEditingRecord(null)}
                        isLoading={loading}
                        submitLabel="Update Record"
                      />
                    </div>
                  ) : (
                    /* Display Record */
                    <div className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="flex justify-between items-start mb-2">
                            <h4 className="font-semibold text-gray-900 text-lg">
                              {record.diagnosis}
                            </h4>
                            <div className="flex items-center space-x-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => setEditingRecord(record)}
                                className="p-2"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDeleteRecord(record.id)}
                                className="p-2 text-red-600 hover:text-red-700 hover:bg-red-50"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </Button>
                            </div>
                          </div>
                          
                          {record.note && (
                            <div className="mb-3">
                              <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded-md">
                                {record.note}
                              </p>
                            </div>
                          )}
                          
                          <div className="flex items-center justify-between text-xs text-gray-500">
                            <div>
                              Doctor: <span className="font-medium">{record.doctor_id}</span>
                            </div>
                            <div className="flex items-center">
                              <CalendarIcon className="h-3 w-3 mr-1" />
                              {formatDate(record.created_at)}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
}