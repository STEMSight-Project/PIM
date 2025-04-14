"use client";
import "./style.css";
import { Suspense, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Header from "@/components/Header"; // Import the Header component
type Patient = {
  id: string;
  first_name: string;
  last_name: string;
  medical_history: string; // Medical history is a string
};

function Page() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId"); // Retrieve the patientId from the URL
  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (patientId) {
      // Fetch the patient data by ID
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) {
            throw new Error("Failed to fetch patient data");
          }
          return response.json();
        })
        .then((data) => {
          setPatient(data);
          setLoading(false);
        })
        .catch((error) => {
          console.error("Error fetching patient data:", error);
          setLoading(false);
        });
    }
  }, [patientId]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!patient) {
    return <div>Patient not found.</div>;
  }

  return (
    <div className="bg-white text-black min-h-screen">
      {/* Pass patientId to Header */}
      <Header patientId={patientId} />
      <header className="text-center p-6 text-2xl font-bold">
        Patient Name:{" "}
        <span className="text-blue-600">
          {patient.first_name} {patient.last_name}
        </span>
      </header>

      <main className="max-w-3xl mx-auto p-6">
        <h2 className="text-xl font-semibold mb-4">Medical History</h2>
        <div className="space-y-4">
          {patient.medical_history ? (
            <div className="border p-4 rounded shadow">
              <p>{patient.medical_history}</p>
            </div>
          ) : (
            <p>No medical history available for this patient.</p>
          )}
        </div>
      </main>

      <footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
        &copy; 2025 STEMSight Inc. All rights reserved.
      </footer>
    </div>
  );
}

export default function PatientMedicalHistory() {
  return (
    <Suspense>
      <Page />
    </Suspense>
  );
}
