// hooks/useMovementDetections.ts
import { movementDetectionService } from "@/services/movementDetectionService";
import type {
  CreateMovementDetection,
  MovementDetection,
  MovementDetectionRealtimeEvent,
  MovementDetectionStats,
  MovementType,
  UpdateMovementDetection,
  ValidationStatus,
} from "@/types/movementDetection";
import { useCallback, useEffect, useRef, useState } from "react";

export interface UseMovementDetectionsOptions {
  /**
   * Auto-fetch on mount
   */
  autoFetch?: boolean;

  /**
   * Filter by room ID
   */
  roomId?: string;

  /**
   * Filter by recording ID
   */
  recordingId?: string;

  /**
   * Enable real-time updates via SSE
   */
  enableRealtime?: boolean;

  /**
   * Filter realtime by validation status
   */
  realtimeStatusFilter?: ValidationStatus;

  /**
   * Callback when new detection arrives via realtime
   */
  onRealtimeDetection?: (detection: MovementDetection) => void;

  /**
   * Callback when detection is updated via realtime
   */
  onRealtimeUpdate?: (detection: MovementDetection) => void;

  /**
   * Callback when detection is deleted via realtime
   */
  onRealtimeDelete?: (detectionId: number) => void;
}

export interface UseMovementDetectionsReturn {
  // State
  detections: MovementDetection[];
  currentDetection: MovementDetection | null;
  statistics: MovementDetectionStats | null;
  isLoading: boolean;
  error: string | null;
  isRealtimeConnected: boolean;

  // Actions
  fetchDetectionById: (detectionId: number) => Promise<void>;
  fetchDetectionsByRecording: (recordingId: string) => Promise<void>;
  fetchDetectionsByRoom: (roomId: string) => Promise<void>;
  fetchDetectionsByMovementType: (movementType: MovementType) => Promise<void>;
  fetchDetectionsByStatus: (
    status: ValidationStatus,
    limit?: number
  ) => Promise<void>;
  fetchStatistics: (roomId?: string, recordingId?: string) => Promise<void>;
  createDetection: (data: CreateMovementDetection) => Promise<boolean>;
  bulkCreateDetections: (
    detections: CreateMovementDetection[]
  ) => Promise<boolean>;
  updateDetection: (
    detectionId: number,
    data: UpdateMovementDetection
  ) => Promise<boolean>;
  updateValidationStatus: (
    detectionId: number,
    status: ValidationStatus
  ) => Promise<boolean>;
  deleteDetection: (detectionId: number) => Promise<boolean>;
  deleteDetectionsByRecording: (recordingId: string) => Promise<number>;
  connectRealtime: () => void;
  disconnectRealtime: () => void;
  clearError: () => void;
}

