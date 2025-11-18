/**
 * Hook for paginated ambulance sessions with infinite scroll
 */

import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/services/api";
import type { AmbulanceSession } from "@/types";

interface PaginatedSessionsResponse {
  data: AmbulanceSession[];
  total: number;
  limit: number;
  offset: number;
  has_more: boolean;
}

interface UsePaginatedSessionsOptions {
  pageSize?: number;
  ambulanceId?: string;
  isActive?: boolean;
}

export function usePaginatedSessions(
  options: UsePaginatedSessionsOptions = {}
) {
  const { pageSize = 20, ambulanceId, isActive } = options;

  const [sessions, setSessions] = useState<AmbulanceSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [offset, setOffset] = useState(0);
  const [total, setTotal] = useState(0);

  const isMountedRef = useRef(true);

  useEffect(() => {
    isMountedRef.current = true;
    return () => {
      isMountedRef.current = false;
    };
  }, []);

  const loadSessions = useCallback(
    async (reset: boolean = false) => {
      try {
        if (reset) {
          setIsLoading(true);
          setOffset(0);
          setSessions([]);
        } else {
          setIsLoadingMore(true);
        }
        setError(null);

        const currentOffset = reset ? 0 : offset;

        // Build query params
        const params = new URLSearchParams();
        params.append("limit", pageSize.toString());
        params.append("offset", currentOffset.toString());
        if (ambulanceId) params.append("ambulance_id", ambulanceId);
        if (isActive !== undefined)
          params.append("is_active", isActive.toString());

        const response = await api.get<PaginatedSessionsResponse>(
          `/ambulance-streaming/ambulance-sessions-paginated?${params.toString()}`
        );

        if (!isMountedRef.current) return;

        if (response.error || !response.data) {
          setError(response.error || "Failed to load sessions");
          return;
        }

        const result = response.data;

        if (reset) {
          setSessions(result.data);
        } else {
          setSessions((prev) => [...prev, ...result.data]);
        }

        setOffset(currentOffset + pageSize);
        setHasMore(result.has_more);
        setTotal(result.total);
      } catch (err) {
        if (!isMountedRef.current) return;
        setError(
          err instanceof Error ? err.message : "Failed to load sessions"
        );
      } finally {
        if (isMountedRef.current) {
          setIsLoading(false);
          setIsLoadingMore(false);
        }
      }
    },
    [offset, pageSize, ambulanceId, isActive]
  );

  // Initial load
  useEffect(() => {
    loadSessions(true);
  }, [ambulanceId, isActive]); // Reload when filters change

  const loadMore = useCallback(() => {
    if (!isLoadingMore && hasMore && !isLoading) {
      loadSessions(false);
    }
  }, [isLoadingMore, hasMore, isLoading, loadSessions]);

  const refresh = useCallback(async () => {
    await loadSessions(true);
  }, [loadSessions]);

  return {
    sessions,
    isLoading,
    isLoadingMore,
    error,
    hasMore,
    total,
    loadMore,
    refresh,
  };
}
