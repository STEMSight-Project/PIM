import { api } from "./api";

export interface Patient {
  id: string;
  first_name: string;
  middle_name?: string;
  last_name: string;
  dob: string;
  primary_phone: string;
  address: string;
  created_at: string;
  updated_at: string;
}
// get all patients
export async function getAllPatients(): Promise<Patient[]> {
  return await api.get("/patients/");
}
// get a patient by id
export async function getPatient(id: string) {
  return await api.get<Patient>(`/patients/${id}`);
}
