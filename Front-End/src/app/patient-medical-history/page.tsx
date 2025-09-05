"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import "./style.css";

/** Types */
type Patient = {
  id: string;
  first_name: string;
  last_name: string;
};

type MedicalHistory = {
  id: string;
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  note?: string | null;
  created_at: string; // ISO if possible
  updated_at: string;
};

/** Config (env-first with safe fallback) */
const API_BASE = process.env.NEXT_PUBLIC_API_BASE ?? "http://127.0.0.1:8000";

/** Date formatting (stable across locales & time zones) */
const formatDate = (isoLike: string) => {
  // If server returns naive datetimes, consider making them explicit UTC on the backend.
  const d = new Date(isoLike);
  if (Number.isNaN(d.getTime())) return "Invalid date";
  return new Intl.DateTimeFormat(undefined, {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(d);
};

/** API hook with stable callbacks + JSON helper + 401 redirect */
const useApi = () => {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  const fetchWithAuth = useCallback(
    async (url: string, options: RequestInit = {}) => {
      try {
        const token =
          localStorage.getItem("token") || sessionStorage.getItem("token");

        const headers: HeadersInit = {
          Accept: "application/json",
          ...(options.method && options.method !== "GET"
            ? { "Content-Type": "application/json" }
            : {}),
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
          ...options.headers,
        };

        const response = await fetch(url, {
          ...options,
          headers,
          credentials: "include", // keep if you rely on cookies; ensure CORS allows it
        });

        if (response.status === 401) {
          // Preserve current path for return
          const returnUrl = encodeURIComponent(
            `${window.location.pathname}${window.location.search}`
          );
          router.push(`/?returnUrl=${returnUrl}`);
          return null;
        }

        if (!response.ok) {
          const text = await response.text().catch(() => "");
          throw new Error(`API error: ${response.status} – ${text || url}`);
        }

        return response;
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        console.error("API request failed:", e);
        setError(`API request failed: ${msg}`);
        return null;
      }
    },
    [router]
  );

  const fetchJson = useCallback(
    async <T,>(url: string, options?: RequestInit): Promise<T | null> => {
      const res = await fetchWithAuth(url, options);
      if (!res) return null;
      try {
        return (await res.json()) as T;
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        setError(`Failed to parse JSON from ${url}: ${msg}`);
        return null;
      }
    },
    [fetchWithAuth]
  );

  return { fetchWithAuth, fetchJson, error, setError };
};

/** Small extracted form with prop/state sync */
const HistoryForm = ({
  onSubmit,
  onCancel,
  initialValues = { diagnosis: "", note: "" },
  isEditing = false,
}: {
  onSubmit: (diagnosis: string, note: string) => void;
  onCancel: () => void;
  initialValues?: { diagnosis: string; note?: string | null };
  isEditing?: boolean;
}) => {
  const [diagnosis, setDiagnosis] = useState(initialValues.diagnosis ?? "");
  const [note, setNote] = useState(initialValues.note ?? "");

  // Keep inputs in sync when initialValues change (e.g., switching records)
  useEffect(() => {
    setDiagnosis(initialValues.diagnosis ?? "");
    setNote(initialValues.note ?? "");
  }, [initialValues.diagnosis, initialValues.note]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(diagnosis.trim(), note.trim());
  };

  return (
    <form onSubmit={handleSubmit} className="border p-4 rounded shadow bg-blue-50">
      <h3 className="font-semibold mb-2">
        {isEditing ? "Edit Medical History" : "Create New Medical History"}
      </h3>

      <div className="space-y-3">
        <div>
          <label className="block text-sm font-medium" htmlFor="diagnosis">
            Diagnosis
          </label>
          <input
            id="diagnosis"
            type="text"
            value={diagnosis}
            onChange={(e) => setDiagnosis(e.target.value)}
            className="w-full border p-2 rounded"
            required
            autoFocus
          />
        </div>

        <div>
          <label className="block text-sm font-medium" htmlFor="note">
            Notes {!isEditing && "(optional)"}
          </label>
          <textarea
            id="note"
            value={note}
            onChange={(e) => setNote(e.target.value)}
            className="w-full border p-2 rounded"
            rows={3}
          />
        </div>

        <div className="flex gap-2 justify-end">
          <button
            type="button"
            onClick={onCancel}
            className="px-3 py-1 border rounded"
          >
            Cancel
          </button>
          <button
            type="submit"
            className={`px-3 py-1 ${
              isEditing ? "bg-orange-600" : "bg-blue-600"
            } text-white rounded`}
          >
            {isEditing ? "Update" : "Save"}
          </button>
        </div>
      </div>
    </form>
  );
};

/** Client-only delete button */
const DeleteButton = ({
  id,
  onDelete,
}: {
  id: string;
  onDelete: (id: string) => void;
}) => {
  const handleClick = () => {
    if (window.confirm("Are you sure you want to delete this record?")) {
      onDelete(id);
    }
  };
  return (
    <button className="text-red-600 underline text-sm" onClick={handleClick}>
      Delete
    </button>
  );
};

export default function PatientMedicalHistory() {
  const router = useRouter();
  const searchParams = useSearchParams();
  // Stabilize and trim once (prevents subtle filter mismatches)
  const patientId = useMemo(
    () => (searchParams?.get("patientId") || "").trim(),
    [searchParams]
  );

  const { fetchWithAuth, fetchJson, error: apiError, setError } = useApi();

  /** State */
  const [patient, setPatient] = useState<Patient | null>(null);
  const [histories, setHistories] = useState<MedicalHistory[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setLocalError] = useState<string | null>(null);

  // Inline edit-note state
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [noteInput, setNoteInput] = useState<string>("");

  // Record-level edit/create
  const [isCreating, setIsCreating] = useState(false);
  const [isEditing, setIsEditing] = useState<string | null>(null);

  const errorMessage = error || apiError;

  /** Fetch patient + histories (abort-safe, sorted, filtered) */
  useEffect(() => {
    let cancelled = false;
    const abort = new AbortController();

    const run = async () => {
      if (!patientId) {
        setLoading(false);
        setLocalError("No patient ID provided");
        return;
      }

      setLoading(true);

      try {
        const p = await fetchJson<Patient>(`${API_BASE}/patients/${patientId}`, {
          signal: abort.signal,
        });
        if (!p) {
          if (!cancelled) setLocalError("Failed to load patient");
          return;
        }
        if (!cancelled) setPatient(p);

        // Fetch all history then filter client-side (kept for compatibility with your backend)
        const all = await fetchJson<MedicalHistory[]>(
          `${API_BASE}/medical-history/`,
          { signal: abort.signal }
        );
        if (!all) {
          if (!cancelled) setLocalError("Failed to load medical history");
          return;
        }

        const filtered = all
          .filter((h) => String(h.patient_id).trim() === patientId)
          .sort((a, b) => {
            const ta = new Date(a.created_at).getTime();
            const tb = new Date(b.created_at).getTime();
            return Number.isNaN(tb - ta) ? 0 : tb - ta;
          });

        if (!cancelled) setHistories(filtered);
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        console.error("Error loading data:", e);
        if (!cancelled) setLocalError(`Failed to load data: ${msg}`);
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    run();

    return () => {
      cancelled = true;
      abort.abort();
    };
    // fetchJson is stable via useCallback
  }, [patientId, fetchJson]);

  /** CRUD */
  const handleCreateHistory = useCallback(
    (diagnosis: string, note: string) => {
      if (!diagnosis.trim()) return;

      // NOTE: replace this hardcoded doctor_id with a real value from session/profile
      const doctorId = "d86f06ec-fd0a-42a7-872c-e8224a4b18f1";

      fetchWithAuth(`${API_BASE}/medical-history/`, {
        method: "POST",
        body: JSON.stringify({
          patient_id: patientId,
          doctor_id: doctorId,
          diagnosis,
          note: note || undefined,
        }),
      })
        .then(async (res) => {
          if (!res) return;
          const created = (await res.json()) as MedicalHistory;
          setHistories((prev) => [created, ...prev]);
          setLocalError(null);
          setIsCreating(false);
        })
        .catch((err) => {
          console.error(err);
          setLocalError(
            `Failed to create record: ${err instanceof Error ? err.message : String(err)}`
          );
        });
    },
    [fetchWithAuth, patientId]
  );

  const handleUpdateHistory = useCallback(
    (diagnosis: string, note: string) => {
      if (!isEditing) return;

      const record = histories.find((h) => h.id === isEditing);
      if (!record) return;

      fetchWithAuth(`${API_BASE}/medical-history/${isEditing}`, {
        method: "PUT",
        body: JSON.stringify({
          patient_id: record.patient_id,
          doctor_id: record.doctor_id,
          diagnosis,
          note: note || undefined,
        }),
      })
        .then(async (res) => {
          if (!res) return;
          const updated = (await res.json()) as MedicalHistory;
          setHistories((prev) =>
            prev.map((h) => (h.id === isEditing ? updated : h))
          );
          setIsEditing(null);
        })
        .catch((err) => {
          console.error(err);
          setLocalError(
            `Failed to update record: ${err instanceof Error ? err.message : String(err)}`
          );
        });
    },
    [fetchWithAuth, histories, isEditing]
  );

  const handleUpdateNote = useCallback(
    async (id: string) => {
      const original = histories.find((h) => h.id === id);
      if (!original) return;

      // Optimistic update for snappy UX
      setHistories((prev) =>
        prev.map((h) => (h.id === id ? { ...h, note: noteInput } : h))
      );

      const clearInlineEditor = () => {
        setEditingNoteId(null);
        setNoteInput("");
      };

      try {
        // Preferred RESTful path (PATCH body) – try first
        const res1 = await fetchWithAuth(`${API_BASE}/medical-history/${id}`, {
          method: "PATCH",
          body: JSON.stringify({ note: noteInput }),
        });

        if (res1) {
          // If backend returns the full record, prefer it; otherwise keep optimistic note
          try {
            const updated = (await res1.json()) as Partial<MedicalHistory>;
            if (updated && (updated.note !== undefined || updated.id)) {
              setHistories((prev) =>
                prev.map((h) => (h.id === id ? { ...h, ...updated } : h))
              );
            }
          } catch {
            // some PATCH endpoints may not return JSON; ignore
          }
          clearInlineEditor();
          return;
        }
        // Fall through to legacy route if no response
        throw new Error("Primary PATCH route returned null");
      } catch (primaryErr) {
        try {
          // Fallback to your existing legacy endpoint (?note=)
          const res2 = await fetchWithAuth(
            `${API_BASE}/medical-history/update_note/${id}?note=${encodeURIComponent(
              noteInput
            )}`,
            { method: "PATCH" }
          );
          if (res2) {
            const updated = await res2.json();
            setHistories((prev) =>
              prev.map((h) =>
                h.id === id ? { ...h, note: updated?.[0]?.note ?? noteInput } : h
              )
            );
            clearInlineEditor();
            return;
          }
          throw new Error("Fallback PATCH route returned null");
        } catch (fallbackErr) {
          console.error("Failed to update note:", fallbackErr);
          setLocalError(
            `Failed to update note: ${
              fallbackErr instanceof Error ? fallbackErr.message : String(fallbackErr)
            }`
          );
          // Revert optimistic change
          setHistories((prev) =>
            prev.map((h) => (h.id === id ? (original as MedicalHistory) : h))
          );
          clearInlineEditor();
        }
      }
    },
    [fetchWithAuth, histories, noteInput]
  );

  const handleDeleteHistory = useCallback(
    async (id: string) => {
      // Optimistic removal
      const prev = histories;
      setHistories((p) => p.filter((h) => h.id !== id));

      try {
        const res = await fetchWithAuth(`${API_BASE}/medical-history/${id}`, {
          method: "DELETE",
        });
        if (!res) throw new Error("No response");
      } catch (err) {
        console.error(err);
        setLocalError(
          `Failed to delete record: ${err instanceof Error ? err.message : String(err)}`
        );
        // Revert on failure
        setHistories(prev);
      }
    },
    [fetchWithAuth, histories]
  );

  /** UI helpers */
  const startEditRecord = (history: MedicalHistory) => {
    setIsEditing(history.id);
  };

  /** Render */
  if (loading) {
    return <div className="flex-grow text-center p-10">Loading...</div>;
  }

  if (errorMessage) {
    return (
      <div className="flex-grow p-10">
        <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4">
          <p className="font-bold">Error</p>
          <p>{errorMessage}</p>
        </div>
        <button
          onClick={() => router.push("/patient-dashboard")}
          className="px-4 py-2 bg-blue-600 text-white rounded"
        >
          Return to Dashboard
        </button>
      </div>
    );
  }

  if (!patient) {
    return (
      <div className="flex-grow text-center p-10">
        <p className="mb-4">Patient not found or unauthorized access.</p>
        <button
          onClick={() => router.push("/patient-dashboard")}
          className="px-4 py-2 bg-blue-600 text-white rounded"
        >
          Return to Dashboard
        </button>
      </div>
    );
  }

  return (
    <div className="bg-white text-black min-h-screen flex flex-col">
      <Header patientId={patientId} />

      <header className="text-center p-6 text-2xl font-bold">
        Patient:{" "}
        <span className="text-blue-600">
          {patient.first_name} {patient.last_name}
        </span>
      </header>

      <main className="flex-grow max-w-3xl mx-auto p-6 space-y-6">
        <div className="flex justify-between items-center">
          <h2 className="text-xl font-semibold">Medical History</h2>
          <button
            className="px-4 py-2 bg-blue-600 text-white rounded"
            onClick={() => {
              setIsEditing(null);
              setIsCreating(true);
            }}
          >
            Create New History
          </button>
        </div>

        {/* Create form */}
        {isCreating && (
          <HistoryForm
            key="create"
            onSubmit={handleCreateHistory}
            onCancel={() => setIsCreating(false)}
          />
        )}

        {/* Edit form */}
        {isEditing && (
          <HistoryForm
            key={isEditing /* force remount if switching records */}
            onSubmit={handleUpdateHistory}
            onCancel={() => setIsEditing(null)}
            initialValues={{
              diagnosis:
                histories.find((h) => h.id === isEditing)?.diagnosis ?? "",
              note: histories.find((h) => h.id === isEditing)?.note ?? "",
            }}
            isEditing
          />
        )}

        {/* List */}
        {histories.length > 0 ? (
          <div className="space-y-4">
            {histories.map((history) => (
              <div key={history.id} className="border p-4 rounded shadow">
                <p>
                  <strong>Diagnosis:</strong> {history.diagnosis}
                </p>

                {editingNoteId === history.id ? (
                  <div className="space-y-2 mt-2">
                    <textarea
                      value={noteInput}
                      onChange={(e) => setNoteInput(e.target.value)}
                      className="w-full border p-2 rounded"
                      rows={3}
                      aria-label="Edit note"
                    />
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleUpdateNote(history.id)}
                        className="text-green-600 underline"
                      >
                        Save
                      </button>
                      <button
                        onClick={() => {
                          setEditingNoteId(null);
                          setNoteInput("");
                        }}
                        className="text-gray-500 underline"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <div>
                    <p>
                      <strong>Note:</strong>{" "}
                      {history.note && history.note.trim() !== "" ? history.note : "—"}
                    </p>
                    <div className="flex gap-2 mt-2">
                      <button
                        onClick={() => {
                          setEditingNoteId(history.id);
                          setNoteInput(history.note ?? "");
                        }}
                        className="text-blue-600 underline text-sm"
                      >
                        Edit Note
                      </button>
                      <button
                        className="text-orange-600 underline text-sm"
                        onClick={() => startEditRecord(history)}
                      >
                        Edit Record
                      </button>
                      <DeleteButton id={history.id} onDelete={handleDeleteHistory} />
                    </div>
                  </div>
                )}

                <p className="text-sm text-gray-500 mt-2">
                  Created: {formatDate(history.created_at)}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-500 italic">No medical history records for this patient.</p>
        )}
      </main>

      <Footer />
    </div>
  );
}
