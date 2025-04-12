import React from 'react';
import { Clock, MessageSquare } from 'lucide-react';
import { Note } from './types';

// NoteForm for creating new notes, you can link a timestamp to each note
interface NoteFormProps {
    newNote: string;
    setNewNote: (value: string) => void;
    currentTime: number | undefined;
    setCurrentTime: (time: number | undefined) => void;
    currentVideoTime: number;
    onCancel: () => void;
    onSave: () => void;
    onUpdateTimestamp: (id: string, newTime: number) => void;
}

const NoteForm: React.FC<NoteFormProps> = ({
    newNote,
    setNewNote,
    currentTime,
    setCurrentTime,
    currentVideoTime,
    onCancel,
    onSave,
    onUpdateTimestamp
}) => {
    const handleSetCurrentTime = () => {
        setCurrentTime(currentVideoTime);
    };

    return (
        <div className="bg-white p-4 rounded-lg border border-gray-200 mb-4">
            <textarea
                className="w-full p-2 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                rows={4}
                placeholder="Enter your note here..."
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
            ></textarea>

            <div className="flex justify-between mt-2">
                <div className="flex items-center">
                    {currentTime !== undefined ? (
                        <span className="text-xs text-gray-600 flex items-center">
                            <Clock className="w-3 h-3 mr-1" />
                            Timestamp: {Math.floor(currentTime / 60)}:{String(Math.floor(currentTime % 60)).padStart(2, '0')}
                        </span>
                    ) : (
                        <button
                            className="text-xs text-blue-600 flex items-center"
                            onClick={handleSetCurrentTime}
                        >
                            <Clock className="w-3 h-3 mr-1" />
                            Add current timestamp
                        </button>
                    )}
                </div>

                <div className="flex space-x-2">
                    <button
                        className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded hover:bg-gray-200"
                        onClick={onCancel}
                    >
                        Cancel
                    </button>
                    <button
                        className="px-2 py-1 bg-blue-600 text-white text-xs rounded hover:bg-blue-700"
                        onClick={onSave}
                    >
                        Save Note
                    </button>
                </div>
            </div>
        </div>
    );
};

export default NoteForm;