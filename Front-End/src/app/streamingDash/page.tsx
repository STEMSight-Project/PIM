"use client";
import React, { useState, useEffect, useRef } from "react";
import { useSearchParams } from "next/navigation";
import { Maximize2 } from "lucide-react"; // Import the fullscreen icon from Lucide
import Header from "@/components/Header"; // Import the Header component
import Footer from "@/components/Footer"; // Import the Footer component

export default function StreamingDash() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId");

  const [patient, setPatient] = useState<{ first_name: string; last_name: string } | null>(null);
  const [fullLogHistory, setFullLogHistory] = useState<string[]>([]); // All logs
  const [visibleLogsCount, setVisibleLogsCount] = useState(10); // Number of logs to display
  const videoContainerRef = useRef<HTMLDivElement>(null); // Reference to the video container

  // Fetch patient details by ID
  useEffect(() => {
    if (patientId) {
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) {
            throw new Error("Failed to fetch patient data");
          }
          return response.json();
        })
        .then((data) => {
          setPatient(data);
        })
        .catch((error) => {
          console.error("Error fetching patient data:", error);
        });
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
      "tremor detector",
      "ballistic movements",
      "versive head posture"// Example of a random event
    ];
    const randomEvent = events[Math.floor(Math.random() * events.length)];
    const timestamp = new Date().toLocaleTimeString();
    return `🟡 ${timestamp} - ${randomEvent}`;
  };

  // Simulate adding logs every 5 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      const newLog = generateRandomLog();

      // Update fullLogHistory
      setFullLogHistory((prevHistory) => [newLog, ...prevHistory]);
    }, 5000);

    return () => clearInterval(interval); // Cleanup interval on component unmount
  }, []);

  // Get the visible logs based on the visibleLogsCount
  const visibleLogs = fullLogHistory.slice(0, visibleLogsCount);

  // Function to toggle fullscreen mode
  const toggleFullscreen = () => {
    if (videoContainerRef.current) {
      if (!document.fullscreenElement) {
        videoContainerRef.current.requestFullscreen().catch((err) => {
          console.error(`Error attempting to enable fullscreen mode: ${err.message}`);
        });
      } else {
        document.exitFullscreen().catch((err) => {
          console.error(`Error attempting to exit fullscreen mode: ${err.message}`);
        });
      }
    }
  };

  return (
    <div className="flex flex-col min-h-screen bg-black">
      {/* Header */}
      <Header />

      {/* Main Content */}
      <div className="flex flex-col items-center justify-center flex-grow">
        {/* Title */}
        <p className="text-lg text-gray-300 mb-4">
          Viewing live stream for Patient:{" "}
          {patient ? `${patient.first_name} ${patient.last_name}` : "Loading..."}
        </p>

        {/* Video Container */}
        <div
          ref={videoContainerRef}
          className="relative w-full max-w-5xl aspect-video border-4 border-gray-700 rounded-lg overflow-hidden"
        >
          {/* Live Video Stream */}
          <img
            src="http://127.0.0.1:8080/video_feed"
            alt="Live Stream"
            className="w-full h-full object-cover"
          />

          {/* Fullscreen Button */}
          <button
            onClick={toggleFullscreen}
            className="absolute top-2 right-2 bg-gray-800 text-white p-2 rounded-md hover:bg-gray-700"
          >
            <Maximize2 className="w-5 h-5" /> {/* Fullscreen icon */}
          </button>

          {/* Detection Logs (Transparent Overlay) */}
          <div className="absolute bottom-0 w-full backdrop-blur-md text-white p-4 text-sm max-h-48 overflow-y-auto">
            <h2 className="text-lg font-semibold">Detection Logs</h2>
            <ul className="text-xs">
              {visibleLogs.map((log, index) => (
                <li key={index}>{log}</li>
              ))}
            </ul>
            {/* Load More Button */}
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

      {/* Footer */}
      <Footer />
    </div>
  );
}
