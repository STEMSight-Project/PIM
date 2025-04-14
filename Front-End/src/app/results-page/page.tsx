"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation"; // To get query parameters
import "./styles.css"; // Import the styles.css file
import Header from "@/components/Header"; // Import the Header component
import Footer from "@/components/Footer"; // Import the Footer component

interface EventData {
  time: string;
  symptom: string;
  video: string;
  wireframe: string;
  strokeRisk: string;
}

interface Patient {
  id: string;
  first_name: string;
  last_name: string;
}

function Page() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId"); // Retrieve the patientId from the URL

  const [currentTime, setCurrentTime] = useState<string>("");
  const [events, setEvents] = useState<EventData[]>([]);
  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  // Fetch patient details based on patientId
  useEffect(() => {
    if (patientId) {
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) {
            throw new Error("Failed to fetch patient data");
          }
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

  // Update time every second
  useEffect(() => {
    const updateTime = () => setCurrentTime(new Date().toUTCString());
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  // Populate table with dummy data
  useEffect(() => {
    const dummyData: EventData[] = [
      {
        time: "2025-03-30 10:00:00",
        symptom: "Myoclonus detected",
        video: "https://via.placeholder.com/100", // Placeholder image
        wireframe: "https://via.placeholder.com/100", // Placeholder image
        strokeRisk: "Low",
      },
      {
        time: "2025-03-30 10:05:00",
        symptom: "Fencer posture detected",
        video: "https://via.placeholder.com/100", // Placeholder image
        wireframe: "https://via.placeholder.com/100", // Placeholder image
        strokeRisk: "Moderate",
      },
      {
        time: "2025-03-30 10:10:00",
        symptom: "Decorticate posture detected",
        video: "https://via.placeholder.com/100", // Placeholder image
        wireframe: "https://via.placeholder.com/100", // Placeholder image
        strokeRisk: "High",
      },
    ];
    setEvents(dummyData);
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!patientId || !patient) {
    return <div>Patient not found.</div>;
  }

  return (
    <div className="min-h-screen flex flex-col">
      <Header patientId={null} /> {/* Add the Header component */}
      <main className="flex-grow p-6">
        <h1 className="title">Summary Analysis</h1>
        <p>{currentTime}</p>

        {/* Display the patient's name */}
        <h2>
          Showing results for patient: {patient.first_name} {patient.last_name}
        </h2>

        <table>
          <thead>
            <tr>
              <th>Time</th>
              <th>Symptom</th>
              <th>Video View</th>
              <th>Wire Frame View</th>
              <th>Indicative of Stroke?</th>
            </tr>
          </thead>
          <tbody>
            {events.map((event, index) => (
              <tr key={index}>
                <td>{event.time}</td>
                <td>{event.symptom}</td>
                <td>
                  <img
                    src={event.video}
                    alt={`Video at ${event.time}`}
                    width="100"
                  />
                </td>
                <td>
                  <img
                    src={event.wireframe}
                    alt={`Wireframe at ${event.time}`}
                    width="100"
                  />
                </td>
                <td>{event.strokeRisk}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </main>
      <Footer /> {/* Add the Footer component */}
    </div>
  );
}

export default function ResultPage() {
  return (
    <Suspense>
      <Page />
    </Suspense>
  );
}
