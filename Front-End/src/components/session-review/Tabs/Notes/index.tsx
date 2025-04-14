"use client";

import React, { useState } from "react";
import { MessageSquare } from "lucide-react";
import NoteForm from "./NoteForm";
import NotesList from "./NoteList";
import { Note, NotesProps } from "./types";

/**
 * For the notes tab, handling note creation via NoteForm and displaying/editing notes in NotesList.
 */
const Notes: React.FC<NotesProps> = ({
  setCurrentTimestamp,
  currentVideoTime,
}) => {
  // Mock data for notes with timestamps
  const [notes, setNotes] = useState<Note[]>([
    {
      id: "1",
      content:
        "Patient was agitated during transport which could affect detection accuracy. However, the decerebrate posturing is clearly visible in the video and consistent with potential brainstem involvement. Tremor detection appears accurate and may indicate extension of the ischemic area. Recommend immediate CT upon arrival, with neurology consultation and preparation for potential thrombectomy.",
      created_time: "10:30 AM",
      videoTimeSeconds: 45, // 0:45 timestamp
      author: "Dr. Sarah Johnson",
      created_at: new Date().toISOString(),
    },
    {
      id: "2",
      content:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
      created_time: "10:35 AM",
      videoTimeSeconds: 120, // 2:00 timestamp
      author: "Dr. Sarah Johnson",
      created_at: new Date().toISOString(),
    },
  ]);

  const [newNote, setNewNote] = useState("");
  const [isAdding, setIsAdding] = useState(false);
  const [currentTime, setCurrentTime] = useState<number | undefined>(undefined);
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [editContent, setEditContent] = useState("");

  const handleUpdateTimestamp = (noteId: string, newTime: number) => {
    setNotes(
      notes.map((note) =>
        note.id === noteId ? { ...note, videoTimeSeconds: newTime } : note
      )
    );
  };

  // Add a new note
  const handleAddNote = () => {
    if (newNote.trim() === "") return;

    const now = new Date();
    const newNoteObj: Note = {
      id: `note-${Date.now()}`,
      content: newNote,
      created_time: now.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      }),
      videoTimeSeconds: currentTime,
      author: "Dr. Sarah Johnson",
      created_at: now.toISOString(),
    };

    setNotes([newNoteObj, ...notes]);
    setNewNote("");
    setIsAdding(false);
    setCurrentTime(undefined);
  };

  // Start editing a note
  const handleEditNote = (note: Note) => {
    setEditingNoteId(note.id);
    setEditContent(note.content);
  };

  // Save edited note
  const handleSaveEdit = (id: string) => {
    if (editContent.trim() === "") return;

    setNotes(
      notes.map((note) =>
        note.id === id ? { ...note, content: editContent } : note
      )
    );

    setEditingNoteId(null);
    setEditContent("");
  };

  // Delete a note
  const handleDeleteNote = (id: string) => {
    setNotes(notes.filter((note) => note.id !== id));
  };

  // Cancel form
  const handleCancelForm = () => {
    setIsAdding(false);
    setNewNote("");
    setCurrentTime(undefined);
  };

  // Cancel edit
  const handleCancelEdit = () => {
    setEditingNoteId(null);
    setEditContent("");
  };

  // Debug function to help troubleshoot
  const handleJumpToTimestamp = (time: number) => {
    console.log("Notes component: Jumping to timestamp", time);
    setCurrentTimestamp(time);
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-medium text-gray-800">Session Notes</h3>
        <button
          className="px-3 py-1.5 bg-blue-600 text-white rounded text-sm hover:bg-blue-700 flex items-center"
          onClick={() => setIsAdding(!isAdding)}
        >
          <MessageSquare className="w-4 h-4 mr-2" />
          Add Note
        </button>
      </div>

      {/* Add note form */}
      {isAdding && (
        <NoteForm
          newNote={newNote}
          setNewNote={setNewNote}
          currentTime={currentTime}
          setCurrentTime={setCurrentTime}
          currentVideoTime={currentVideoTime}
          onCancel={handleCancelForm}
          onSave={handleAddNote}
          onUpdateTimestamp={handleUpdateTimestamp}
        />
      )}

      {/* Notes list */}
      <NotesList
        notes={notes}
        editingNoteId={editingNoteId}
        editContent={editContent}
        setEditContent={setEditContent}
        onEdit={handleEditNote}
        onSaveEdit={handleSaveEdit}
        onDelete={handleDeleteNote}
        setCurrentTimestamp={handleJumpToTimestamp}
        onCancelEdit={handleCancelEdit}
        currentVideoTime={currentVideoTime}
        onUpdateTimestamp={handleUpdateTimestamp}
      />
    </div>
  );
};

export default Notes;
