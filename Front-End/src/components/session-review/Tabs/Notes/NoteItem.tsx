import { Note } from "@/services";
import { CheckCircle, Clock, Edit3, Trash2 } from "lucide-react";
import React from "react";

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
  currentVideoTime,
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
      console.warn(
        "NoteItem: Cannot jump to timestamp - note has no timestamp"
      );
    }
  };

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow">
      {isEditing ? (
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Edit Note
            </label>
            <textarea
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 resize-none"
              rows={3}
              value={editContent}
              onChange={(e) => setEditContent(e.target.value)}
            ></textarea>
          </div>

          {/* timestamp controls in edit mode */}
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center">
              <Clock className="w-4 h-4 text-gray-400 mr-2" />
              <span className="text-sm text-gray-600">
                {note.timestamp_seconds !== undefined ? (
                  <>
                    Timestamp: {Math.floor(note.timestamp_seconds / 60)}:
                    {String(Math.floor(note.timestamp_seconds % 60)).padStart(
                      2,
                      "0"
                    )}
                  </>
                ) : (
                  <>No timestamp set</>
                )}
              </span>
            </div>
            <button
              className="inline-flex items-center px-3 py-1 text-sm text-blue-600 hover:text-blue-800 font-medium"
              onClick={() => onUpdateTimestamp(note.id, currentVideoTime)}
            >
              <Clock className="w-4 h-4 mr-1" />
              Update to current time
            </button>
          </div>

          <div className="flex justify-end space-x-3">
            <button
              className="px-4 py-2 bg-gray-100 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-200 transition-colors"
              onClick={onCancelEdit}
            >
              Cancel
            </button>
            <button
              className="inline-flex items-center px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700 transition-colors"
              onClick={() => onSaveEdit(note.id)}
            >
              <CheckCircle className="w-4 h-4 mr-2" />
              Save Changes
            </button>
          </div>
        </div>
      ) : (
        <div className="space-y-3">
          <div className="flex justify-between items-start">
            <div className="flex-1">
              <p className="text-gray-900 font-medium leading-relaxed">
                {note.content}
              </p>
            </div>
            <div className="ml-4 text-right">
              <span className="text-xs text-gray-500 block">
                {new Date(note.created_at).toLocaleDateString()}
              </span>
              <span className="text-xs text-gray-400 block mt-1">
                {new Date(note.created_at).toLocaleTimeString()}
              </span>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center mr-2">
                <span className="text-xs font-medium text-blue-600">
                  {note.author?.charAt(0).toUpperCase() || "U"}
                </span>
              </div>
              <span className="text-sm text-gray-600 font-medium">
                {note.author || "Unknown"}
              </span>
            </div>

            <div className="flex items-center space-x-3">
              {note.timestamp_seconds !== undefined && (
                <button
                  className="inline-flex items-center px-2 py-1 bg-blue-50 text-blue-700 text-xs font-medium rounded-md hover:bg-blue-100 transition-colors"
                  onClick={handleJumpToTimestamp}
                >
                  <Clock className="w-3 h-3 mr-1" />
                  {Math.floor(note.timestamp_seconds / 60)}:
                  {String(Math.floor(note.timestamp_seconds % 60)).padStart(
                    2,
                    "0"
                  )}
                </button>
              )}

              <div className="flex items-center space-x-2">
                <button
                  className="inline-flex items-center text-xs text-gray-500 hover:text-blue-600 font-medium"
                  onClick={() => onEdit(note)}
                >
                  <Edit3 className="w-3 h-3 mr-1" />
                  Edit
                </button>

                <button
                  className="inline-flex items-center text-xs text-gray-500 hover:text-red-600 font-medium"
                  onClick={() => onDelete(note.id)}
                >
                  <Trash2 className="w-3 h-3 mr-1" />
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default NoteItem;
