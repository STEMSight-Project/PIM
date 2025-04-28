import { api } from "./api";

export interface Video {
  id: string;
  patient_id: string;
  description: string | null;
  file_path: string;
  public_video_url: string;
  created_at: string;
}

// get all videos
export async function getAllVideos(): Promise<Video[]> {
  return await api.get("/videos/");
}

// get video using patient id
export async function getVideosForPatient(patientId: string): Promise<Video[]> {
  return await api.get(`/videos/${patientId}/videos`);
}
