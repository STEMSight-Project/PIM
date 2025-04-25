import { fetchData, postData, deleteData, ApiResponse } from './api';

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
export async function getNotesForPatient(patientId: string): Promise<ApiResponse<Note[]>> {
  return fetchData<Note[]>(`/note/patient/${patientId}`);
}

// get notes for a specific video id
export async function getNotesForVideo(videoId: string): Promise<ApiResponse<Note[]>> {
  return fetchData<Note[]>(`/note/video/${videoId}`);
}

// create new note
export async function createNote(note: Omit<Note, 'id' | 'created_at' | 'updated_at'>): Promise<ApiResponse<Note>> {
  return postData<Note>('/note/', note);
}

// update note
export async function updateNote(noteId: string, note: Partial<Omit<Note, 'id' | 'created_at' | 'updated_at'>>): Promise<ApiResponse<Note>> {
  return postData<Note>(`/note/${noteId}`, note);
}

// delete note
export async function deleteNote(noteId: string): Promise<ApiResponse<{ message: string }>> {
    return deleteData<{ message: string }>(`/note/${noteId}`);
}