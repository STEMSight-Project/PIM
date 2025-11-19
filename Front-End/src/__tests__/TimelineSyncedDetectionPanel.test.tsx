import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock the api service used by the component
jest.mock('@/services/api', () => ({
  __esModule: true,
  api: {
    get: async (path: string) => {
      if (path.startsWith('/videos/recordings/')) {
        return {
          data: {
            id: 'rec-1',
            session_id: 'sess-1',
            session_start: '2025-11-17T12:00:00Z',
            created_at: '2025-11-17T12:00:00Z',
            duration: 120,
          },
          error: null,
        };
      }

      if (path.startsWith('/api/movement-detections/recording/')) {
        return { data: [], error: null };
      }

      if (path.startsWith('/ai-detections')) {
        return {
          data: [
            {
              id: 1,
              detection_type: 'fall',
              confidence_score: 0.9,
              created_at: '2025-11-17T12:00:02Z',
              frame_timestamp: '2',
              detection_data: { pose_landmarks: [{ x: 0, y: 0, z: 0, visibility: 1 }] },
            },
          ],
          error: null,
        };
      }

      return { data: null, error: 'Not found' };
    },
  },
}));

import TimelineSyncedDetectionPanel from '@/components/TimelineSyncedDetectionPanel';

describe('TimelineSyncedDetectionPanel', () => {
  test('loads detections and displays summary', async () => {
    render(
      <TimelineSyncedDetectionPanel
        recordingId="rec-1"
        currentTimestamp={2}
        timeWindow={2}
        maxDetections={5}
      />
    );

    // Wait for the header and for detection summary to appear
    await waitFor(() => expect(screen.getByText(/Timeline Detections/i)).toBeInTheDocument());

    // Because the mock returns one AI detection at timestamp 2, the panel should show it
    await waitFor(() => expect(screen.getByText(/fall/i)).toBeInTheDocument());
  });
});
