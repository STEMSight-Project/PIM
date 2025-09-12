"use client";

import React, { useState, useEffect } from "react";
import { useSessions, useNotes } from "@/hooks";

type Tab = "patients" | "sessions" | "view";

export const SessionReview: React.FC = () => {
  const [activeTab, setActiveTab] = useState<Tab>("patients");
  const [selectedPatient, setSelectedPatient] = useState<any>(null);

  const {
    sessions,
    loading: sessionsLoading,
    error: sessionsError,
    fetchStitchedSessions,
  } = useSessions();

  const {
    notes,
    loading: notesLoading,
    error: notesError,
    fetchNotesForPatient,
  } = useNotes();

  useEffect(() => {
    fetchStitchedSessions();
  }, [fetchStitchedSessions]);

  return (
    <div className="session-review">
      <h1>Session Review - Converted to Hooks</h1>
      <div>Active Tab: {activeTab}</div>
      <div>Sessions Loading: {sessionsLoading ? "Yes" : "No"}</div>
      <div>Sessions Count: {sessions?.length || 0}</div>
    </div>
  );
};

export default SessionReview;
