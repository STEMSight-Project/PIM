"use client";
import { useEffect, useState } from "react";

type Patient = {
  id: number;
  name: string;
  isLive: boolean; // Determines the live/offline status
  lastSeen: string;
  stationNumber?: number; // Optional station number field
};

export default function PatientDashboard() {
  const [patients, setPatients] = useState<Patient[]>([]);

  // Fetch mock patient data
  useEffect(() => {
    const mockPatients: Patient[] = [
      {
        id: 1,
        name: "John Doe",
        isLive: true,
        lastSeen: "2025-03-16T12:34:56",
        stationNumber: 101,
      },
      {
        id: 2,
        name: "Jane Smith",
        isLive: false,
        lastSeen: "2025-03-15T18:00:00",
      },
      {
        id: 3,
        name: "Robert Brown",
        isLive: true,
        lastSeen: "2025-03-16T14:22:11",
        stationNumber: 102,
      },
      {
        id: 4,
        name: "Emily Johnson",
        isLive: false,
        lastSeen: "2025-03-14T10:05:45",
      },
      {
        id: 5,
        name: "Michael Davis",
        isLive: true,
        lastSeen: "2025-03-16T08:50:30",
        stationNumber: 103,
      },
      {
        id: 6,
        name: "Sophia Wilson",
        isLive: false,
        lastSeen: "2025-03-13T16:30:10",
      },
      {
        id: 7,
        name: "William Lee",
        isLive: true,
        lastSeen: "2025-03-16T11:12:00",
        stationNumber: 104,
      },
    ];

    setPatients(mockPatients);
  }, []);

  // Separate active and inactive patients
  const activePatients = patients.filter((patient) => patient.isLive);
  const inactivePatients = patients.filter((patient) => !patient.isLive);

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <div className="max-w-4xl mx-auto bg-white shadow-lg rounded-lg p-6">
        <h1 className="text-2xl font-bold mb-4">
          🩺 Patient Monitoring Dashboard
        </h1>

        {/* Active Patients (Live) */}
        <div>
          <h2 className="text-xl font-semibold mb-4">🟢 Active Patients</h2>
          <ul className="space-y-3">
            {activePatients.length > 0 ? (
              activePatients.map((patient) => (
                <PatientCard key={patient.id} patient={patient} />
              ))
            ) : (
              <p className="text-gray-500 text-center">
                No active patients under observation.
              </p>
            )}
          </ul>
        </div>

        {/* Inactive Patients (Recorded) */}
        <div className="mt-6">
          <h2 className="text-xl font-semibold mb-4">⚪ Inactive Patients</h2>
          <ul className="space-y-3">
            {inactivePatients.length > 0 ? (
              inactivePatients.map((patient) => (
                <PatientCard key={patient.id} patient={patient} />
              ))
            ) : (
              <p className="text-gray-500 text-center">No inactive patients.</p>
            )}
          </ul>
        </div>
      </div>
    </div>
  );
}

const PatientCard = ({ patient }: { patient: Patient }) => {
  // Get the current date in a readable format (e.g., March 16, 2025)
  const currentDate = new Date().toLocaleDateString();

  return (
    <li className="flex items-center justify-between p-4 bg-gray-50 rounded-lg shadow-sm hover:bg-gray-100 transition">
      {/* Live Indicator */}
      <div className="flex items-center space-x-3">
        <div
          className={`w-4 h-4 rounded-full ${
            patient.isLive ? "bg-green-600 animate-pulse" : "bg-red-500"
          }`}
          aria-hidden="true"
        />
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            {patient.name}
            {/* Display station number for live patients */}
            {patient.isLive && patient.stationNumber && (
              <span className="ml-2 text-sm text-gray-500">
                Station: {patient.stationNumber}
              </span>
            )}
          </h3>
          <p className="text-gray-600 text-sm">
            {patient.isLive
              ? `Current Date: ${currentDate}`
              : `Recorded On: ${patient.lastSeen}`}
          </p>
        </div>
      </div>

      {/* Dummy Link to medical history */}
      <a
        href="#"
        onClick={(e) => {
          e.preventDefault(); // Prevents the default link action
          alert(`Viewing medical history for ${patient.name}`);
        }}
        className="text-blue-600 hover:underline text-sm mt-2"
      >
        View Patient Medical History
      </a>

      {/* Access Playback Recording Button for Inactive Patients */}
      {!patient.isLive && (
        <button
          onClick={() =>
            alert(`Accessing playback recording for ${patient.name}`)
          }
          className="ml-4 px-4 py-2 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600"
        >
          Access Playback Recording
        </button>
      )}
    </li>
  );
};