export function useMovementDetections(
  options: UseMovementDetectionsOptions = {}
): UseMovementDetectionsReturn {
  const {
    autoFetch = false,
    roomId,
    recordingId,
    enableRealtime = false,
    realtimeStatusFilter,
    onRealtimeDetection,
    onRealtimeUpdate,
    onRealtimeDelete,
  } = options;

  const [detections, setDetections] = useState<MovementDetection[]>([]);
  const [currentDetection, setCurrentDetection] =
    useState<MovementDetection | null>(null);
  const [statistics, setStatistics] = useState<MovementDetectionStats | null>(
    null
  );
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isRealtimeConnected, setIsRealtimeConnected] = useState(false);

  const eventSourceRef = useRef<EventSource | null>(null);

  // Fetch detection by ID
  const fetchDetectionById = useCallback(async (detectionId: number) => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await movementDetectionService.getDetectionById(
        detectionId
      );

      if (response.error) {
        throw new Error(response.error);
      }

      setCurrentDetection(response.data);
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : "Failed to fetch detection";
      setError(errorMessage);
      console.error("Error fetching detection:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch detections by recording
  const fetchDetectionsByRecording = useCallback(
    async (recordingId: string) => {
      setIsLoading(true);
      setError(null);

      try {
        const response =
          await movementDetectionService.getDetectionsByRecording(recordingId);

        if (response.error) {
          throw new Error(response.error);
        }

        setDetections(response.data || []);
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to fetch detections by recording";
        setError(errorMessage);
        console.error("Error fetching detections by recording:", err);
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Fetch detections by room
  const fetchDetectionsByRoom = useCallback(async (roomId: string) => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await movementDetectionService.getDetectionsByRoom(
        roomId
      );

      if (response.error) {
        throw new Error(response.error);
      }

      setDetections(response.data || []);
    } catch (err) {
      const errorMessage =
        err instanceof Error
          ? err.message
          : "Failed to fetch detections by room";
      setError(errorMessage);
      console.error("Error fetching detections by room:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Fetch detections by movement type
  const fetchDetectionsByMovementType = useCallback(
    async (movementType: MovementType) => {
      setIsLoading(true);
      setError(null);

      try {
        const response =
          await movementDetectionService.getDetectionsByMovementType(
            movementType
          );

        if (response.error) {
          throw new Error(response.error);
        }

        setDetections(response.data || []);
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to fetch detections by movement type";
        setError(errorMessage);
        console.error("Error fetching detections by movement type:", err);
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Fetch detections by validation status
  const fetchDetectionsByStatus = useCallback(
    async (status: ValidationStatus, limit?: number) => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.getDetectionsByStatus(
          status,
          limit
        );

        if (response.error) {
          throw new Error(response.error);
        }

        setDetections(response.data || []);
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to fetch detections by status";
        setError(errorMessage);
        console.error("Error fetching detections by status:", err);
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Fetch statistics
  const fetchStatistics = useCallback(
    async (roomId?: string, recordingId?: string) => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.getStatistics(
          roomId,
          recordingId
        );

        if (response.error) {
          throw new Error(response.error);
        }

        setStatistics(response.data);
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to fetch statistics";
        setError(errorMessage);
        console.error("Error fetching statistics:", err);
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  // Create detection
  const createDetection = useCallback(
    async (data: CreateMovementDetection): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.createDetection(data);

        if (response.error) {
          throw new Error(response.error);
        }

        // Add to local state if not using realtime
        if (!enableRealtime && response.data) {
          setDetections((prev) => [response.data!, ...prev]);
        }

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to create detection";
        setError(errorMessage);
        console.error("Error creating detection:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime]
  );

  // Bulk create detections
  const bulkCreateDetections = useCallback(
    async (detections: CreateMovementDetection[]): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.bulkCreateDetections(
          detections
        );

        if (response.error) {
          throw new Error(response.error);
        }

        // Add to local state if not using realtime
        if (!enableRealtime && response.data) {
          setDetections((prev) => [...response.data!, ...prev]);
        }

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to bulk create detections";
        setError(errorMessage);
        console.error("Error bulk creating detections:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime]
  );

  // Update detection
  const updateDetection = useCallback(
    async (
      detectionId: number,
      data: UpdateMovementDetection
    ): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.updateDetection(
          detectionId,
          data
        );

        if (response.error) {
          throw new Error(response.error);
        }

        // Update local state if not using realtime
        if (!enableRealtime && response.data) {
          setDetections((prev) =>
            prev.map((d) => (d.id === detectionId ? response.data! : d))
          );
          if (currentDetection?.id === detectionId) {
            setCurrentDetection(response.data);
          }
        }

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to update detection";
        setError(errorMessage);
        console.error("Error updating detection:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime, currentDetection]
  );

  // Update validation status
  const updateValidationStatus = useCallback(
    async (detectionId: number, status: ValidationStatus): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.updateValidationStatus(
          detectionId,
          status
        );

        if (response.error) {
          throw new Error(response.error);
        }

        // Update local state if not using realtime
        if (!enableRealtime && response.data) {
          setDetections((prev) =>
            prev.map((d) => (d.id === detectionId ? response.data! : d))
          );
          if (currentDetection?.id === detectionId) {
            setCurrentDetection(response.data);
          }
        }

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to update validation status";
        setError(errorMessage);
        console.error("Error updating validation status:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime, currentDetection]
  );

  // Delete detection
  const deleteDetection = useCallback(
    async (detectionId: number): Promise<boolean> => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await movementDetectionService.deleteDetection(
          detectionId
        );

        if (response.error) {
          throw new Error(response.error);
        }

        // Remove from local state if not using realtime
        if (!enableRealtime) {
          setDetections((prev) => prev.filter((d) => d.id !== detectionId));
          if (currentDetection?.id === detectionId) {
            setCurrentDetection(null);
          }
        }

        return true;
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to delete detection";
        setError(errorMessage);
        console.error("Error deleting detection:", err);
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime, currentDetection]
  );

  // Delete detections by recording
  const deleteDetectionsByRecording = useCallback(
    async (recordingId: string): Promise<number> => {
      setIsLoading(true);
      setError(null);

      try {
        const response =
          await movementDetectionService.deleteDetectionsByRecording(
            recordingId
          );

        if (response.error) {
          throw new Error(response.error);
        }

        // Remove from local state if not using realtime
        if (!enableRealtime) {
          setDetections((prev) =>
            prev.filter((d) => d.recording_id !== recordingId)
          );
        }

        return response.data?.deleted_count || 0;
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : "Failed to delete detections by recording";
        setError(errorMessage);
        console.error("Error deleting detections by recording:", err);
        return 0;
      } finally {
        setIsLoading(false);
      }
    },
    [enableRealtime]
  );

  // Connect to realtime SSE
  const connectRealtime = useCallback(() => {
    if (eventSourceRef.current) {
      console.warn("EventSource already connected");
      return;
    }

    const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
    const realtimeUrl = movementDetectionService.getRealtimeUrl(
      roomId,
      recordingId,
      realtimeStatusFilter
    );
    const fullUrl = `${baseUrl}${realtimeUrl}`;

    console.log("🔌 Connecting to realtime:", fullUrl);

    const eventSource = new EventSource(fullUrl);

    eventSource.onopen = () => {
      console.log("✅ Realtime connected");
      setIsRealtimeConnected(true);
    };

    eventSource.onmessage = (event) => {
      try {
        const data: MovementDetectionRealtimeEvent = JSON.parse(event.data);

        // Handle different event types
        if (data.type === "connected") {
          console.log("📡 Realtime channel connected:", data.channel);
        } else if (data.type === "database_change") {
          if (data.event === "INSERT" && data.new) {
            console.log("➕ New detection:", data.new);
            setDetections((prev) => [data.new!, ...prev]);
            onRealtimeDetection?.(data.new);
          } else if (data.event === "UPDATE" && data.new) {
            console.log("🔄 Updated detection:", data.new);
            setDetections((prev) =>
              prev.map((d) => (d.id === data.new!.id ? data.new! : d))
            );
            onRealtimeUpdate?.(data.new);
          } else if (data.event === "DELETE" && data.id) {
            console.log("🗑️ Deleted detection:", data.id);
            setDetections((prev) => prev.filter((d) => d.id !== data.id));
            onRealtimeDelete?.(data.id);
          }
        } else if (data.type === "heartbeat") {
          // Heartbeat - connection alive
        }
      } catch (err) {
        console.error("Error parsing realtime event:", err);
      }
    };

    eventSource.onerror = (error) => {
      console.error("❌ Realtime error:", error);
      setIsRealtimeConnected(false);
      eventSource.close();
      eventSourceRef.current = null;
    };

    eventSourceRef.current = eventSource;
  }, [
    roomId,
    recordingId,
    realtimeStatusFilter,
    onRealtimeDetection,
    onRealtimeUpdate,
    onRealtimeDelete,
  ]);

  // Disconnect from realtime
  const disconnectRealtime = useCallback(() => {
    if (eventSourceRef.current) {
      console.log("👋 Disconnecting realtime");
      eventSourceRef.current.close();
      eventSourceRef.current = null;
      setIsRealtimeConnected(false);
    }
  }, []);

  // Clear error
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  // Auto-fetch on mount
  useEffect(() => {
    if (autoFetch) {
      if (recordingId) {
        fetchDetectionsByRecording(recordingId);
      } else if (roomId) {
        fetchDetectionsByRoom(roomId);
      }
    }
  }, [
    autoFetch,
    recordingId,
    roomId,
    fetchDetectionsByRecording,
    fetchDetectionsByRoom,
  ]);

  // Auto-connect realtime
  useEffect(() => {
    if (enableRealtime) {
      connectRealtime();
    }

    return () => {
      disconnectRealtime();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [enableRealtime, roomId, recordingId, realtimeStatusFilter]);

  return {
    detections,
    currentDetection,
    statistics,
    isLoading,
    error,
    isRealtimeConnected,
    fetchDetectionById,
    fetchDetectionsByRecording,
    fetchDetectionsByRoom,
    fetchDetectionsByMovementType,
    fetchDetectionsByStatus,
    fetchStatistics,
    createDetection,
    bulkCreateDetections,
    updateDetection,
    updateValidationStatus,
    deleteDetection,
    deleteDetectionsByRecording,
    connectRealtime,
    disconnectRealtime,
    clearError,
  };
}
