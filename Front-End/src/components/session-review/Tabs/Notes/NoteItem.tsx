import React from 'react';
import { Edit3, Clock, CheckCircle, Trash2 } from 'lucide-react';
import { createNote, updateNote, deleteNote, Note } from "@/services/noteService";

interface NoteItemProps {
    note: Note;
    isEditing: boolean;
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

const NoteItem: React.FC<NoteItemProps> = ({
    note,
    isEditing,
    editContent,
    setEditContent,
    onEdit,
    onSaveEdit,
    onDelete,
    setCurrentTimestamp,
    onCancelEdit,
    onUpdateTimestamp,
    currentVideoTime
}) => {
    const handleJumpToTimestamp = () => {
        if (note.timestamp_seconds !== undefined) {
            const timeSeconds = note.timestamp_seconds; // store the value in a local variable
            console.log("NoteItem: Jump to timestamp clicked", timeSeconds);

            // first set to a slightly different time to allow re-clicking the same timestamp
            setCurrentTimestamp(timeSeconds - 0.5);

            // then set to the actual time after a brief delay
            setTimeout(() => {
                setCurrentTimestamp(timeSeconds);
            }, 10);
        } else {
            console.warn("NoteItem: Cannot jump to timestamp - note has no timestamp");
        }
    };

    return (
        <div
            className={`p-4 rounded-lg border bg-blue-50 border-blue-200`}
        >
            {isEditing ? (
                <div className="space-y-2">
                    <textarea
                        className="w-full p-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                        rows={3}
                        value={editContent}
                        onChange={(e) => setEditContent(e.target.value)}
                    ></textarea>

                    {/* timestamp controls in edit mode */}
                    <div className="flex items-center mb-2">
                        <span className="text-xs text-gray-600 mr-2">
                            {note.timestamp_seconds !== undefined ? (
                                <>
                                    Current timestamp: {Math.floor(note.timestamp_seconds / 60)}:{String(Math.floor(note.timestamp_seconds % 60)).padStart(2, '0')}
                                </>
                            ) : (
                                <>No timestamp</>
                            )}
                        </span>
                        <button
                            className="text-xs text-blue-600 hover:text-blue-800 flex items-center ml-3"
                            onClick={() => onUpdateTimestamp(note.id, currentVideoTime)}
                        >
                            <Clock className="w-3 h-3 mr-1" />
                            Set to current video position
                        </button>
                    </div>

                    <div className="flex justify-end space-x-2">
                        <button
                            className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded hover:bg-gray-200"
                            onClick={onCancelEdit}
                        >
                            Cancel
                        </button>
                        <button
                            className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded hover:bg-green-200 flex items-center"
                            onClick={() => onSaveEdit(note.id)}
                        >
                            <CheckCircle className="w-3 h-3 mr-1" />
                            Save
                        </button>
                    </div>
                </div>
            ) : (
                <>
                    <div className="flex justify-between">
                        <p className="font-medium text-gray-800">{note.content.length > 50 ? `${note.content.substring(0, 50)}...` : note.content}</p>
                        <span className="text-xs text-gray-500">{note.created_at}</span>
                    </div>

                    <p className="mt-2 text-sm text-gray-600">
                        {note.content}
                    </p>

                    <div className="mt-2 flex justify-between items-center">
                        <span className="text-xs text-gray-500 font-medium">{note.author}</span>

                        <div className="flex items-center space-x-3">
                            {note.timestamp_seconds !== undefined && (
                                <button
                                    className="text-xs text-blue-600 hover:text-blue-800 flex items-center"
                                    onClick={handleJumpToTimestamp}
                                >
                                    <Clock className="w-3 h-3 mr-1" />
                                    Jump to {Math.floor(note.timestamp_seconds / 60)}:{String(Math.floor(note.timestamp_seconds % 60)).padStart(2, '0')}
                                </button>
                            )}

                            <div className="flex items-center space-x-2">
                                <button
                                    className="text-xs text-gray-500 flex items-center hover:text-blue-600"
                                    onClick={() => onEdit(note)}
                                >
                                    <Edit3 className="w-3 h-3 mr-1" />
                                    Edit
                                </button>

                                <button
                                    className="text-xs text-gray-500 flex items-center hover:text-red-600"
                                    onClick={() => onDelete(note.id)}
                                >
                                    <Trash2 className="w-3 h-3 mr-1" />
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </>
            )}
        </div>
    );
};

export default NoteItem;