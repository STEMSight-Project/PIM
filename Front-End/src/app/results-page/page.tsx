"use client";

import { useState, useEffect } from "react";
import "./styles.css"; // Import the styles.css file

interface EventData {
  time: string;
  symptom: string;
  video: string;
  wireframe: string;
  strokeRisk: string;
}

export default function Page() {
  const [currentTime, setCurrentTime] = useState<string>("");
  const [events, setEvents] = useState<EventData[]>([]);

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

  return (
    <div>
      <h1 className="title">Summary Analysis</h1>
      <p>{currentTime}</p>

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
    </div>
  );
}
