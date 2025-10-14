// services/ambulanceSessionService.ts
import { api } from "./api";

export interface AmbulanceSession {
  id: string;
  session_id: string;
  hls_playlist_url: string | null;
  recording_path: string | null;
  session_start: string;
  session_end: string | null;
  duration: number | null;
  file_size: number | null;
  status: string;
  created_at: string;
  updated_at: string | null;
  storage_url: string | null;
}

class AmbulanceSessionService {
  /**
   * Fetch recent ambulance sessions
   */
  async getRecentSessions(limit: number = 20) {
    try {
      // Fetch all sessions and sort/limit on client side
      const response = await api.get<AmbulanceSession[]>('/ambulance_sessions');

      if (!response.data) {
        return { success: false, error: 'No data returned', data: [] };
      }

      // Sort by session_start descending and limit
      const sortedSessions = response.data
        .sort((a, b) => new Date(b.session_start).getTime() - new Date(a.session_start).getTime())
        .slice(0, limit);

      return { success: true, data: sortedSessions, error: null };
    } catch (err) {
      console.error('Exception fetching sessions:', err);
      return {
        success: false,
        error: err instanceof Error ? err.message : 'Unknown error',
        data: [],
      };
    }
  }

  /**
   * Fetch a single session by ID
   */
  async getSessionById(sessionId: string) {
    try {
      const response = await api.get<AmbulanceSession>(`/ambulance_sessions/${sessionId}`);

      if (!response.data) {
        return { success: false, error: 'Session not found', data: null };
      }

      return { success: true, data: response.data, error: null };
    } catch (err) {
      console.error('Exception fetching session:', err);
      return {
        success: false,
        error: err instanceof Error ? err.message : 'Unknown error',
        data: null,
      };
    }
  }

  /**
   * Fetch active sessions only
   */
  async getActiveSessions() {
    try {
      const response = await api.get<AmbulanceSession[]>('/ambulance_sessions');

      if (!response.data) {
        return { success: false, error: 'No data returned', data: [] };
      }

      // Filter for active sessions (no end time or status not completed)
      const activeSessions = response.data
        .filter(session => session.session_end === null || session.status !== 'completed')
        .sort((a, b) => new Date(b.session_start).getTime() - new Date(a.session_start).getTime());

      return { success: true, data: activeSessions, error: null };
    } catch (err) {
      console.error('Exception fetching active sessions:', err);
      return {
        success: false,
        error: err instanceof Error ? err.message : 'Unknown error',
        data: [],
      };
    }
  }

  /**
   * Calculate session duration
   */
  getSessionDuration(session: AmbulanceSession): string {
    if (session.duration) {
      const minutes = Math.floor(session.duration / 60);
      const seconds = session.duration % 60;
      
      if (minutes >= 60) {
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = minutes % 60;
        return `${hours}h ${remainingMinutes}m`;
      }
      
      if (minutes > 0) {
        return `${minutes}m ${seconds}s`;
      }
      
      return `${seconds}s`;
    }

    // Fallback: calculate from start/end times
    const start = new Date(session.session_start);
    const end = session.session_end ? new Date(session.session_end) : new Date();
    const durationMs = end.getTime() - start.getTime();
    const minutes = Math.floor(durationMs / 60000);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    }
    return `${minutes}m`;
  }

  /**
   * Check if session is active
   */
  isSessionActive(session: AmbulanceSession): boolean {
    return session.session_end === null || session.status !== 'completed';
  }

  /**
   * Format file size
   */
  formatFileSize(bytes: number | null): string {
    if (!bytes) return 'N/A';
    
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
  }
}

export const ambulanceSessionService = new AmbulanceSessionService();