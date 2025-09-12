"use client";

import { useState, useCallback } from "react";
import { api } from "@/services/api";

export interface Video {
  id: string;
  patient_id: string;
  description: string | null;
  file_path: string;
  public_video_url: string;
  created_at: string;
}

interface UseVideosReturn {
  videos: Video[];
  selectedVideo: Video | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchAllVideos: () => Promise<void>;
  fetchVideosForPatient: (patientId: string) => Promise<void>;
  createVideo: (data: FormData) => Promise<Video | null>;
  deleteVideo: (id: string) => Promise<boolean>;
  clearError: () => void;
  setSelectedVideo: (video: Video | null) => void;
  clearVideos: () => void;
}

export function useVideos(): UseVideosReturn {
  const [videos, setVideos] = useState<Video[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const clearVideos = useCallback(() => {
    setVideos([]);
    setSelectedVideo(null);
  }, []);

  const fetchAllVideos = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Video[]>("/videos/");
      setVideos(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch videos";
      setError(message);
      console.error("Error fetching videos:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchVideosForPatient = useCallback(async (patientId: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<Video[]>(`/videos/${patientId}/videos`);
      setVideos(response.data || []);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Failed to fetch patient videos";
      setError(message);
      console.error("Error fetching patient videos:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const createVideo = useCallback(
    async (data: FormData): Promise<Video | null> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.post<Video>("/videos/", data);
        if (response.data) {
          setVideos((prev) => [response.data!, ...prev]);
          return response.data;
        }
        return null;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to create video";
        setError(message);
        console.error("Error creating video:", err);
        return null;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  const deleteVideo = useCallback(
    async (id: string): Promise<boolean> => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.delete(`/videos/${id}`);
        if (!response.error) {
          setVideos((prev) => prev.filter((video) => video.id !== id));
          if (selectedVideo?.id === id) {
            setSelectedVideo(null);
          }
          return true;
        }
        return false;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to delete video";
        setError(message);
        console.error("Error deleting video:", err);
        return false;
      } finally {
        setLoading(false);
      }
    },
    [selectedVideo]
  );

  return {
    videos,
    selectedVideo,
    loading,
    error,
    fetchAllVideos,
    fetchVideosForPatient,
    createVideo,
    deleteVideo,
    clearError,
    setSelectedVideo,
    clearVideos,
  };
}
