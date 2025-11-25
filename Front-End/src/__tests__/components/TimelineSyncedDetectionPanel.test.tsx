/**
 * Tests for TimelineSyncedDetectionPanel component
 * Verifies summary states, detection rendering, and interaction callbacks
 */

import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import "@testing-library/jest-dom";
import TimelineSyncedDetectionPanel from "@/components/TimelineSyncedDetectionPanel";
import { api } from "@/services/api";
import { vi } from "vitest";

vi.mock("@/services/api", () => ({
  api: {
    get: vi.fn(),
  },
}));

const mockApiGet = api.get as any;

interface RecordingStub {
  id: string;
  created_at: string;
  session_start?: string;
  session_end?: string;
  duration?: number | null;
  session_id?: string;
}

const baseRecording: RecordingStub = {
  id: "rec-1",
  created_at: "2025-01-01T00:00:00.000Z",
  session_start: "2025-01-01T00:00:00.000Z",
  session_end: "2025-01-01T00:05:00.000Z",
  duration: 300,
  session_id: undefined,
};

const createDetection = (overrides: Partial<Record<string, unknown>> = {}) => ({
  id: overrides.id ?? "ai-detection",
  detection_type: overrides.detection_type ?? "ballistic",
  confidence_score: overrides.confidence_score ?? 0.93,
  frame_timestamp: overrides.frame_timestamp ?? "1.5",
  created_at: overrides.created_at ?? "2025-01-01T00:00:01.500Z",
  room_id: overrides.room_id ?? "room-1",
  detection_data: overrides.detection_data ?? {
    pose_landmarks: [
      { x: 0.1, y: 0.2, z: 0, visibility: 0.9 },
      { x: 0.2, y: 0.3, z: 0, visibility: 0.8 },
    ],
    all_probabilities: {
      ballistic: 0.93,
      tremor: 0.03,
    },
  },
});

const enqueueFetchResponses = ({
  recording = baseRecording,
  movement = [],
  ai = [],
  aiFallback = null,
}: {
  recording?: typeof baseRecording;
  movement?: any[];
  ai?: any[];
  aiFallback?: any[] | null;
} = {}) => {
  mockApiGet.mockResolvedValueOnce({ data: recording, error: null });
  mockApiGet.mockResolvedValueOnce({ data: movement, error: null });
  mockApiGet.mockResolvedValueOnce({ data: ai, error: null });
  if (aiFallback !== null) {
    mockApiGet.mockResolvedValueOnce({ data: aiFallback, error: null });
  }
};

