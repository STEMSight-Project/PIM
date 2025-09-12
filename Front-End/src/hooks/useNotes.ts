"use client";

import { useState, useCallback } from "react";
import { api } from "@/services/api";

export interface Note {
  id: string;
  created_at: string;
  content: string;
  patient_id: string;
  video_id?: string;
  author: string;
  timestamp_seconds?: number;
  updated_at?: string;
}

interface CreateNoteRequest {
  content: string;
  patient_id: string;
  video_id?: string;
  author: string;
  timestamp_seconds?: number;
}

interface UpdateNoteRequest {
  content?: string;
  author?: string;
  timestamp_seconds?: number;
}

interface UseNotesReturn {
  notes: Note[];
  selectedNote: Note | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchNotesForPatient: (patientId: string) => Promise<void>;
  fetchNotesForVideo: (videoId: string) => Promise<void>;
  createNote: (data: CreateNoteRequest) => Promise<Note | null>;
  updateNote: (id: string, data: UpdateNoteRequest) => Promise<Note | null>;
  deleteNote: (id: string) => Promise<boolean>;
  clearError: () => void;
  setSelectedNote: (note: Note | null) => void;
  clearNotes: () => void;
}

export function useNotes(): UseNotesReturn {
  const [notes, setNotes] = useState<Note[]>([]);
  const [selectedNote, setSelectedNote] = useState<Note | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const clearNotes = useCallback(() => {
    setNotes([]);
    setSelectedNote(null);
  }, []);

  const fetchNotesForPatient = useCallback(async (patientId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Note[]>(`/note/patient/${patientId}`);
      setNotes(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch patient notes";
      setError(message);
      console.error("Error fetching patient notes:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchNotesForVideo = useCallback(async (videoId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Note[]>(`/note/video/${videoId}`);
      setNotes(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch video notes";
      setError(message);
      console.error("Error fetching video notes:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const createNote = useCallback(
    async (data: CreateNoteRequest): Promise<Note | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.post<Note>("/note/", data);
        if (response.data) {
          setNotes((prev) => [response.data!, ...prev]); // Add new note to the top
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to create note";
        setError(message);
        console.error("Error creating note:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const updateNote = useCallback(
    async (id: string, data: UpdateNoteRequest): Promise<Note | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.patch<Note>(`/note/${id}`, data);
        if (response.data) {
          setNotes((prev) =>
            prev.map((note) => (note.id === id ? response.data! : note))
          );
          if (selectedNote?.id === id) {
            setSelectedNote(response.data);
          }
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to update note";
        setError(message);
        console.error("Error updating note:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [selectedNote]
  );

  const deleteNote = useCallback(
    async (id: string): Promise<boolean> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.delete(`/note/${id}`);
        if (!response.error) {
          setNotes((prev) => prev.filter((note) => note.id !== id));
          if (selectedNote?.id === id) {
            setSelectedNote(null);
          }
          return true;
        }
        return false;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to delete note";
        setError(message);
        console.error("Error deleting note:", err);
        return false;
      } finally {
        setLoading(false);
      }
    },
    [selectedNote]
  );

  return {
    notes,
    selectedNote,
    loading,
    error,
    fetchNotesForPatient,
    fetchNotesForVideo,
    createNote,
    updateNote,
    deleteNote,
    clearError,
    setSelectedNote,
    clearNotes,
  };
}
