import React from 'react';
import NoteItem from './NoteItem';
import { Note } from './types';

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
    onUpdateTimestamp
}) => {
    // display a message if there are no notes 
    if (notes.length === 0) {
        return (
            <div className="text-center py-8 text-gray-500">
                No notes for this session. Add one to get started.
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