import { fetchData, postData, ApiResponse } from './api';

export interface Video {
  id: string;
  patient_id: string;
  description: string | null;
  file_path: string;
  public_video_url: string;
  created_at: string;
}

// get all videos
export async function getAllVideos(): Promise<ApiResponse<Video[]>> {
  return fetchData<Video[]>('/videos/');
}

// get video using patient id
export async function getVideosForPatient(patientId: string): Promise<ApiResponse<Video[]>> {
  return fetchData<Video[]>(`/videos/${patientId}/videos`);
}
