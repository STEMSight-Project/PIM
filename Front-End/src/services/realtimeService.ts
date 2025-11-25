/**
 * Realtime Service for Frontend
 * Handles Server-Sent Events (SSE) connections to backend realtime endpoints
 */

import { getApiBaseUrl } from "@/lib/apiBase";

export interface RealtimeEvent {
  type: "connected" | "database_change" | "heartbeat" | "error";
  timestamp?: number;
  channel?: string;
  table?: string;
  event?: "INSERT" | "UPDATE" | "DELETE";
  new?: Record<string, any>;
  old?: Record<string, any>;
  error?: string;
  message?: string;
}

export interface RealtimeOptions {
  autoReconnect?: boolean;
  reconnectDelay?: number;
  maxReconnectAttempts?: number;
}

export type RealtimeEventHandler = (event: RealtimeEvent) => void;

class RealtimeConnection {
  private eventSource: EventSource | null = null;
  private reconnectTimer: NodeJS.Timeout | null = null;
  private reconnectAttempts = 0;
  private isConnecting = false;
  private isClosed = false;

  constructor(
    private url: string,
    private onMessage: RealtimeEventHandler,
    private onError?: (error: Event) => void,
    private onOpen?: () => void,
    private options: RealtimeOptions = {}
  ) {
    this.options = {
      autoReconnect: true,
      reconnectDelay: 3000,
      maxReconnectAttempts: 5,
      ...options,
    };
  }

  connect(): void {
    if (this.isConnecting || this.eventSource) {
      return;
    }

    this.isConnecting = true;
    this.isClosed = false;

    try {
      this.eventSource = new EventSource(this.url);

      this.eventSource.onopen = () => {
        console.log(`🔗 Connected to realtime stream: ${this.url}`);
        this.isConnecting = false;
        this.reconnectAttempts = 0;
        this.onOpen?.();
      };

      this.eventSource.onmessage = (event) => {
        try {
          const data: RealtimeEvent = JSON.parse(event.data);
          this.onMessage(data);
        } catch (error) {
          console.error("Failed to parse SSE message:", error, event.data);
        }
      };

      this.eventSource.onerror = (error) => {
        console.error(`❌ SSE connection error for ${this.url}:`, error);
        this.isConnecting = false;
        this.onError?.(error);

        if (this.options.autoReconnect && !this.isClosed) {
          this.handleReconnect();
        }
      };
    } catch (error) {
      console.error("Failed to create EventSource:", error);
      this.isConnecting = false;
      this.onError?.(error as Event);
    }
  }

  private handleReconnect(): void {
    if (
      this.reconnectAttempts >= (this.options.maxReconnectAttempts || 5) ||
      this.isClosed
    ) {
      console.log(`🛑 Max reconnection attempts reached for ${this.url}`);
      return;
    }

    this.reconnectAttempts++;
    const delay = this.options.reconnectDelay || 3000;

    console.log(
      `🔄 Attempting to reconnect to ${this.url} (attempt ${this.reconnectAttempts}) in ${delay}ms`
    );

    this.reconnectTimer = setTimeout(() => {
      this.cleanup();
      this.connect();
    }, delay);
  }

  private cleanup(): void {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }

    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
  }

  close(): void {
    console.log(`📴 Closing realtime connection: ${this.url}`);
    this.isClosed = true;
    this.cleanup();
  }

  get readyState(): number {
    return this.eventSource?.readyState ?? EventSource.CLOSED;
  }

  get isConnected(): boolean {
    return this.readyState === EventSource.OPEN;
  }
}

class RealtimeService {
  private baseUrl: string;
  private connections = new Map<string, RealtimeConnection>();

  constructor() {
    this.baseUrl = getApiBaseUrl();
  }

