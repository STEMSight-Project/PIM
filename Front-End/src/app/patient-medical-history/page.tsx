"use client";
import "./style.css";
import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

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
  note?: string;
  created_at: string;
  updated_at: string;
};

export default function PatientMedicalHistory() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get("patientId") || "";
  const [patient, setPatient] = useState<Patient | null>(null);
  const [histories, setHistories] = useState<MedicalHistory[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [noteInput, setNoteInput] = useState<string>("");

  // CREATE a new history record
  const handleCreateHistory = async (diagnosis: string, note?: string) => {
    try {
      const res = await fetch("http://127.0.0.1:8000/medical-history/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          patient_id: patientId,
          doctor_id: "d86f06ec-fd0a-42a7-872c-e8224a4b18f1", // replace with actual doctor_id
          diagnosis,
          note,
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Create failed: ${res.status} ${text}`);
      }
      const newRecord: MedicalHistory = await res.json();
      setHistories((h) => [newRecord, ...h]);
    } catch (err) {
      console.error(err);
      alert(`Error creating history: ${err}`);
    }
  };

  // UPDATE an existing history record (now sends patient_id, doctor_id, diagnosis, note)
  const handleUpdateHistory = async (
    id: string,
    patient_id: string,
    doctor_id: string,
    diagnosis: string,
    note?: string
  ) => {
    try {
      const res = await fetch(
        `http://127.0.0.1:8000/medical-history/${id}`,
        {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ patient_id, doctor_id, diagnosis, note }),
        }
      );
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Update failed: ${res.status} ${text}`);
      }
      const updatedRecord: MedicalHistory = await res.json();
      setHistories((h) =>
        h.map((item) => (item.id === id ? updatedRecord : item))
      );
    } catch (err) {
      console.error(err);
      alert(`Error updating history: ${err}`);
    }
  };

  // DELETE a history record
  const handleDeleteHistory = async (id: string) => {
    if (!confirm("Are you sure you want to delete this record?")) return;
    try {
      const res = await fetch(`http://127.0.0.1:8000/medical-history/${id}`, {
        method: "DELETE",
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Delete failed: ${res.status} ${text}`);
      }
      setHistories((h) => h.filter((item) => item.id !== id));
    } catch (err) {
      console.error(err);
      alert(`Error deleting history: ${err}`);
    }
  };

  useEffect(() => {
    if (!patientId) return setLoading(false);

    // Load patient
    fetch(`http://127.0.0.1:8000/patients/${patientId}`)
      .then((r) => (r.ok ? r.json() : Promise.reject("patient")))
      .then(setPatient)
      .catch(console.error);

    // Load all medical history and filter locally
    fetch(`http://127.0.0.1:8000/medical-history/`)
      .then((r) => (r.ok ? r.json() : Promise.reject("history")))
      .then((data) => {
        const filtered = data.filter(
          (h: MedicalHistory) => h.patient_id === patientId
        );
        setHistories(filtered);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [patientId]);

  const handleUpdateNote = (id: string) => {
    fetch(`http://127.0.0.1:8000/medical-history/update_note/${id}?note=${encodeURIComponent(noteInput)}`, {
      method: "PATCH",
    })
      .then(async (res) => {
        if (!res.ok) {
          const text = await res.text();
          throw new Error(`Update failed: ${res.status} ${res.statusText} – ${text}`);
        }
        return res.json();
      })
      .then((updated) => {
        setHistories((prev) =>
          prev.map((h) => (h.id === id ? { ...h, note: updated[0]?.note ?? h.note } : h))
        );
        setEditingNoteId(null);
        setNoteInput("");
      })
      .catch((err) => {
        console.error(err);
        alert(err.message);
      });
  };

  if (loading) return <div>Loading…</div>;
  if (!patient) return <div>Patient not found.</div>;

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
        <h2 className="text-xl font-semibold">Medical History</h2>
        <button
          className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
          onClick={() =>
            handleCreateHistory(
              prompt("Diagnosis?") || "",
              prompt("Note?") || undefined
            )
          }
        >
          Create New History
        </button>
        {histories.length > 0 ? (
          histories.map((h, idx) => (
            <div
              key={h.id ?? idx}
              className="border p-4 rounded shadow"
            >
              <p>
                <strong>Diagnosis:</strong> {h.diagnosis}
              </p>
              {editingNoteId === h.id ? (
                <div className="space-y-2">
                  <textarea
                    value={noteInput}
                    onChange={(e) => setNoteInput(e.target.value)}
                    className="w-full border p-2 rounded"
                  />
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleUpdateNote(h.id)}
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
                    <strong>Note:</strong> {h.note || "—"}
                  </p>
                  <button
                    onClick={() => {
                      setEditingNoteId(h.id);
                      setNoteInput(h.note || "");
                    }}
                    className="text-blue-600 underline text-sm mt-1"
                  >
                    Edit Note
                  </button>
                </div>
              )}
              <button
                className="ml-2 text-orange-600 underline text-sm"
                onClick={() => {
                  const newDiag =
                    prompt("New diagnosis?", h.diagnosis) || h.diagnosis;
                  const newNote =
                    prompt("New note?", h.note ?? "") ?? h.note;
                  handleUpdateHistory(
                    h.id,
                    h.patient_id,
                    h.doctor_id,
                    newDiag,
                    newNote
                  );
                }}
              >
                Update
              </button>
              <button
                className="ml-2 text-red-600 underline text-sm"
                onClick={() => handleDeleteHistory(h.id)}
              >
                Delete
              </button>
              <p className="text-sm text-gray-500">
                Created: {new Date(h.created_at).toLocaleString()}
              </p>
            </div>
          ))
        ) : (
          <p>No medical history records for this patient.</p>
        )}
      </main>

      <Footer />
    </div>
  );
}