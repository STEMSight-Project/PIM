"use client";

import React, { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import SessionReview from "@/components/session-review/SessionReview";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

interface Patient {
  id: string;
  first_name: string;
  last_name: string;
}

function SessionReviewView() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (patientId) {
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) throw new Error("Failed to fetch patient data");
          return response.json();
        })
        .then((data: Patient) => {
          setPatient(data);
          setLoading(false);
        })
        .catch((error) => {
          console.error("Error fetching patient data:", error);
          setLoading(false);
        });
    } else {
      setLoading(false);
    }
  }, [patientId]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!patientId || !patient) {
    return <div>Patient not found.</div>;
  }

  return (
    <div className="bg-gray-50 min-h-screen">
      <Header patientId={null} />
      <SessionReview initialPatient={patient} />
      <Footer />
    </div>
  );
}

export default function SessionReviewPage() {
  return (
    <Suspense>
      <SessionReviewView />
    </Suspense>
  );
}