describe("TimelineSyncedDetectionPanel", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders detections and supports interactions when data is returned", async () => {
    const detection = createDetection();
    enqueueFetchResponses({ ai: [detection] });

    const onSeekToTime = vi.fn();
    const onLandmarksChange = vi.fn();

    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={1.5}
        onSeekToTime={onSeekToTime}
        onLandmarksChange={onLandmarksChange}
      />
    );

    expect(await screen.findByText(/Timeline Detections/i)).toBeInTheDocument();
    await waitFor(() => {
      expect(
        screen.getByText("1 detection near current time")
      ).toBeInTheDocument();
    });

    const detectionLabel = await screen.findByText(/ballistic/i);
    fireEvent.click(detectionLabel);

    expect(onSeekToTime).toHaveBeenCalledTimes(1);
    const invokedTimestamp = (onSeekToTime.mock.calls[0] ?? [0])[0];
    expect(invokedTimestamp).toBeCloseTo(1.5, 3);

    await waitFor(() => {
      expect(onLandmarksChange).toHaveBeenCalledWith(
        expect.arrayContaining([expect.objectContaining({ x: 0.1 })])
      );
    });
  });

  it("shows awaiting state when no detections are available", async () => {
    enqueueFetchResponses({ ai: [] });

    render(
      <TimelineSyncedDetectionPanel recordingId="rec-1" currentTimestamp={0} />
    );

    await waitFor(() => {
      expect(screen.getByText("Awaiting AI detections")).toBeInTheDocument();
    });

    expect(
      screen.getByText(/No detections available yet/i)
    ).toBeInTheDocument();
  });

  it("indicates when detections exist but none are near the active timestamp", async () => {
    const farDetection = createDetection({ frame_timestamp: "42" });
    enqueueFetchResponses({ ai: [farDetection] });

    render(
      <TimelineSyncedDetectionPanel recordingId="rec-1" currentTimestamp={0} />
    );

    await screen.findByText(/ballistic/i);

    await waitFor(() => {
      expect(
        screen.getByText("No detections near current time")
      ).toBeInTheDocument();
    });

    expect(screen.getByText(/ballistic/i)).toBeInTheDocument();
  });

  it("suppresses UI when showPanel is false but still performs data fetch", async () => {
    enqueueFetchResponses({ ai: [createDetection()] });

    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={1}
        showPanel={false}
      />
    );

    expect(screen.queryByText(/Timeline Detections/i)).not.toBeInTheDocument();

    await waitFor(() => {
      expect(mockApiGet).toHaveBeenCalledTimes(3);
    });
  });

  it("surfaced API errors in the panel", async () => {
    mockApiGet.mockResolvedValueOnce({ data: null, error: "not found" });

    render(
      <TimelineSyncedDetectionPanel recordingId="rec-1" currentTimestamp={0} />
    );

    await waitFor(() => {
      expect(
        screen.getByText(/Recording rec-1 not found/i)
      ).toBeInTheDocument();
    });
  });

  it("invokes onDetectionsReady with converted detections", async () => {
    const detection = createDetection();
    enqueueFetchResponses({ ai: [detection] });
    const onDetectionsReady = vi.fn();

    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={1.5}
        onDetectionsReady={onDetectionsReady}
      />
    );

    await waitFor(() => {
      expect(onDetectionsReady).toHaveBeenLastCalledWith(
        expect.arrayContaining([
          expect.objectContaining({
            id: detection.id,
            timestamp: Number(detection.frame_timestamp),
          }),
        ])
      );
    });
  });

  it("supplies prediction summaries via onPredictionChange", async () => {
    const detection = createDetection();
    enqueueFetchResponses({ ai: [detection] });
    const onPredictionChange = vi.fn();

    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={1.5}
        onPredictionChange={onPredictionChange}
      />
    );

    await waitFor(() => {
      expect(onPredictionChange).toHaveBeenCalledWith(
        expect.objectContaining({
          predicted_class: detection.detection_type,
          confidence: detection.confidence_score,
          top3: expect.arrayContaining([
            expect.objectContaining({ class: "ballistic", confidence: 0.93 }),
          ]),
        })
      );
    });
  });

  it("falls back to session-based AI query when recording data is empty", async () => {
    enqueueFetchResponses({
      recording: { ...baseRecording, session_id: "session-42" },
      ai: [],
      aiFallback: [createDetection({ frame_timestamp: "3" })],
    });

    render(
      <TimelineSyncedDetectionPanel recordingId="rec-1" currentTimestamp={3} />
    );

    await waitFor(() => {
      expect(mockApiGet).toHaveBeenCalledWith(
        "/ai-detections?session_id=session-42&limit=500"
      );
    });

    expect(await screen.findByText(/ballistic/i)).toBeInTheDocument();
  });

  it("normalizes negative timestamps to zero for display", async () => {
    enqueueFetchResponses({
      ai: [createDetection({ frame_timestamp: "-1.2" })],
    });

    render(
      <TimelineSyncedDetectionPanel recordingId="rec-1" currentTimestamp={0} />
    );

    const zeroTimestamp = await screen.findByText(/0.0s/i);
    expect(zeroTimestamp).toBeInTheDocument();
  });

  it("clears prediction callback when detections are outside the time window", async () => {
    enqueueFetchResponses({ ai: [createDetection({ frame_timestamp: "10" })] });
    const onPredictionChange = vi.fn();

    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={50}
        onPredictionChange={onPredictionChange}
      />
    );

    await waitFor(() => {
      expect(onPredictionChange).toHaveBeenCalledWith(null);
    });
  });
});
