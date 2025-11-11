"use client";

import type { Note } from "@/services";
import { noteService } from "@/services";
import { useCallback, useState } from "react";

// Re-export Note interface for backward compatibility
export type { Note };

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
      const response = await noteService.getByPatientId(patientId);
      setNotes(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch patient notes";
      setError(message);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchNotesForVideo = useCallback(async (videoId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await noteService.getByVideoId(videoId);
      setNotes(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch video notes";
      setError(message);
    } finally {
      setLoading(false);
    }
  }, []);

  const createNote = useCallback(
    async (data: CreateNoteRequest): Promise<Note | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await noteService.create(data);
        if (response.data) {
          setNotes((prev) => [response.data!, ...prev]); // Add new note to the top
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to create note";
        setError(message);
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
        const response = await noteService.update(id, data);
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
        const response = await noteService.delete(id);
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
