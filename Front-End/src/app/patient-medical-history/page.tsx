"use client";
import ErrorMessage from "@/components/ErrorMessage";
import Footer from "@/components/Footer";
import Header from "@/components/Header";
import LoadingSpinner from "@/components/LoadingSpinner";
import MedicalHistoryForm from "@/components/MedicalHistoryForm";
import NoteEditor from "@/components/NoteEditor";
import { useMedicalHistory } from "@/hooks/useMedicalHistory";
import { usePatients } from "@/hooks/usePatients";
import { Patient } from "@/types";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import "./style.css";

export default function PatientMedicalHistory() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId") || "";

  // State for UI
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [editingHistoryId, setEditingHistoryId] = useState<string | null>(null);
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);

  // Local state for the current patient
  const [patient, setPatient] = useState<Patient | null>(null);
  const [patientLoading, setPatientLoading] = useState(false);
  const [patientError, setPatientError] = useState<string | null>(null);

  // Custom hooks for data and actions
  const { getPatient } = usePatients();
  const {
    medicalHistories,
    loading: historiesLoading,
    error: historiesError,
    createMedicalHistory,
    updateMedicalHistory,
    deleteMedicalHistory,
    clearError,
    fetchMedicalHistoriesByPatient,
  } = useMedicalHistory();

  // Fetch patient data
  useEffect(() => {
    const fetchPatient = async () => {
      if (!patientId) return;

      try {
        setPatientLoading(true);
        setPatientError(null);
        const result = await getPatient(patientId);

        if (result.success && result.data) {
          setPatient(result.data);
        } else {
          setPatientError(result.error || "Failed to fetch patient");
        }
      } catch (error) {
        setPatientError("Failed to fetch patient");
        console.error("Error fetching patient:", error);
      } finally {
        setPatientLoading(false);
      }
    };

    fetchPatient();
  }, [patientId]);

  // Load medical histories when patient ID changes
  useEffect(() => {
    if (patientId) {
      fetchMedicalHistoriesByPatient(patientId);
    }
  }, [patientId, fetchMedicalHistoriesByPatient]);

  // CREATE a new history record
  const handleCreateHistory = async (data: {
    diagnosis: string;
    note: string;
  }) => {
    try {
      await createMedicalHistory({
        patient_id: patientId,
        doctor_id: "d86f06ec-fd0a-42a7-872c-e8224a4b18f1", // Replace with actual doctor_id
        diagnosis: data.diagnosis,
        note: data.note || undefined,
      });
      setShowCreateForm(false);
    } catch (error) {
      console.error("Failed to create medical history:", error);
    }
  };

  // UPDATE an existing history record
  const handleUpdateHistory = async (
    id: string,
    data: { diagnosis: string; note: string }
  ) => {
    try {
      await updateMedicalHistory(id, {
        diagnosis: data.diagnosis,
        note: data.note || undefined,
      });
      setEditingHistoryId(null);
    } catch (error) {
      console.error("Failed to update medical history:", error);
    }
  };

  // UPDATE note only
  const handleUpdateNote = async (id: string, note: string) => {
    try {
      // Note: The existing hook doesn't have updateNote method, using updateMedicalHistory instead
      const history = medicalHistories.find((h) => h.id === id);
      if (history) {
        await updateMedicalHistory(id, {
          diagnosis: history.condition, // Use condition from the type
          note: note || undefined,
        });
      }
      setEditingNoteId(null);
    } catch (error) {
      console.error("Failed to update note:", error);
    }
  };

  // DELETE a history record
  const handleDeleteHistory = async (id: string) => {
    if (!confirm("Are you sure you want to delete this record?")) return;

    try {
      await deleteMedicalHistory(id);
    } catch (error) {
      console.error("Failed to delete medical history:", error);
    }
  };

  const loading = patientLoading || historiesLoading;
  const error = patientError || historiesError;

  if (loading && !patient && medicalHistories.length === 0) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
        <Header patientId={patientId} />
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12">
            <div className="flex items-center justify-center">
              <LoadingSpinner size="lg" />
              <span className="ml-4 text-lg text-gray-600">
                Loading patient information...
              </span>
            </div>
          </div>
        </div>
        <Footer />
      </div>
    );
  }

  if (!patient && !patientLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
        <Header patientId={patientId} />
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12">
            <div className="text-center">
              <div className="mx-auto h-24 w-24 bg-red-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="h-12 w-12 text-red-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={1.5}
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                  />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">
                Patient Not Found
              </h2>
              <p className="text-gray-600 mb-6">
                The requested patient could not be loaded. Please check the
                patient ID and try again.
              </p>
              <button
                onClick={() => window.history.back()}
                className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-medium rounded-lg hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200"
              >
                <svg
                  className="w-5 h-5 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M10 19l-7-7m0 0l7-7m-7 7h18"
                  />
                </svg>
                Go Back
              </button>
            </div>
          </div>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      <Header patientId={patientId} />

      {/* Hero Section with Patient Info */}
      {patient && (
        <div className="bg-white shadow-sm border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center space-x-4">
              <div className="h-16 w-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                <span className="text-2xl font-bold text-white">
                  {patient.first_name[0]}
                  {patient.last_name[0]}
                </span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  {patient.first_name} {patient.last_name}
                </h1>
                <p className="text-sm text-gray-600">
                  Patient ID: {patient.id}
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Page Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900">
                Medical History
              </h2>
              <p className="text-gray-600 mt-1">
                Manage patient medical records and notes
              </p>
            </div>
            {!showCreateForm && (
              <button
                className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-medium rounded-lg hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 shadow-lg hover:shadow-xl"
                onClick={() => setShowCreateForm(true)}
              >
                <svg
                  className="w-5 h-5 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 4v16m8-8H4"
                  />
                </svg>
                Add New Record
              </button>
            )}
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="mb-6">
            <ErrorMessage message={error} onDismiss={clearError} />
          </div>
        )}

        {/* Create Form */}
        {showCreateForm && (
          <div className="bg-white rounded-xl shadow-lg border border-gray-200 p-6 mb-8">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-semibold text-gray-900">
                Create New Medical Record
              </h3>
              <button
                onClick={() => setShowCreateForm(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg
                  className="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <MedicalHistoryForm
              onSubmit={handleCreateHistory}
              onCancel={() => setShowCreateForm(false)}
              submitLabel="Create Record"
            />
          </div>
        )}

        {/* Loading State */}
        {loading && (
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12">
            <div className="flex items-center justify-center">
              <LoadingSpinner size="lg" />
              <span className="ml-4 text-lg text-gray-600">
                Loading medical histories...
              </span>
            </div>
          </div>
        )}

        {/* Medical History Records */}
        {medicalHistories.length > 0 ? (
          <div className="space-y-6">
            {medicalHistories.map((history, index) => (
              <div
                key={history.id}
                className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden hover:shadow-xl transition-shadow duration-200"
              >
                {editingHistoryId === history.id ? (
                  <div className="p-6">
                    <div className="flex items-center justify-between mb-6">
                      <h3 className="text-xl font-semibold text-gray-900">
                        Edit Medical Record
                      </h3>
                      <button
                        onClick={() => setEditingHistoryId(null)}
                        className="text-gray-400 hover:text-gray-600 transition-colors"
                      >
                        <svg
                          className="w-6 h-6"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M6 18L18 6M6 6l12 12"
                          />
                        </svg>
                      </button>
                    </div>
                    <MedicalHistoryForm
                      initialData={{
                        diagnosis: history.condition || "",
                        note: history.notes || "",
                      }}
                      onSubmit={(data) => handleUpdateHistory(history.id, data)}
                      onCancel={() => setEditingHistoryId(null)}
                      submitLabel="Update Record"
                    />
                  </div>
                ) : (
                  <>
                    {/* Record Header */}
                    <div className="bg-gradient-to-r from-gray-50 to-blue-50 px-6 py-4 border-b border-gray-200">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                          <div className="h-8 w-8 bg-blue-100 rounded-full flex items-center justify-center">
                            <span className="text-sm font-semibold text-blue-600">
                              #{index + 1}
                            </span>
                          </div>
                          <div>
                            <h4 className="text-lg font-semibold text-gray-900">
                              Medical Record
                            </h4>
                            <p className="text-sm text-gray-500">
                              Created:{" "}
                              {new Date(history.created_at).toLocaleDateString(
                                "en-US",
                                {
                                  year: "numeric",
                                  month: "long",
                                  day: "numeric",
                                  hour: "2-digit",
                                  minute: "2-digit",
                                }
                              )}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <button
                            className="inline-flex items-center px-3 py-1.5 bg-orange-100 text-orange-700 text-sm font-medium rounded-lg hover:bg-orange-200 transition-colors duration-200"
                            onClick={() => setEditingHistoryId(history.id)}
                          >
                            <svg
                              className="w-4 h-4 mr-1"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                              />
                            </svg>
                            Edit
                          </button>
                          <button
                            className="inline-flex items-center px-3 py-1.5 bg-red-100 text-red-700 text-sm font-medium rounded-lg hover:bg-red-200 transition-colors duration-200"
                            onClick={() => handleDeleteHistory(history.id)}
                          >
                            <svg
                              className="w-4 h-4 mr-1"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                              />
                            </svg>
                            Delete
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Record Content */}
                    <div className="p-6">
                      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        {/* Diagnosis Section */}
                        <div className="space-y-3">
                          <div className="flex items-center space-x-2">
                            <div className="h-2 w-2 bg-blue-500 rounded-full"></div>
                            <h5 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
                              Diagnosis
                            </h5>
                          </div>
                          <div className="bg-gray-50 rounded-lg p-4">
                            <p className="text-gray-900 leading-relaxed">
                              {history.condition}
                            </p>
                          </div>
                        </div>

                        {/* Notes Section */}
                        <div className="space-y-3">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-2">
                              <div className="h-2 w-2 bg-purple-500 rounded-full"></div>
                              <h5 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
                                Notes
                              </h5>
                            </div>
                            {editingNoteId !== history.id && (
                              <button
                                onClick={() => setEditingNoteId(history.id)}
                                className="text-blue-600 hover:text-blue-700 text-sm font-medium transition-colors duration-200"
                              >
                                Edit Note
                              </button>
                            )}
                          </div>

                          {editingNoteId === history.id ? (
                            <div className="bg-gray-50 rounded-lg p-4">
                              <NoteEditor
                                initialNote={history.notes || ""}
                                onSave={(note) =>
                                  handleUpdateNote(history.id, note)
                                }
                                onCancel={() => setEditingNoteId(null)}
                              />
                            </div>
                          ) : (
                            <div className="bg-gray-50 rounded-lg p-4">
                              <p className="text-gray-900 leading-relaxed">
                                {history.notes || (
                                  <span className="text-gray-500 italic">
                                    No notes available
                                  </span>
                                )}
                              </p>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </div>
            ))}
          </div>
        ) : !loading ? (
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12">
            <div className="text-center">
              <div className="mx-auto h-24 w-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="h-12 w-12 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={1.5}
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                No Medical Records
              </h3>
              <p className="text-gray-600 mb-6">
                This patient doesn't have any medical history records yet.
              </p>
              <button
                className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-medium rounded-lg hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200"
                onClick={() => setShowCreateForm(true)}
              >
                <svg
                  className="w-5 h-5 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 4v16m8-8H4"
                  />
                </svg>
                Create First Record
              </button>
            </div>
          </div>
        ) : null}
      </main>

      <Footer />
    </div>
  );
}
