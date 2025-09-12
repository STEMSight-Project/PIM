"use client";

import React, { useState, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import SessionReview from "@/components/session-review/SessionReview";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { usePatients } from "@/hooks";
import type { Patient } from "@/types";

export default function SessionReviewPage() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  const { patients, getPatient } = usePatients();

  useEffect(() => {
    if (patientId) {
      // Fetch specific patient by ID
      getPatient(patientId)
        .then((result) => {
          if (!result.success || !result.data)
            throw new Error("Failed to fetch patient data");
          setPatient(result.data);
          setLoading(false);
        })
        .catch((error) => {
          console.error("Error fetching patient data:", error);
          setLoading(false);
        });
    } else {
      // Use first available patient if no ID specified
      if (patients.length > 0) {
        const randomPatient =
          patients[Math.floor(Math.random() * patients.length)];
        setPatient(randomPatient);
        setLoading(false);
      }
    }
  }, [patientId, getPatient, patients]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!patient) {
    return <div>Patient not found.</div>;
  }

  return (
    <div className="bg-gray-50 min-h-screen">
      <Header patientId={patientId} />
      <SessionReview />
      <Footer />
    </div>
  );
}
