import React from "react";
import NoteItem from "./NoteItem";
import { Note } from "@/hooks";

/*
    Renders the list of notes that can be created, updated, and deleted passes the props to the NoteItem
*/
interface NotesListProps {
  notes: Note[];
  editingNoteId: string | null;
  editContent: string;
  setEditContent: (content: string) => void;
  onEdit: (note: Note) => void;
  onSaveEdit: (id: string) => void;
  onDelete: (id: string) => void;
  setCurrentTimestamp: (time: number) => void;
  onCancelEdit: () => void;
  currentVideoTime: number;
  onUpdateTimestamp: (id: string, newTime: number) => void;
}

const NotesList: React.FC<NotesListProps> = ({
  notes,
  editingNoteId,
  editContent,
  setEditContent,
  onEdit,
  onSaveEdit,
  onDelete,
  setCurrentTimestamp,
  onCancelEdit,
  currentVideoTime,
  onUpdateTimestamp,
}) => {
  // display a message if there are no notes
  if (notes.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
          <svg
            className="w-8 h-8 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={1.5}
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            />
          </svg>
        </div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">No notes yet</h3>
        <p className="text-gray-500 max-w-sm mx-auto">
          Start adding notes to keep track of important moments in this session.
        </p>
      </div>
    );
  }
  // map over notes array and render the NoteItem for each note
  return (
    <div className="space-y-4">
      {notes.map((note) => (
        <NoteItem
          key={note.id}
          note={note}
          isEditing={editingNoteId === note.id}
          editContent={editContent}
          setEditContent={setEditContent}
          onEdit={onEdit}
          onSaveEdit={onSaveEdit}
          onDelete={onDelete}
          setCurrentTimestamp={setCurrentTimestamp}
          onCancelEdit={onCancelEdit}
          onUpdateTimestamp={onUpdateTimestamp}
          currentVideoTime={currentVideoTime}
        />
      ))}
    </div>
  );
};

export default NotesList;
