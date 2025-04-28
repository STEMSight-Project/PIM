"use client";

import React, { useState, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import SessionReview from "@/components/session-review/SessionReview";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { getAllPatients, getPatient } from "@/services/patientService";

interface Patient {
  id: string;
  first_name: string;
  last_name: string;
}

export default function SessionReviewPage() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (patientId) {
      // Fetch specific patient by ID
      getPatient(patientId)
        .then((patient) => {
          if (!patient) throw new Error("Failed to fetch patient data");
          setPatient(patient);
          setLoading(false);
        })
        .catch((error) => {
          console.error("Error fetching patient data:", error);
          setLoading(false);
        });
    } else {
      // Fetch all patients and select one randomly
      getAllPatients()
        .then((patients) => {
          if (!patients) throw new Error("Failed to fetch patients");
          const randomPatient =
            patients[Math.floor(Math.random() * patients.length)];
          setPatient(randomPatient);
        })
        .catch((error) => {
          console.error("Error fetching patients:", error);
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
    <div className="bg-gray-50 min-h-screen">
      <Header patientId={patientId} />
      <SessionReview initialPatient={patient} />
      <Footer />
    </div>
  );
}
