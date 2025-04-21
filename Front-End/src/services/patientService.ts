import { fetchData, postData } from './api';

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
export async function getAllPatients() {
  return fetchData<Patient[]>('/patients/');
}
// get a patient by id
export async function getPatient(id: string) {
  return fetchData<Patient>(`/patients/${id}`);
}