  /**
   * Subscribe to real-time updates for streaming sessions
   */
  subscribeToSessions(
    onMessage: RealtimeEventHandler,
    patientId?: string,
    options?: RealtimeOptions
  ): RealtimeConnection {
    const params = new URLSearchParams();
    if (patientId) {
      params.append("patient_id", patientId);
    }

    const url = `${this.baseUrl}/realtime/sessions?${params.toString()}`;
    const connectionKey = `sessions-${patientId || "all"}`;

    // Close existing connection if any
    this.unsubscribe(connectionKey);

    const connection = new RealtimeConnection(
      url,
      onMessage,
      (error) => {
        console.error("Sessions SSE error:", error);
      },
      () => {
        console.log("Sessions SSE connected");
      },
      options
    );

    this.connections.set(connectionKey, connection);
    connection.connect();

    return connection;
  }

  /**
   * Subscribe to real-time updates for streaming rooms
   */
  subscribeToRooms(
    onMessage: RealtimeEventHandler,
    options?: RealtimeOptions
  ): RealtimeConnection {
    const url = `${this.baseUrl}/realtime/rooms`;
    const connectionKey = "rooms";

    // Close existing connection if any
    this.unsubscribe(connectionKey);

    const connection = new RealtimeConnection(
      url,
      onMessage,
      (error) => {
        console.error("Rooms SSE error:", error);
      },
      () => {
        console.log("Rooms SSE connected");
      },
      options
    );

    this.connections.set(connectionKey, connection);
    connection.connect();

    return connection;
  }

  /**
   * Subscribe to real-time updates for a specific patient status
   */
  subscribeToPatientStatus(
    patientId: string,
    onMessage: RealtimeEventHandler,
    options?: RealtimeOptions
  ): RealtimeConnection {
    const url = `${this.baseUrl}/realtime/patient/${patientId}/status`;
    const connectionKey = `patient-${patientId}`;

    // Close existing connection if any
    this.unsubscribe(connectionKey);

    const connection = new RealtimeConnection(
      url,
      onMessage,
      (error) => {
        console.error(`Patient ${patientId} SSE error:`, error);
      },
      () => {
        console.log(`Patient ${patientId} SSE connected`);
      },
      options
    );

    this.connections.set(connectionKey, connection);
    connection.connect();

    return connection;
  }

  /**
   * Subscribe to test realtime endpoint for debugging
   */
  subscribeToTest(
    onMessage: RealtimeEventHandler,
    patientId?: string,
    options?: RealtimeOptions
  ): RealtimeConnection {
    const params = new URLSearchParams();
    if (patientId) {
      params.append("patient_id", patientId);
    }

    const url = `${this.baseUrl}/realtime/test?${params.toString()}`;
    const connectionKey = `test-${patientId || "default"}`;

    // Close existing connection if any
    this.unsubscribe(connectionKey);

    const connection = new RealtimeConnection(
      url,
      onMessage,
      (error) => {
        console.error("Test SSE error:", error);
      },
      () => {
        console.log("Test SSE connected");
      },
      options
    );

    this.connections.set(connectionKey, connection);
    connection.connect();

    return connection;
  }

  /**
   * Unsubscribe from a specific connection
   */
  unsubscribe(connectionKey: string): void {
    const connection = this.connections.get(connectionKey);
    if (connection) {
      connection.close();
      this.connections.delete(connectionKey);
    }
  }

  /**
   * Unsubscribe from all connections
   */
  unsubscribeAll(): void {
    this.connections.forEach((connection) => {
      connection.close();
    });
    this.connections.clear();
  }

  /**
   * Get connection status for debugging
   */
  getConnectionStatus(): Record<
    string,
    { isConnected: boolean; readyState: number }
  > {
    const status: Record<string, { isConnected: boolean; readyState: number }> =
      {};

    this.connections.forEach((connection, key) => {
      status[key] = {
        isConnected: connection.isConnected,
        readyState: connection.readyState,
      };
    });

    return status;
  }

  /**
   * Check realtime service health
   */
  async checkHealth(): Promise<{
    status: string;
    service: string;
    environment: string;
    active_subscriptions: number;
    active_queues: number;
  }> {
    try {
      const response = await fetch(`${this.baseUrl}/realtime/health`);

      if (!response.ok) {
        throw new Error(`Health check failed: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Realtime health check failed:", error);
      throw error;
    }
  }
}

// Global singleton instance
export const realtimeService = new RealtimeService();

// Export for dependency injection or testing
export { RealtimeConnection, RealtimeService };

// Convenience exports
export default realtimeService;
