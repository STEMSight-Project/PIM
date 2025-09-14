import { useState } from "react";

interface EnhancedMedicalHistoryFormData {
  doctor_id: string;
  diagnosis: string;
  note: string;
}

interface EnhancedMedicalHistoryFormProps {
  initialData?: Partial<EnhancedMedicalHistoryFormData>;
  onSubmit: (data: EnhancedMedicalHistoryFormData) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
  submitLabel?: string;
}

export default function EnhancedMedicalHistoryForm({
  initialData = { doctor_id: "", diagnosis: "", note: "" },
  onSubmit,
  onCancel,
  isLoading = false,
  submitLabel = "Save",
}: EnhancedMedicalHistoryFormProps) {
  const [formData, setFormData] = useState<EnhancedMedicalHistoryFormData>({
    doctor_id: initialData.doctor_id || "",
    diagnosis: initialData.diagnosis || "",
    note: initialData.note || "",
  });
  const [errors, setErrors] = useState<{
    doctor_id?: string;
    diagnosis?: string;
    note?: string;
  }>({});

  const validateForm = () => {
    const newErrors: {
      doctor_id?: string;
      diagnosis?: string;
      note?: string;
    } = {};

    if (!formData.doctor_id.trim()) {
      newErrors.doctor_id = "Doctor ID is required";
    }

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

  const handleInputChange = (field: keyof EnhancedMedicalHistoryFormData, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="space-y-4 p-6 border rounded-lg bg-gray-50"
    >
      <div>
        <label
          htmlFor="doctor_id"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Doctor ID *
        </label>
        <input
          id="doctor_id"
          type="text"
          value={formData.doctor_id}
          onChange={(e) => handleInputChange("doctor_id", e.target.value)}
          className={`w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            errors.doctor_id ? "border-red-500" : "border-gray-300"
          }`}
          placeholder="Enter doctor ID"
          disabled={isLoading}
        />
        {errors.doctor_id && (
          <p className="mt-1 text-sm text-red-600">{errors.doctor_id}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="diagnosis"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Diagnosis *
        </label>
        <input
          id="diagnosis"
          type="text"
          value={formData.diagnosis}
          onChange={(e) => handleInputChange("diagnosis", e.target.value)}
          className={`w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
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
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Notes
        </label>
        <textarea
          id="note"
          value={formData.note}
          onChange={(e) => handleInputChange("note", e.target.value)}
          rows={4}
          className={`w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            errors.note ? "border-red-500" : "border-gray-300"
          }`}
          placeholder="Enter additional notes (optional)"
          disabled={isLoading}
        />
        {errors.note && (
          <p className="mt-1 text-sm text-red-600">{errors.note}</p>
        )}
      </div>

      <div className="flex gap-3 pt-4">
        <button
          type="submit"
          disabled={isLoading}
          className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed font-medium"
        >
          {isLoading ? "Saving..." : submitLabel}
        </button>
        <button
          type="button"
          onClick={onCancel}
          disabled={isLoading}
          className="px-6 py-3 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 disabled:opacity-50 disabled:cursor-not-allowed font-medium"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}