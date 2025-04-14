"use client";
import React, { useState, useEffect, useRef, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { Maximize2 } from "lucide-react"; // Fullscreen icon
import Header from "@/components/Header"; // Header component
import Footer from "@/components/Footer"; // Footer component

function Page() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<{
    first_name: string;
    last_name: string;
  } | null>(null);
  const [fullLogHistory, setFullLogHistory] = useState<string[]>([]);
  const [visibleLogsCount, setVisibleLogsCount] = useState(10);

  const videoContainerRef = useRef<HTMLDivElement>(null);
  // Use a canvas to draw JPEG frames
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Fetch patient details by ID
  useEffect(() => {
    if (patientId) {
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) throw new Error("Failed to fetch patient data");
          return response.json();
        })
        .then((data) => setPatient(data))
        .catch((error) => console.error("Error fetching patient data:", error));
    }
  }, [patientId]);

  // Function to generate random detection logs
  const generateRandomLog = () => {
    const events = [
      "Myoclonus detected",
      "Figure of four detected",
      "Fencer posture detected",
      "Decorticate posture detected",
      "Decerebrate posture detected",
      "Hemichorea detected",
      "Tremor detected",
      "Ballistic movements",
      "Versive head posture",
    ];
    const randomEvent = events[Math.floor(Math.random() * events.length)];
    const timestamp = new Date().toLocaleTimeString();
    return `🟡 ${timestamp} - ${randomEvent}`;
  };

  // Simulate adding logs every 5 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      const newLog = generateRandomLog();
      setFullLogHistory((prev) => [newLog, ...prev]);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // Setup the WebSocket for streaming JPEG frames and draw them on a canvas
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const context = canvas.getContext("2d");
    if (!context) return;

    const ws = new WebSocket(
      "ws://127.0.0.1:8000/video-streaming/watch/test_patient"
    );
    ws.binaryType = "arraybuffer";

    ws.onopen = () => {
      console.log("WebSocket connection opened for streaming.");
    };

    ws.onmessage = (event) => {
      // Create a Blob from the received ArrayBuffer with image/jpeg type
      const blob = new Blob([event.data], { type: "image/jpeg" });
      const url = URL.createObjectURL(blob);
      const img = new Image();

      img.onload = () => {
        // Clear the canvas and draw the new frame
        context.clearRect(0, 0, canvas.width, canvas.height);
        context.drawImage(img, 0, 0, canvas.width, canvas.height);
        // Release the object URL after image has loaded
        URL.revokeObjectURL(url);
      };
      img.src = url;
    };

    ws.onerror = (error) => {
      console.error("WebSocket error in streaming:", error);
    };

    ws.onclose = () => {
      console.log("WebSocket connection closed for streaming.");
    };

    return () => {
      ws.close();
    };
  }, []);

  const visibleLogs = fullLogHistory.slice(0, visibleLogsCount);

  // Fullscreen toggle function
  const toggleFullscreen = () => {
    if (videoContainerRef.current) {
      if (!document.fullscreenElement) {
        videoContainerRef.current
          .requestFullscreen()
          .catch((err) =>
            console.error(
              `Error attempting to enable fullscreen mode: ${err.message}`
            )
          );
      } else {
        document
          .exitFullscreen()
          .catch((err) =>
            console.error(
              `Error attempting to exit fullscreen mode: ${err.message}`
            )
          );
      }
    }
  };

  return (
    <div className="flex flex-col min-h-screen bg-black">
      <Header patientId={null} />

      <div className="flex flex-col items-center justify-center flex-grow">
        <p className="text-lg text-gray-300 mb-4">
          Viewing live stream for Patient:{" "}
          {patient
            ? `${patient.first_name} ${patient.last_name}`
            : "Loading..."}
        </p>

        <div
          ref={videoContainerRef}
          className="relative w-full max-w-5xl aspect-video border-4 border-gray-700 rounded-lg overflow-hidden"
        >
          <canvas ref={canvasRef} className="w-full h-full" />
          <button
            onClick={toggleFullscreen}
            className="absolute top-2 right-2 bg-gray-800 text-white p-2 rounded-md hover:bg-gray-700"
          >
            <Maximize2 className="w-5 h-5" />
          </button>

          <div className="absolute bottom-0 w-full backdrop-blur-md text-white p-4 text-sm max-h-48 overflow-y-auto">
            <h2 className="text-lg font-semibold">Detection Logs</h2>
            <ul className="text-xs">
              {visibleLogs.map((log, index) => (
                <li key={index}>{log}</li>
              ))}
            </ul>
            {visibleLogsCount < fullLogHistory.length && (
              <button
                onClick={() => setVisibleLogsCount((prev) => prev + 10)}
                className="mt-2 text-blue-400 hover:underline"
              >
                Load More
              </button>
            )}
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}

export default function StreamingDash() {
  return (
    <Suspense>
      <Page />
    </Suspense>
  );
}
