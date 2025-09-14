"use client";
import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert } from "@/components/ui/Alert";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Loading } from "@/components/ui/Loading";
import { usePatients, useStreaming } from "@/hooks";
import type { Patient } from "@/types";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, Maximize2 } from "lucide-react";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import ScriptLog from "./ScriptLog";

export default function StreamingDashPage() {
  const params = useSearchParams();
  const patientId =
    params.get("patientId") ?? "0cabaa76-b0cb-4785-ae2a-9b5e96739ae3";

  const [showLog, setShowLog] = useState(true);

  const {
    isConnected,
    isConnecting,
    error: streamingError,
    connectionQuality,
    videoRef,
    startStreaming,
    stopStreaming,
    clearError: clearStreamingError,
    toggleFullscreen,
  } = useStreaming();

  const { isLoading: loading, error, getPatient } = usePatients();

  const [patient, setPatient] = useState<Patient | null>(null);

  useEffect(() => {
    async function fetchPatientData() {
      if (patientId) {
        const result = await getPatient(patientId);
        if (result.success && result.data) {
          setPatient(result.data);
        }
      }
    }
    fetchPatientData();
  }, [patientId]);

  useEffect(() => {
    // Auto-start streaming when component mounts
    if (patientId) {
      startStreaming(patientId);
    }

    return () => {
      stopStreaming();
    };
  }, [patientId]);

  const handleStartStreaming = () => {
    clearStreamingError();
    startStreaming(patientId);
  };

  const handleStopStreaming = () => {
    stopStreaming();
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <Loading />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Live Stream</h1>
            <p className="text-gray-600">
              Viewing live stream for{" "}
              {patient
                ? `${patient.first_name} ${patient.last_name}`
                : patientId}
            </p>
          </div>

          <div className="flex items-center gap-3">
            {connectionQuality && (
              <div
                className={`px-3 py-1 rounded-full text-sm font-medium ${
                  connectionQuality === "excellent"
                    ? "bg-green-100 text-green-800"
                    : connectionQuality === "good"
                    ? "bg-blue-100 text-blue-800"
                    : connectionQuality === "fair"
                    ? "bg-yellow-100 text-yellow-800"
                    : "bg-red-100 text-red-800"
                }`}
              >
                {connectionQuality} connection
              </div>
            )}

            {isConnected ? (
              <Button onClick={handleStopStreaming} variant="outline">
                Stop Stream
              </Button>
            ) : (
              <Button
                onClick={handleStartStreaming}
                isLoading={isConnecting}
                disabled={isConnecting}
              >
                {isConnecting ? "Connecting..." : "Start Stream"}
              </Button>
            )}
          </div>
        </div>

        {(error || streamingError) && (
          <Alert variant="error">{error || streamingError}</Alert>
        )}

        <Card className="p-6">
          <div className="relative w-full aspect-video border-2 border-gray-200 rounded-lg overflow-hidden bg-black">
            <video
              ref={videoRef}
              className="w-full h-full"
              controls
              muted={false}
              autoPlay
              playsInline
            />

            {!isConnected && (
              <div className="absolute inset-0 flex items-center justify-center bg-gray-900 text-white">
                <div className="text-center">
                  {isConnecting ? (
                    <>
                      <Loading />
                      <p className="mt-2">Connecting to stream...</p>
                    </>
                  ) : (
                    <p>No video stream available</p>
                  )}
                </div>
              </div>
            )}

            <button
              onClick={toggleFullscreen}
              className="absolute top-3 right-3 bg-gray-800 text-white p-2 rounded-md hover:bg-gray-700 transition-colors"
            >
              <Maximize2 className="w-5 h-5" />
            </button>
          </div>
        </Card>

        {/* Log Panel */}
        <div className="fixed right-4 bottom-4 flex items-end gap-2 z-20">
          <motion.button
            onClick={() => setShowLog((prev) => !prev)}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
            className="bg-blue-600 text-white p-3 rounded-full shadow-lg hover:bg-blue-500 transition-colors"
          >
            {showLog ? <ArrowRight /> : <ArrowLeft />}
          </motion.button>

          <motion.div
            animate={{ x: showLog ? 0 : 300 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            className="w-96 h-96"
          >
            <Card className="h-full p-4 bg-gray-900 text-white">
              <h3 className="text-lg font-semibold mb-4">Analysis Log</h3>
              <div className="h-full overflow-hidden">
                <ScriptLog />
              </div>
            </Card>
          </motion.div>
        </div>
      </div>
    </DashboardLayout>
  );
}
