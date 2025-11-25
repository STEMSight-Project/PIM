import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock hooks used by the component
jest.mock('@/hooks/useStreaming', () => ({
  __esModule: true,
  useStreaming: () => ({
    videoRef: { current: document.createElement('video') },
    isConnected: true,
    isConnecting: false,
    startStreaming: jest.fn(),
    stopStreaming: jest.fn(),
    error: null,
    userFriendlyStatus: 'connected',
    isWaitingForData: false,
    poseLandmarks: null,
    prediction: { predicted_class: 'fall', confidence: 0.85, top3: [] },
  }),
}));

jest.mock('@/hooks/useHLS', () => ({
  __esModule: true,
  useHLS: () => ({
    videoRef: { current: document.createElement('video') },
    hls: null,
    isLoading: false,
    isHLSReady: false,
    play: jest.fn(),
    pause: jest.fn(),
    seek: jest.fn(),
    error: null,
    recordingStatus: null,
  }),
}));

// Minimal mocks for imported child components
jest.mock('@/components/TimelineSyncedDetectionPanel', () => ({
  __esModule: true,
  default: () => <div>Timeline Panel Mock</div>,
}));

jest.mock('@/components/SkeletonOverlay', () => ({
  __esModule: true,
  SkeletonOverlay: () => <div>Skeleton Mock</div>,
}));

import { HybridStreamPlayer } from '@/components/HybridStreamPlayer';

describe('HybridStreamPlayer', () => {
  test('renders streaming badge when live connected', () => {
    render(<HybridStreamPlayer ambulanceId="AMB-1" roomId="ROOM-1" debug />);

    // STREAMING badge should be visible in the DOM
    const badge = screen.getByText(/STREAMING/i);
    expect(badge).toBeInTheDocument();
  });

  test('play/pause button exists and toggles playback logic', () => {
    render(<HybridStreamPlayer ambulanceId="AMB-1" roomId="ROOM-1" debug />);

    const button = screen.getByRole('button', { name: /Pause|Play/i });
    expect(button).toBeInTheDocument();
    fireEvent.click(button);
    // No runtime errors expected; hooks are mocked
  });
});
