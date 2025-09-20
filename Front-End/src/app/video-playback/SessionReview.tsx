"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import SessionReview from "@/components/session-review/SessionReview";
import { Card, CardContent } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { usePatients } from "@/hooks";
import type { Patient } from "@/types";
import { useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState } from "react";

function SessionReviewPageContent() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const {
    patients,
    getPatient,
    isLoading: patientsLoading,
    error: patientsError,
    fetchPatients,
  } = usePatients();//-

  useEffect(() => {
    let isMounted = true;

    const fetchPatientData = async () => {
      if (patientsLoading) return; //-
      try {
        setLoading(true);
        setError(null);

        //-
        if (patientsError) {
          if (isMounted) setError(patientsError);
          return;
        }

        if (patientId) {
          const result = await getPatient(patientId);
          if (!result.success || !result.data) {
            throw new Error(result.error || "Failed to fetch patient data");
          }
          if (isMounted) setPatient(result.data);
        } else {
          if (patients.length > 0) {
            if (isMounted) setPatient(patients[0]);
          } else {
            throw new Error("No patients available");
          }
        }
      } catch (err) {
        console.error("Error fetching patient data:", err);
        if (isMounted)
          setError(err instanceof Error ? err.message : "An error occurred");
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    fetchPatientData();
    return () => {
      isMounted = false;
    };
    // Include hook outputs in deps to satisfy linters and avoid stale reads
  }, [patientId, patientsLoading, patientsError, patients, getPatient]);

  if (loading || patientsLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loading size="lg" text="Loading session data..." />
      </div>
    );
  }

  if (error || !patient) {
    return (
      <div className="px-4">
        <Card className="max-w-md mx-auto">
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="w-16 h-16 mx-auto mb-4 bg-red-100 rounded-full flex items-center justify-center">
                {/* error icon */}
                <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                {error ? "Error Loading Patient" : "Patient Not Found"}
              </h3>
              <p className="text-gray-600 mb-4">
                {error || "The requested patient could not be found or accessed."}
              </p>
              <button
  onClick={() => {
    setError(null);
    setLoading(true);
    fetchPatients(); // this will flip patientsLoading and re-run the effect
  }}
  className="inline-flex items-center px-4 py-2 rounded-md text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
>
  Try Again
</button>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <>
      {/* Page header (kept inside content area) */}
      <div className="bg-white border-b border-gray-200 shadow-sm">
        {/* ... your existing header markup that uses patient ... */}
      </div>

      {/* Main Content: suspend JUST the heavy viewer */}
      <main className="flex-grow">
        <Suspense fallback={<div className="p-8"><Loading size="lg" text="Loading session review..." /></div>}>
          <SessionReview />
        </Suspense>
      </main>
    </>
  );
}

export default function SessionReviewPage() {
  // Layout always visible; no flicker
  return (
    <DashboardLayout>
      <SessionReviewPageContent />
    </DashboardLayout>
  );
}
