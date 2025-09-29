"use client";

import { DashboardLayout } from "@/components/layouts/DashboardLayout";
import { Alert, Button, Input, Loading } from "@/components/ui";
import { usePatients } from "@/hooks";
import type { PatientUpdateRequest } from "@/types";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface PatientEditProps {
  patientId: string;
}



export default function PatientEdit({ patientId }: PatientEditProps) {
  const params = useParams();
  const router = useRouter();
  const { getPatient, updatePatient } = usePatients();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState<PatientUpdateRequest>({
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
            ...res.data,
            date_of_birth: res.data.date_of_birth || "",
            address: res.data.address || "",
            emergency_contact: res.data.emergency_contact || "",
          });
        } else {
          setError(res.error || "Failed to load patient");
        }
      } catch (err: any) {
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setError(null);

    // Basic email validation
    if (form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
      setError("Invalid email format");
      setIsSaving(false);
      return;
    }

    const res = await updatePatient(patientId, form);
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
              onChange={(e) => setForm((p) => ({ ...p, first_name: e.target.value }))}
              required
            />
            <Input
              label="Last Name"
              value={form.last_name}
              onChange={(e) => setForm((p) => ({ ...p, last_name: e.target.value }))}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
            label="Date of Birth"
            type="date"
            value={form.date_of_birth}
            onChange={(e) =>
              setForm((p) => ({ ...p, date_of_birth: e.target.value }))} 
              required />
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Gender</label>
              <select
                className="w-full h-10 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={form.gender}
                onChange={(e) => setForm((p) => ({ ...p, gender: e.target.value as "male" | "female" | "other" }))}
              >
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
              </select>
            </div>
          </div>

          <Input label="Email" type="email" value={form.email} 
          onChange={(e) => setForm((p) => ({ ...p, email: e.target.value }))} />

          <Input label="Phone" type="tel" value={form.phone} 
          onChange={(e) => setForm((p) => ({ ...p, phone: e.target.value }))} />

          <Input label="Address" value={form.address} 
          onChange={(e) => setForm((p) => ({ ...p, address: e.target.value }))} />

          <Input label="Emergency Contact" value={form.emergency_contact} 
          onChange={(e) => setForm((p) => ({ ...p, emergency_contact: e.target.value }))} />

          <div className="flex space-x-3 pt-4">
            <Button type="button" variant="outline" onClick={() => router.back()}>
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
