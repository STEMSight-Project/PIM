"use client";
import React, { useEffect, useRef, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Maximize2, ArrowLeft, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { getPatient } from "@/services/patientService";
import { createNewConnection } from "@/services/streamingVideoServices";
import ScriptLog from "./ScriptLog";

export default function Page() {
  const params = useSearchParams();
  const patientId = params.get("patientId") ?? "test_patient";

  const [patient, setPatient] = useState<{
    first_name: string;
    last_name: string;
  } | null>(null);
  const [showLog, setShowLog] = useState(true);

  const videoRef = useRef<HTMLVideoElement>(null);
  const pcRef = useRef<RTCPeerConnection | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    getPatient(patientId)
      .then((patient) => {
        if (patient) {
          setPatient({
            first_name: patient.first_name,
            last_name: patient.last_name,
          });
        }
      })
      .catch(console.error);
  }, [patientId]);

  useEffect(() => {
    const pc = new RTCPeerConnection({
      iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
    });

    pc.ontrack = (ev) => {
      if (videoRef.current) {
        videoRef.current.srcObject = ev.streams[0];
        videoRef.current
          .play()
          .catch((err) => console.error("Autoplay error:", err));
      }
    };

    pcRef.current = pc;
    createNewConnection(patientId, pc);
    return () => pcRef.current?.close();
  }, [patientId]);

  const toggleFS = () => {
    const el = containerRef.current;
    if (!el) return;
    document.fullscreenElement
      ? document.exitFullscreen()
      : el.requestFullscreen();
  };

  return (
    <div className="flex flex-col min-h-screen bg-black overflow-hidden">
      <Header patientId={null} />

      <main className="flex flex-1 flex-col items-center justify-center relative px-4 py-6">
        <p className="text-lg text-gray-300 mb-4 text-center">
          Viewing live stream for&nbsp;
          {patient ? `${patient.first_name} ${patient.last_name}` : patientId}
        </p>

        <div
          ref={containerRef}
          className="relative w-full max-w-5xl aspect-video border-4 border-gray-700 rounded-xl overflow-hidden shadow-lg"
        >
          <video
            ref={videoRef}
            className="w-full h-full bg-black"
            controls
            muted={false}
            autoPlay
            playsInline
          />

          <button
            onClick={toggleFS}
            className="absolute top-3 right-3 bg-gray-800 text-white p-2 rounded-md hover:bg-gray-700 z-10"
          >
            <Maximize2 className="w-5 h-5" />
          </button>
        </div>

        {/* Toggle button and log panel */}
        <div className="absolute right-0 bottom-4 flex items-end pr-4 gap-2 z-20">
          {/* Toggle button slides with log */}
          <motion.div
            animate={{ x: showLog ? 0 : 300 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
          >
            <motion.button
              onClick={() => setShowLog((prev) => !prev)}
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.95 }}
              className="bg-blue-600 text-white p-3 rounded-full shadow-md hover:bg-blue-500"
            >
              {showLog ? <ArrowRight /> : <ArrowLeft />}
            </motion.button>
          </motion.div>

          {/* ScriptLog always mounted — just slides in/out */}
          <motion.div
            animate={{ x: showLog ? 0 : 300 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            className="w-[22rem] max-w-[90vw] h-[32rem] bg-black/70 backdrop-blur-md text-white rounded-xl shadow-xl overflow-hidden"
            style={{
              pointerEvents: showLog ? "auto" : "none",
              opacity: showLog ? 1 : 0.3,
            }}
          >
            <ScriptLog />
          </motion.div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
