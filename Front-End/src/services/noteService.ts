import { api } from "./api";

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

// get notes for a specific patient id
export async function getNotesForPatient(patientId: string): Promise<Note[]> {
  return await api.get(`/note/patient/${patientId}`);
}

// get notes for a specific video id
export async function getNotesForVideo(videoId: string): Promise<Note[]> {
  return await api.get(`/note/video/${videoId}`);
}

// create new note
export async function createNote(
  note: Omit<Note, "id" | "created_at" | "updated_at">
): Promise<Note> {
  return await api.post<Note>("/note/", note);
}

// update note
export async function updateNote(
  noteId: string,
  note: Partial<Omit<Note, "id" | "created_at" | "updated_at">>
): Promise<Note> {
  return await api.post<Note>(`/note/${noteId}`, note);
}

// delete note
export async function deleteNote(noteId: string): Promise<{ message: string }> {
  return await api.delete<{ message: string }>(`/note/${noteId}`);
}
