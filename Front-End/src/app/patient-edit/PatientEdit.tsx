"use client";

import React from "react";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert, Button, Input, Loading } from "@/components/ui";
import { usePatients } from "@/hooks";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface PatientEditProps {
  patientId: string;
}

interface PatientFormData {
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: "male" | "female" | "other";
  email: string;
  phone: string;
  address: string;
  emergency_contact: string;
}

export default function PatientEdit({ patientId }: PatientEditProps) {
  const router = useRouter();
  const { getPatient, updatePatient } = usePatients();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState<PatientFormData>({
    first_name: "",
    last_name: "",
    date_of_birth: "",
    gender: "male",
    email: "",
    phone: "",
    address: "",
    emergency_contact: "",
  });

  useEffect(() => {
    if (!patientId) return;

    let mounted = true;

    const load = async () => {
      setIsLoading(true);
      try {
        const res = await getPatient(patientId);
        if (!mounted) return;

        if (res.success && res.data) {
          setForm({
            first_name: res.data.first_name,
            last_name: res.data.last_name,
            date_of_birth: res.data.date_of_birth || "",
            gender: res.data.gender,
            email: res.data.email || "",
            phone: res.data.phone || "",
            address: res.data.address || "",
            emergency_contact: res.data.emergency_contact || "",
          });
        } else {
          setError(res.error || "Failed to load patient");
        }
      } catch (err) {
        console.error(err);
        setError("Server error");
      } finally {
        setIsLoading(false);
      }
    };
    load();
    return () => {
      mounted = false;
    };
  }, [patientId]);

  const validateForm = (data: PatientFormData): string[] => {
    const errors: string[] = [];
    const trimmedData = {
      ...data,
      first_name: (data.first_name || "").trim(),
      last_name: (data.last_name || "").trim(),
      email: (data.email || "").trim(),
      phone: (data.phone || "").trim(),
      address: (data.address || "").trim(),
      emergency_contact: (data.emergency_contact || "").trim(),
    };

    // First name validation
    if (!trimmedData.first_name) {
      errors.push("First name is required.");
    } else if (
      trimmedData.first_name.length < 1 ||
      trimmedData.first_name.length > 50
    ) {
      errors.push("First name must be between 1 and 50 characters.");
    }

    // Last name validation
    if (!trimmedData.last_name) {
      errors.push("Last name is required.");
    } else if (
      trimmedData.last_name.length < 1 ||
      trimmedData.last_name.length > 50
    ) {
      errors.push("Last name must be between 1 and 50 characters.");
    }

    // Date of birth validation (optional)
    if (trimmedData.date_of_birth) {
      const dob = new Date(trimmedData.date_of_birth);
      const today = new Date();
      if (isNaN(dob.getTime())) {
        errors.push("Invalid date of birth.");
      } else if (dob > today) {
        errors.push("Date of birth cannot be in the future.");
      } else {
        const age = today.getFullYear() - dob.getFullYear();
        if (age < 0 || age > 150) {
          errors.push("Age must be between 0 and 150 years.");
        }
      }
    }

    // Email validation
    if (
      trimmedData.email &&
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedData.email)
    ) {
      errors.push("Invalid email format.");
    }

    // Phone validation (optional, but if provided, check format)
    if (
      trimmedData.phone &&
      !/^\+?[\d\s\-\(\)]{10,}$/.test(trimmedData.phone)
    ) {
      errors.push("Invalid phone number format.");
    }

    // Emergency contact validation (optional, but if provided, check format)
    if (
      trimmedData.emergency_contact &&
      !/^\+?[\d\s\-\(\)]{10,}$/.test(trimmedData.emergency_contact)
    ) {
      errors.push("Invalid emergency contact phone format.");
    }

    return errors;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setError(null);

    const trimmedForm = {
      ...form,
      first_name: (form.first_name || "").trim(),
      last_name: (form.last_name || "").trim(),
      email: (form.email || "").trim(),
      phone: (form.phone || "").trim(),
      address: (form.address || "").trim(),
      emergency_contact: (form.emergency_contact || "").trim(),
    };

    const errors = validateForm(trimmedForm);
    if (errors.length > 0) {
      setError(errors.join(" "));
      setIsSaving(false);
      return;
    }

    const res = await updatePatient(patientId, trimmedForm);
    if (res.success) {
      // back to patient details
      router.push(`/patients/${patientId}`);
    } else {
      setError(res.error || "Failed to update patient");
    }

    setIsSaving(false);
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <Loading text="Loading patient..." />
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6 max-w-2xl">
        <h2 className="text-xl font-semibold">Edit Patient</h2>

        {error && <Alert variant="error">{error}</Alert>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="First Name"
              value={form.first_name}
              onChange={(e) =>
                setForm((p) => ({ ...p, first_name: e.target.value }))
              }
              required
            />
            <Input
              label="Last Name"
              value={form.last_name}
              onChange={(e) =>
                setForm((p) => ({ ...p, last_name: e.target.value }))
              }
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date of Birth"
              type="date"
              value={form.date_of_birth}
              onChange={(e) =>
                setForm((p) => ({ ...p, date_of_birth: e.target.value }))
              }
            />
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Gender
              </label>
              <select
                className="w-full h-10 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={form.gender}
                onChange={(e) =>
                  setForm((p) => ({
                    ...p,
                    gender: e.target.value as "male" | "female" | "other",
                  }))
                }
              >
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
              </select>
            </div>
          </div>

          <Input
            label="Email"
            type="email"
            value={form.email}
            onChange={(e) => setForm((p) => ({ ...p, email: e.target.value }))}
          />

          <Input
            label="Phone"
            type="tel"
            value={form.phone}
            onChange={(e) => setForm((p) => ({ ...p, phone: e.target.value }))}
          />

          <Input
            label="Address"
            value={form.address}
            onChange={(e) =>
              setForm((p) => ({ ...p, address: e.target.value }))
            }
          />

          <Input
            label="Emergency Contact"
            value={form.emergency_contact}
            onChange={(e) =>
              setForm((p) => ({ ...p, emergency_contact: e.target.value }))
            }
          />

          <div className="flex space-x-3 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
            >
              Cancel
            </Button>
            <Button type="submit" isLoading={isSaving}>
              Save
            </Button>
          </div>
        </form>
      </div>
    </DashboardLayout>
  );
}
