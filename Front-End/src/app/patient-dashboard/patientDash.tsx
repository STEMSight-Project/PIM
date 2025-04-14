"use client";
import { useEffect, useState } from "react";
import Header from "@/components/Header"; // Import the Header component
import Footer from "@/components/Footer";
type Patient = {
  id: string; // UUID from Supabase
  first_name: string;
  last_name: string;
  isLive: boolean; // Determines the live/offline status
  created_at: string;
  stationNumber?: number; // Optional station number field
};

export default function PatientDashboard() {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch patient data from the backend
    fetch("http://127.0.0.1:8000/patients/")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to fetch patients");
        }
        return response.json();
      })
      .then((data) => {
        // Assign a station number to all patients and simulate live status
        const updatedPatients = data.map((patient: Patient) => {
          const isLive = Math.random() < 0.1; // Randomly set isLive to true for ~10% of patients
          return {
            ...patient,
            isLive,
            stationNumber: Math.floor(Math.random() * 10) + 1, // Assign a random station number (1-10) to all patients
          };
        });
        setPatients(updatedPatients);
        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching patients:", error);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  // Separate active and inactive patients
  const activePatients = patients.filter((patient) => patient.isLive);
  const inactivePatients = patients.filter((patient) => !patient.isLive);

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <Header />

      <div className="p-6">
        <div className="max-w-4xl mx-auto bg-white shadow-lg rounded-lg p-6">
          <h1 className="text-2xl font-bold mb-4">
            🩺 Patient Monitoring Dashboard
          </h1>

          {/* Active Patients (Live) */}
          <div>
            <h2 className="text-xl font-semibold mb-4">🟢 Active Patients</h2>
            <ul className="space-y-3">
              {activePatients.length > 0 ? (
                activePatients.map((patient) => (
                  <PatientCard key={patient.id} patient={patient} />
                ))
              ) : (
                <p className="text-gray-500 text-center">
                  No active patients under observation.
                </p>
              )}
            </ul>
          </div>

          {/* Inactive Patients (Recorded) */}
          <div className="mt-6">
            <h2 className="text-xl font-semibold mb-4">⚪ Inactive Patients</h2>
            <ul className="space-y-3">
              {inactivePatients.length > 0 ? (
                inactivePatients.map((patient) => (
                  <PatientCard key={patient.id} patient={patient} />
                ))
              ) : (
                <p className="text-gray-500 text-center">No inactive patients.</p>
              )}
            </ul>
          </div>
        </div>
      </div>
        <Footer />
    </div>
  );
}

const PatientCard = ({ patient }: { patient: Patient }) => {
  const currentDate = new Date().toLocaleDateString();

  const liveLink = patient.isLive
    ? `/streamingDash?patientId=${patient.id}`
    : null;
  const sessionReviewLink = !patient.isLive
    ? `/video-playback?patientId=${patient.id}`
    : null;
  const medicalHistoryLink = `/patient-medical-history?patientId=${patient.id}`;

  return (
    <li
      className={`flex items-center justify-between p-4 bg-gray-50 rounded-lg shadow-sm hover:bg-gray-100 transition ${
        liveLink || sessionReviewLink ? "cursor-pointer" : ""
      }`}
      onClick={() => {
        if (liveLink) {
          window.location.href = liveLink;
        } else if (sessionReviewLink) {
          window.location.href = sessionReviewLink;
        }
      }}
    >
      <div className="flex items-center space-x-3">
        <div
          className={`w-4 h-4 rounded-full ${
            patient.isLive ? "bg-green-600 animate-pulse" : "bg-red-500"
          }`}
          aria-hidden="true"
        />
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            {patient.first_name} {patient.last_name}
            {patient.stationNumber && (
              <span className="ml-2 text-sm text-gray-500">
                Station: {patient.stationNumber}
              </span>
            )}
          </h3>
          <p className="text-gray-600 text-sm">
            {patient.isLive
              ? `Current Date: ${currentDate}`
              : `Recorded On: ${patient.created_at}`}
          </p>
        </div>
      </div>

      {/* Buttons */}
      <div className="flex space-x-2">
        <a
          href={medicalHistoryLink}
          className="px-4 py-2 text-sm bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 flex items-center gap-2"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9 12h6m2 0a2 2 0 100-4H7a2 2 0 100 4m0 0v6m0-6h10"
            />
          </svg>
          Medical History
        </a>

        <a
          href={`/results-page?patientId=${patient.id}`} // Pass patientId as a query parameter
          className="px-4 py-2 text-sm bg-blue-800 text-white rounded-lg hover:bg-blue-600 flex items-center gap-2"
        >
          View Results
        </a>
      </div>
    </li>
  );
};
