import React from "react";
import { Clock } from "lucide-react";

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
}) => {
  const handleSetCurrentTime = () => {
    setCurrentTime(currentVideoTime);
  };

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Note Content
        </label>
        <textarea
          className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 resize-none shadow-sm"
          rows={4}
          placeholder="Enter your note here..."
          value={newNote}
          onChange={(e) => setNewNote(e.target.value)}
        ></textarea>
      </div>

      <div className="flex justify-between items-center">
        <div className="flex items-center">
          {currentTime !== undefined ? (
            <div className="inline-flex items-center px-3 py-1.5 bg-blue-100 text-blue-800 text-sm font-medium rounded-md">
              <Clock className="w-4 h-4 mr-2" />
              Timestamp: {Math.floor(currentTime / 60)}:
              {String(Math.floor(currentTime % 60)).padStart(2, "0")}
            </div>
          ) : (
            <button
              className="inline-flex items-center px-3 py-1.5 text-sm text-blue-600 hover:text-blue-800 font-medium"
              onClick={handleSetCurrentTime}
            >
              <Clock className="w-4 h-4 mr-2" />
              Add current timestamp
            </button>
          )}
        </div>

        <div className="flex space-x-3">
          <button
            className="px-4 py-2 bg-gray-100 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-200 transition-colors"
            onClick={onCancel}
          >
            Cancel
          </button>
          <button
            className="px-4 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white text-sm font-medium rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all duration-200 shadow-sm hover:shadow-md"
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
