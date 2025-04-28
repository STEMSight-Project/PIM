"use client";

import React, { useState } from "react";
import { MessageSquare } from "lucide-react";
import NoteForm from "./NoteForm";
import NotesList from "./NoteList";
import { NotesProps } from "./types";
import {
  createNote,
  updateNote,
  deleteNote,
  Note,
} from "@/services/noteService";

/**
 * For the notes tab, handling note creation via NoteForm and displaying/editing notes in NotesList.
 */
const Notes: React.FC<NotesProps> = ({
  notes,
  setNotes,
  setCurrentTimestamp,
  currentVideoTime,
  patientId,
  videoId,
}) => {
  const [newNote, setNewNote] = useState("");
  const [isAdding, setIsAdding] = useState(false);
  const [currentTime, setCurrentTime] = useState<number | undefined>(undefined);
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [editContent, setEditContent] = useState("");

  const handleUpdateTimestamp = async (noteId: string, newTime: number) => {
    await updateNote(noteId, { timestamp_seconds: newTime })
      .then((note) => {
        if (!note) throw new Error("Failed to update note");
        console.log("Note updated successfully:", note);
        setNotes(
          notes.map((n) => {
            if (n.id === noteId) {
              return { ...n, timestamp_seconds: newTime };
            }
            return note;
          })
        );
      })
      .catch((error) => {
        console.error("Error updating note:", error);
      });
  };

  // Add a new note
  const handleAddNote = async () => {
    if (newNote.trim() === "") return;

    const notePayload = {
      content: newNote,
      timestamp_seconds: currentTime,
      author: "d86f06ec-fd0a-42a7-872c-e8224a4b18f1",
      video_id: videoId,
      patient_id: patientId,
    };

    await createNote(notePayload).then((note) => {
      if (note) {
        setNotes([note, ...notes]);
        setNewNote("");
        setIsAdding(false);
        setCurrentTime(undefined);
      } else {
        console.error("Failed to create note");
      }
    });
  };

  // Start editing a note
  const handleEditNote = (note: Note) => {
    setEditingNoteId(note.id);
    setEditContent(note.content);
  };

  const handleSaveEdit = async (id: string) => {
    if (editContent.trim() === "") return;

    await updateNote(id, { content: editContent }).then((note) => {
      if (note) {
        setNotes(
          notes.map((note) =>
            note.id === id ? { ...note, content: editContent } : note
          )
        );
        setEditingNoteId(null);
        setEditContent("");
      } else {
        console.error("Failed to update note");
      }
    });
  };

  // Delete a note
  const handleDeleteNote = async (id: string) => {
    await deleteNote(id).then((note) => {
      if (note) {
        setNotes(notes.filter((note) => note.id !== id));
      } else {
        console.error("Failed to delete note");
      }
    });
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
