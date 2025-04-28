"use client";
import React, { useState, useEffect } from "react";
import TabsContainer from "./Tabs/TabsContainer";
import VideoPlayer from "./VideoPlayer";
import SessionGallery from "./Gallery";
import SessionHeader from "./SessionHeader";
import { fetchStitchedSessions } from "@/services/sessionService";
import { Note, getNotesForVideo } from "@/services/noteService";
import { Patient, SessionWithPatient } from "./types";

interface SessionReviewProps {
  initialPatient?: Patient;
}

const SessionReview: React.FC<SessionReviewProps> = ({ initialPatient }) => {
  const [loading, setLoading] = useState(true);

  const [sessionsWithPatients, setSessionsWithPatients] = useState<
    SessionWithPatient[]
  >([]);
  const [sessionId, setSessionId] = useState<string>("session-123");
  const [currentTimestamp, setCurrentTimestamp] = useState<number>(0);
  const [currentVideoTime, setCurrentVideoTime] = useState<number>(0);
  const [notes, setNotes] = useState<Note[]>([]);

  useEffect(() => {
    fetchStitchedSessions()
      .then((data) => {
        setSessionsWithPatients(data);
        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching session data:", error);
        setLoading(false);
      });
  }, []);

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
  const selectedVideo = currentSession?.videos?.[0] || null;
  useEffect(() => {
    if (selectedVideo?.id) {
      getNotesForVideo(selectedVideo.id).then((notes) => {
        if (notes) {
          setNotes(notes);
        } else {
          setNotes([]);
        }
      });
    }
  }, [selectedVideo]);

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
            videoUrl={selectedVideo?.public_video_url || null}
            currentTimestamp={currentTimestamp}
            onTimeUpdate={handleTimeUpdate}
          />
          <TabsContainer
            sessionId={sessionId}
            setCurrentTimestamp={setCurrentTimestamp}
            currentVideoTime={currentVideoTime}
            notes={notes}
            setNotes={setNotes}
            videoId={selectedVideo?.id || ""}
            patientId={currentPatient?.id || currentSession?.patientId || ""}
          />
        </div>
        <div className="space-y-6">
          <SessionGallery
            sessions={sessionsWithPatients}
            selectedSessionId={sessionId}
            onSessionSelect={handleSessionSelect}
          />
        </div>
      </div>

      {loading && <p>Loading patients...</p>}
    </div>
  );
};

export default SessionReview;
