import { useState } from "react";

interface MedicalHistoryFormProps {
  initialData?: {
    diagnosis: string;
    note: string;
  };
  onSubmit: (data: { diagnosis: string; note: string }) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
  submitLabel?: string;
}

export default function MedicalHistoryForm({
  initialData = { diagnosis: "", note: "" },
  onSubmit,
  onCancel,
  isLoading = false,
  submitLabel = "Save",
}: MedicalHistoryFormProps) {
  const [formData, setFormData] = useState(initialData);
  const [errors, setErrors] = useState<{ diagnosis?: string; note?: string }>(
    {}
  );

  const validateForm = () => {
    const newErrors: { diagnosis?: string; note?: string } = {};

    if (!formData.diagnosis.trim()) {
      newErrors.diagnosis = "Diagnosis is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      await onSubmit(formData);
    } catch (error) {
      console.error("Form submission error:", error);
    }
  };

  const handleInputChange = (field: keyof typeof formData, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="space-y-4 p-4 border rounded-lg bg-gray-50"
    >
      <div>
        <label
          htmlFor="diagnosis"
          className="block text-sm font-medium text-gray-700 mb-1"
        >
          Diagnosis *
        </label>
        <input
          id="diagnosis"
          type="text"
          value={formData.diagnosis}
          onChange={(e) => handleInputChange("diagnosis", e.target.value)}
          className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            errors.diagnosis ? "border-red-500" : "border-gray-300"
          }`}
          placeholder="Enter diagnosis"
          disabled={isLoading}
        />
        {errors.diagnosis && (
          <p className="mt-1 text-sm text-red-600">{errors.diagnosis}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="note"
          className="block text-sm font-medium text-gray-700 mb-1"
        >
          Note
        </label>
        <textarea
          id="note"
          value={formData.note}
          onChange={(e) => handleInputChange("note", e.target.value)}
          rows={3}
          className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            errors.note ? "border-red-500" : "border-gray-300"
          }`}
          placeholder="Enter additional notes (optional)"
          disabled={isLoading}
        />
        {errors.note && (
          <p className="mt-1 text-sm text-red-600">{errors.note}</p>
        )}
      </div>

      <div className="flex gap-2 pt-2">
        <button
          type="submit"
          disabled={isLoading}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? "Saving..." : submitLabel}
        </button>
        <button
          type="button"
          onClick={onCancel}
          disabled={isLoading}
          className="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
