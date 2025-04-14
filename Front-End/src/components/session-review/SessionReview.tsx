"use client";

import React, { useState, useEffect } from "react";
import TabsContainer from "./Tabs/TabsContainer";
import VideoPlayer from "./VideoPlayer";
import SessionGallery from "./Gallery";
import SessionHeader from "./SessionHeader";

type Patient = {
  id: string;
  first_name: string;
  last_name: string;
};

interface SessionReviewProps {
  initialPatient?: Patient; // Make this optional
}

interface SessionData {
  id: string;
  stationId: string;
  patientId: string;
  sessionDate: string;
  startTime: string;
  endTime: string;
  thumbnailUrl?: string;
}

interface SessionWithPatient {
  session: SessionData;
  patient?: Patient;
}

const SessionReview: React.FC<SessionReviewProps> = ({ initialPatient }) => {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(true);
  const [sessions, setSessions] = useState<Record<string, SessionData>>({
    // Initial mock session data
    "session-123": {
      id: "session-123",
      stationId: "S-103",
      patientId: "28491",
      sessionDate: "March 17, 2025",
      startTime: "10:35 AM",
      endTime: "10:50 AM",
    },
    "session-124": {
      id: "session-124",
      stationId: "S-217",
      patientId: "28495",
      sessionDate: "March 17, 2025",
      startTime: "9:22 AM",
      endTime: "9:40 AM",
    },
    "session-125": {
      id: "session-125",
      stationId: "S-103",
      patientId: "28492",
      sessionDate: "March 17, 2025",
      startTime: "8:47 AM",
      endTime: "9:05 AM",
    },
    "session-126": {
      id: "session-126",
      stationId: "S-054",
      patientId: "28487",
      sessionDate: "March 16, 2025",
      startTime: "4:12 PM",
      endTime: "4:30 PM",
    },
    "session-127": {
      id: "session-127",
      stationId: "S-217",
      patientId: "28486",
      sessionDate: "March 16, 2025",
      startTime: "2:38 PM",
      endTime: "2:55 PM",
    },
    "session-128": {
      id: "session-128",
      stationId: "S-103",
      patientId: "28483",
      sessionDate: "March 16, 2025",
      startTime: "11:04 AM",
      endTime: "11:22 AM",
    },
    "session-129": {
      id: "session-129",
      stationId: "S-221",
      patientId: "28480",
      sessionDate: "March 15, 2025",
      startTime: "7:55 PM",
      endTime: "8:15 PM",
    },
    "session-130": {
      id: "session-130",
      stationId: "S-103",
      patientId: "28478",
      sessionDate: "March 15, 2025",
      startTime: "3:17 PM",
      endTime: "3:35 PM",
    },
    "session-131": {
      id: "session-131",
      stationId: "S-217",
      patientId: "28475",
      sessionDate: "March 15, 2025",
      startTime: "10:42 AM",
      endTime: "11:00 AM",
    },
    "session-132": {
      id: "session-132",
      stationId: "S-103",
      patientId: "28472",
      sessionDate: "March 14, 2025",
      startTime: "8:09 PM",
      endTime: "8:30 PM",
    },
  });

  const [sessionsWithPatients, setSessionsWithPatients] = useState<
    SessionWithPatient[]
  >([]);
  const [sessionId, setSessionId] = useState<string>("session-123");
  const [currentTimestamp, setCurrentTimestamp] = useState<number>(0);
  const [currentVideoTime, setCurrentVideoTime] = useState<number>(0);

  useEffect(() => {
    fetch("http://127.0.0.1:8000/patients/")
      .then((res) => res.json())
      .then((data: Patient[]) => {
        setPatients(data);

        // Randomly sample 10 patient IDs
        const sampledIds = data
          .sort(() => 0.5 - Math.random())
          .slice(0, 10)
          .map((p) => p.id);

        setSessions((prev) => {
          const updated = { ...prev };

          // Assign sampled IDs to mock sessions
          Object.entries(updated).forEach(([key], i) => {
            updated[key].patientId = sampledIds[i] || sampledIds[0];
          });

          // Override the first session with the initial patient, if provided
          if (initialPatient) {
            console.log(
              "Overriding first session with initial patient:",
              initialPatient.first_name,
              initialPatient.last_name
            );
            const firstSessionKey = Object.keys(updated)[0]; // Get the first session key
            if (firstSessionKey) {
              updated[firstSessionKey].patientId = initialPatient.id;
            }
          }

          return updated;
        });

        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching patients:", error);
        setLoading(false);
      });
  }, [initialPatient]);

  useEffect(() => {
    const merged = Object.values(sessions).map((session) => {
      const foundPatient = patients.find((p) => p.id === session.patientId);
      return { session, patient: foundPatient };
    });
    setSessionsWithPatients(merged);
  }, [patients, sessions]);

  useEffect(() => {
    if (initialPatient) {
      console.log(
        "Initial Patient:",
        initialPatient.first_name,
        initialPatient.last_name
      );

      const sessionWithInitialPatient = sessionsWithPatients.find(
        (sp) => sp.patient?.id === initialPatient.id
      );
      if (sessionWithInitialPatient) {
        setSessionId(sessionWithInitialPatient.session.id);
      }
    } else if (sessionsWithPatients.length > 0) {
      // Randomly select a patient if no initialPatient is provided
      const randomSession =
        sessionsWithPatients[
          Math.floor(Math.random() * sessionsWithPatients.length)
        ];
      if (randomSession) {
        console.log(
          "Randomly selected patient:",
          randomSession.patient?.first_name,
          randomSession.patient?.last_name
        );
        setSessionId(randomSession.session.id);
      }
    }
  }, [initialPatient, sessionsWithPatients]);

  const currentSessionObj = sessionsWithPatients.find(
    (sp) => sp.session.id === sessionId
  );
  const currentSession = currentSessionObj?.session;
  const currentPatient = currentSessionObj?.patient;

  const handleTimeUpdate = (time: number) => {
    setCurrentVideoTime(time);
  };

  const handleSessionSelect = (selectedId: string) => {
    setSessionId(selectedId);
    setCurrentTimestamp(0);
    setCurrentVideoTime(0);
  };

  return (
    <div className="container mx-auto bg-gray-50 p-6 min-h-screen">
      {currentSession && (
        <SessionHeader
          stationId={currentSession.stationId}
          patientId={
            currentPatient
              ? `${currentPatient.first_name} ${currentPatient.last_name}`
              : currentSession.patientId
          }
          sessionDate={currentSession.sessionDate}
          startTime={currentSession.startTime}
          endTime={currentSession.endTime}
        />
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <VideoPlayer
            currentTimestamp={currentTimestamp}
            onTimeUpdate={handleTimeUpdate}
          />
          <TabsContainer
            sessionId={sessionId}
            setCurrentTimestamp={setCurrentTimestamp}
            currentVideoTime={currentVideoTime}
          />
        </div>
        <div className="space-y-6">
          <SessionGallery onSessionSelect={handleSessionSelect} />
        </div>
      </div>

      {loading && <p>Loading patients...</p>}
    </div>
  );
};

export default SessionReview;
