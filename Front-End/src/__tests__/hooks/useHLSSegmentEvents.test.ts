/**
 * Unit tests for useHLSSegmentEvents hook
 * Tests SSE connection and segment event handling
 */

import { useHLSSegmentEvents } from "@/hooks/useHLSSegmentEvents";
import { act, renderHook, waitFor } from "@testing-library/react";

// Mock EventSource
class MockEventSource {
  url: string;
  onopen: ((event: Event) => void) | null = null;
  onmessage: ((event: MessageEvent) => void) | null = null;
  onerror: ((event: Event) => void) | null = null;
  readyState: number = 0;
  CONNECTING = 0;
  OPEN = 1;
  CLOSED = 2;

  constructor(url: string) {
    this.url = url;
    // Simulate async connection
    setTimeout(() => {
      this.readyState = this.OPEN;
      if (this.onopen) {
        this.onopen(new Event("open"));
      }
    }, 0);
  }

  close() {
    this.readyState = this.CLOSED;
  }

  // Helper method to simulate receiving a message
  simulateMessage(data: any) {
    if (this.onmessage) {
      const event = new MessageEvent("message", {
        data: JSON.stringify(data),
      });
      this.onmessage(event);
    }
  }
}

// Replace global EventSource with mock
(global as any).EventSource = MockEventSource;

describe("useHLSSegmentEvents", () => {
  let mockHlsInstance: any;
  let mockVideoElement: HTMLVideoElement;

  beforeEach(() => {
    // Mock video element
    mockVideoElement = document.createElement("video");
    mockVideoElement.currentTime = 0;
    Object.defineProperty(mockVideoElement, "duration", {
      value: 30,
      writable: true,
      configurable: true,
    });
    Object.defineProperty(mockVideoElement, "paused", {
      value: false,
      writable: true,
      configurable: true,
    });
    mockVideoElement.play = jest.fn().mockResolvedValue(undefined);

    // Mock HLS instance
    mockHlsInstance = {
      loadSource: jest.fn(),
      startLoad: jest.fn(),
      stopLoad: jest.fn(),
      loadLevel: -1,
      media: mockVideoElement,
    };

    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe("SSE connection", () => {
    it("should not connect when roomId is null", () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: null,
          hls: mockHlsInstance,
        })
      );

      expect(result.current.isConnected).toBe(false);
      expect(result.current.status).toBe("Disconnected");
    });

    it("should connect to SSE endpoint when roomId is provided", async () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });
    });

    it("should update status to Connected on successful connection", async () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
        })
      );

      await waitFor(() => {
        expect(result.current.status).toContain("Connected");
      });
    });
  });

  describe("segment events", () => {
    it("should handle new_segment event", async () => {
      const onSegmentAdded = jest.fn();

      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          onSegmentAdded,
          debug: true,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      // Simulate receiving a new segment event
      const segmentEvent = {
        type: "new_segment",
        room_id: "AMB-001-ROOM-001",
        segment_name: "segment-001.ts",
        segment_number: 1,
        file_size: 1024000,
        timestamp: new Date().toISOString(),
      };

      // Get the EventSource instance and simulate message
      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(segmentEvent);
        });
      }

      await waitFor(() => {
        expect(onSegmentAdded).toHaveBeenCalledWith(segmentEvent);
        expect(result.current.lastSegment).toEqual(segmentEvent);
        expect(result.current.segmentCount).toBe(1);
      });
    });

    it("should reload HLS playlist when autoReload is enabled", async () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          autoReload: true,
          debug: true,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      // Simulate receiving a new segment event
      const segmentEvent = {
        type: "new_segment",
        room_id: "AMB-001-ROOM-001",
        segment_name: "segment-002.ts",
        segment_number: 2,
        file_size: 1024000,
        timestamp: new Date().toISOString(),
      };

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(segmentEvent);
        });
      }

      await waitFor(() => {
        // Verify proper reload sequence: stopLoad → startLoad
        expect(mockHlsInstance.stopLoad).toHaveBeenCalled();
        expect(mockHlsInstance.startLoad).toHaveBeenCalled();
        expect(mockHlsInstance.loadLevel).toBe(-1);
      });
    });

    it("should not reload HLS when autoReload is disabled", async () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          autoReload: false,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const segmentEvent = {
        type: "new_segment",
        room_id: "AMB-001-ROOM-001",
        segment_name: "segment-003.ts",
        segment_number: 3,
        file_size: 1024000,
        timestamp: new Date().toISOString(),
      };

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(segmentEvent);
        });
      }

      await waitFor(() => {
        expect(result.current.segmentCount).toBe(1);
      });

      // Should NOT reload
      expect(mockHlsInstance.stopLoad).not.toHaveBeenCalled();
      expect(mockHlsInstance.startLoad).not.toHaveBeenCalled();
    });

    it("should resume playback after reload if video was playing", async () => {
      // Initially set as not paused (playing)
      Object.defineProperty(mockVideoElement, "paused", {
        value: false,
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          autoReload: true,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const segmentEvent = {
        type: "new_segment",
        room_id: "AMB-001-ROOM-001",
        segment_name: "segment-004.ts",
        segment_number: 4,
        file_size: 1024000,
        timestamp: new Date().toISOString(),
      };

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(segmentEvent);
        });

        // Simulate video being paused after reload
        Object.defineProperty(mockVideoElement, "paused", {
          value: true,
          writable: true,
          configurable: true,
        });
      }

      await waitFor(() => {
        expect(mockVideoElement.play).toHaveBeenCalled();
      });
    });

    it("should handle connected event", async () => {
      const onConnected = jest.fn();

      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          onConnected,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const connectedEvent = {
        type: "connected",
        room_id: "AMB-001-ROOM-001",
        timestamp: new Date().toISOString(),
      };

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(connectedEvent);
        });
      }

      await waitFor(() => {
        expect(onConnected).toHaveBeenCalledWith(connectedEvent);
      });
    });

    it("should handle error event", async () => {
      const onError = jest.fn();

      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
          onError,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const errorEvent = {
        type: "error",
        room_id: "AMB-001-ROOM-001",
        error: "Test error message",
        timestamp: new Date().toISOString(),
      };

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        act(() => {
          eventSource.simulateMessage(errorEvent);
        });
      }

      await waitFor(() => {
        expect(onError).toHaveBeenCalledWith("Test error message");
        expect(result.current.error).toBe("Test error message");
      });
    });

    it("should increment segment count for each new segment", async () => {
      const { result } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const eventSource = (result.current as any).eventSourceRef?.current;
      if (eventSource) {
        // Send 3 segment events
        for (let i = 1; i <= 3; i++) {
          act(() => {
            eventSource.simulateMessage({
              type: "new_segment",
              room_id: "AMB-001-ROOM-001",
              segment_name: `segment-${String(i).padStart(3, "0")}.ts`,
              segment_number: i,
              file_size: 1024000,
              timestamp: new Date().toISOString(),
            });
          });
        }
      }

      await waitFor(() => {
        expect(result.current.segmentCount).toBe(3);
      });
    });
  });

  describe("cleanup", () => {
    it("should close EventSource on unmount", async () => {
      const { result, unmount } = renderHook(() =>
        useHLSSegmentEvents({
          roomId: "AMB-001-ROOM-001",
          hls: mockHlsInstance,
        })
      );

      await waitFor(() => {
        expect(result.current.isConnected).toBe(true);
      });

      const eventSource = (result.current as any).eventSourceRef?.current;
      const closeSpy = jest.spyOn(eventSource, "close");

      unmount();

      expect(closeSpy).toHaveBeenCalled();
    });
  });
});
