import { useState } from "react";

interface NoteEditorProps {
  initialNote: string;
  onSave: (note: string) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
}

export default function NoteEditor({
  initialNote,
  onSave,
  onCancel,
  isLoading = false,
}: NoteEditorProps) {
  const [note, setNote] = useState(initialNote);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await onSave(note);
    } catch (error) {
      console.error("Note save error:", error);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <textarea
        value={note}
        onChange={(e) => setNote(e.target.value)}
        className="w-full border p-2 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        rows={3}
        placeholder="Enter note..."
        disabled={isLoading}
      />
      <div className="flex gap-2">
        <button
          type="submit"
          disabled={isLoading}
          className="text-green-600 underline hover:text-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? "Saving..." : "Save"}
        </button>
        <button
          type="button"
          onClick={onCancel}
          disabled={isLoading}
          className="text-gray-500 underline hover:text-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
