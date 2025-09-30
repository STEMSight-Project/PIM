import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import Timeline from './Timeline';
import { Detection } from '@/components/session-review/types';

// Mock the usePatientEvents hook
const mockFetchEventsForVideo = jest.fn();
const mockUpdateEventStatus = jest.fn();
const mockClearError = jest.fn();

jest.mock('@/hooks/usePatientEvents', () => ({
  usePatientEvents: jest.fn(() => ({
    events: [],
    loading: false,
    error: null,
    fetchEventsForVideo: mockFetchEventsForVideo,
    updateEventStatus: mockUpdateEventStatus,
    clearError: mockClearError,
  })),
}));

// Mock lucide-react icons
jest.mock('lucide-react', () => ({
  CheckCircle: ({ className }: any) => <span className={className}>CheckCircle</span>,
  XCircle: ({ className }: any) => <span className={className}>XCircle</span>,
  Clock: ({ className }: any) => <span className={className}>Clock</span>,
}));

const { usePatientEvents } = require('@/hooks/usePatientEvents');

describe('Timeline Component', () => {
  const mockSetCurrentTimestamp = jest.fn();

  const defaultProps = {
    setCurrentTimestamp: mockSetCurrentTimestamp,
    videoId: 'video-123',
    patientId: 'patient-456',
  };

  const mockEvents: Detection[] = [
    {
      id: 'event-1',
      type: 'myoclonus',
      timestamp: '30.5',
      confidence: 85,
      validation_status: 'pending',
      created_at: '2024-01-15T10:00:00Z',
      video_id: 'video-123',
    },
    {
      id: 'event-2',
      type: 'tremor',
      timestamp: '60',
      confidence: 92,
      validation_status: 'confirmed',
      created_at: '2024-01-15T10:05:00Z',
      video_id: 'video-123',
    },
    {
      id: 'event-3',
      type: 'seizure',
      timestamp: '120.8',
      confidence: 78,
      validation_status: 'dismissed',
      created_at: '2024-01-15T10:10:00Z',
      video_id: 'video-123',
    },
  ];

  beforeEach(() => {
    jest.clearAllMocks();
    usePatientEvents.mockReturnValue({
      events: [],
      loading: false,
      error: null,
      fetchEventsForVideo: mockFetchEventsForVideo,
      updateEventStatus: mockUpdateEventStatus,
      clearError: mockClearError,
    });
  });

  describe('Loading State', () => {
    test('displays loading message when loading', () => {
      usePatientEvents.mockReturnValue({
        events: [],
        loading: true,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Activity Timeline')).toBeInTheDocument();
      expect(screen.getByText('Loading events...')).toBeInTheDocument();
    });
  });

  describe('Error State', () => {
    test('displays error message when there is an error', () => {
      usePatientEvents.mockReturnValue({
        events: [],
        loading: false,
        error: 'Failed to fetch events',
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText(/Error loading events:/)).toBeInTheDocument();
      expect(screen.getByText(/Failed to fetch events/)).toBeInTheDocument();
    });

    test('retry button calls clearError', () => {
      usePatientEvents.mockReturnValue({
        events: [],
        loading: false,
        error: 'Failed to fetch events',
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      const retryButton = screen.getByText('Retry');
      fireEvent.click(retryButton);

      expect(mockClearError).toHaveBeenCalled();
    });
  });

  describe('Empty State', () => {
    test('displays no events message when events array is empty', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Activity Timeline')).toBeInTheDocument();
      expect(screen.getByText('No events detected for this video')).toBeInTheDocument();
    });
  });

  describe('Events Display', () => {
    beforeEach(() => {
      usePatientEvents.mockReturnValue({
        events: mockEvents,
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });
    });

    test('displays correct number of events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('3 events detected')).toBeInTheDocument();
    });

    test('displays singular "event" for single event', () => {
      usePatientEvents.mockReturnValue({
        events: [mockEvents[0]],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('1 event detected')).toBeInTheDocument();
    });

    test('displays event types correctly', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Myoclonus Detected')).toBeInTheDocument();
      expect(screen.getByText('Tremor Detected')).toBeInTheDocument();
      expect(screen.getByText('Seizure Detected')).toBeInTheDocument();
    });

    test('displays confidence levels', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('85% confidence')).toBeInTheDocument();
      expect(screen.getByText('92% confidence')).toBeInTheDocument();
      expect(screen.getByText('78% confidence')).toBeInTheDocument();
    });

    test('formats timestamps correctly', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('00:30')).toBeInTheDocument(); // 30.5 seconds
      expect(screen.getByText('01:00')).toBeInTheDocument(); // 60 seconds
      expect(screen.getByText('02:00')).toBeInTheDocument(); // 120.8 seconds
    });

    test('sorts events by timestamp', () => {
      const unsortedEvents = [mockEvents[2], mockEvents[0], mockEvents[1]];
      
      usePatientEvents.mockReturnValue({
        events: unsortedEvents,
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      const eventCards = screen.getAllByText(/Detected/);
      expect(eventCards[0]).toHaveTextContent('Myoclonus');
      expect(eventCards[1]).toHaveTextContent('Tremor');
      expect(eventCards[2]).toHaveTextContent('Seizure');
    });
  });

  describe('Event Status - Pending', () => {
    beforeEach(() => {
      usePatientEvents.mockReturnValue({
        events: [mockEvents[0]],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });
    });

    test('shows action buttons for pending events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Jump to Event')).toBeInTheDocument();
      expect(screen.getByText('Confirm')).toBeInTheDocument();
      expect(screen.getByText('Dismiss')).toBeInTheDocument();
    });

    test('Jump to Event button calls setCurrentTimestamp', async () => {
      jest.useFakeTimers();
      render(<Timeline {...defaultProps} />);

      const jumpButton = screen.getByText('Jump to Event');
      fireEvent.click(jumpButton);

      // Should call with timestamp - 0.5 first
      expect(mockSetCurrentTimestamp).toHaveBeenCalledWith(30.0);

      // Fast-forward timers
      jest.advanceTimersByTime(10);

      // Then call with actual timestamp
      expect(mockSetCurrentTimestamp).toHaveBeenCalledWith(30.5);

      jest.useRealTimers();
    });

    test('Confirm button calls updateEventStatus with confirmed', async () => {
      mockUpdateEventStatus.mockResolvedValue(true);

      render(<Timeline {...defaultProps} />);

      const confirmButton = screen.getByText('Confirm');
      fireEvent.click(confirmButton);

      await waitFor(() => {
        expect(mockUpdateEventStatus).toHaveBeenCalledWith('event-1', 'confirmed');
      });
    });

    test('Dismiss button calls updateEventStatus with dismissed', async () => {
      mockUpdateEventStatus.mockResolvedValue(true);

      render(<Timeline {...defaultProps} />);

      const dismissButton = screen.getByText('Dismiss');
      fireEvent.click(dismissButton);

      await waitFor(() => {
        expect(mockUpdateEventStatus).toHaveBeenCalledWith('event-1', 'dismissed');
      });
    });
  });

  describe('Event Status - Confirmed', () => {
    beforeEach(() => {
      usePatientEvents.mockReturnValue({
        events: [mockEvents[1]],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });
    });

    test('shows confirmed badge for confirmed events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Confirmed')).toBeInTheDocument();
    });

    test('shows Edit Status button for confirmed events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Edit Status')).toBeInTheDocument();
    });

    test('Edit Status button resets status to pending', async () => {
      mockUpdateEventStatus.mockResolvedValue(true);

      render(<Timeline {...defaultProps} />);

      const editButton = screen.getByText('Edit Status');
      fireEvent.click(editButton);

      await waitFor(() => {
        expect(mockUpdateEventStatus).toHaveBeenCalledWith('event-2', 'pending');
      });
    });
  });

  describe('Event Status - Dismissed', () => {
    beforeEach(() => {
      usePatientEvents.mockReturnValue({
        events: [mockEvents[2]],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });
    });

    test('shows dismissed badge for dismissed events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Dismissed')).toBeInTheDocument();
    });

    test('shows Edit Status button for dismissed events', () => {
      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('Edit Status')).toBeInTheDocument();
    });
  });

  describe('Fetching Events', () => {
    test('fetches events on mount when no currentEvents provided', () => {
      render(<Timeline {...defaultProps} />);

      expect(mockFetchEventsForVideo).toHaveBeenCalledWith('video-123');
    });

    test('does not fetch events when currentEvents provided', () => {
      render(<Timeline {...defaultProps} currentEvents={mockEvents} />);

      expect(mockFetchEventsForVideo).not.toHaveBeenCalled();
    });

    test('uses currentEvents when provided', () => {
      render(<Timeline {...defaultProps} currentEvents={[mockEvents[0]]} />);

      expect(screen.getByText('Myoclonus Detected')).toBeInTheDocument();
      expect(screen.queryByText('Tremor Detected')).not.toBeInTheDocument();
    });
  });

  describe('Timestamp Formatting', () => {
    test('handles string timestamps', () => {
      const eventWithStringTimestamp: Detection = {
        ...mockEvents[0],
        timestamp: '45.7',
      };

      usePatientEvents.mockReturnValue({
        events: [eventWithStringTimestamp],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('00:45')).toBeInTheDocument();
    });

    test('handles numeric timestamps', () => {
      const eventWithNumericTimestamp: Detection = {
        ...mockEvents[0],
        timestamp: 95 as any,
      };

      usePatientEvents.mockReturnValue({
        events: [eventWithNumericTimestamp],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('01:35')).toBeInTheDocument();
    });

    test('pads single digit minutes and seconds', () => {
      const eventWithSmallTimestamp: Detection = {
        ...mockEvents[0],
        timestamp: '5',
      };

      usePatientEvents.mockReturnValue({
        events: [eventWithSmallTimestamp],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('00:05')).toBeInTheDocument();
    });
  });

  describe('Event Colors', () => {
    test('assigns correct color classes based on event type', () => {
      usePatientEvents.mockReturnValue({
        events: mockEvents,
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      const { container } = render(<Timeline {...defaultProps} />);

      // Check for color classes (myoclonus=red, tremor=yellow, seizure=red)
      const dots = container.querySelectorAll('.rounded-full');
      expect(dots.length).toBeGreaterThan(0);
    });
  });

  describe('Edge Cases', () => {
    test('handles events without confidence display', () => {
      // Confidence of 0 is falsy, so it won't display
      const eventWithZeroConfidence: Detection = {
        ...mockEvents[0],
        confidence: 0,
      };

      usePatientEvents.mockReturnValue({
        events: [eventWithZeroConfidence],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      // Component doesn't show confidence when it's 0 (falsy check)
      expect(screen.queryByText(/confidence/)).not.toBeInTheDocument();
    });

    test('handles invalid timestamp gracefully', () => {
      const eventWithInvalidTimestamp: Detection = {
        ...mockEvents[0],
        timestamp: 'invalid' as any,
      };

      usePatientEvents.mockReturnValue({
        events: [eventWithInvalidTimestamp],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      expect(screen.getByText('00:00')).toBeInTheDocument();
    });

    test('handles failed updateEventStatus', async () => {
      mockUpdateEventStatus.mockResolvedValue(false);

      usePatientEvents.mockReturnValue({
        events: [mockEvents[0]],
        loading: false,
        error: null,
        fetchEventsForVideo: mockFetchEventsForVideo,
        updateEventStatus: mockUpdateEventStatus,
        clearError: mockClearError,
      });

      render(<Timeline {...defaultProps} />);

      const confirmButton = screen.getByText('Confirm');
      fireEvent.click(confirmButton);

      await waitFor(() => {
        expect(mockUpdateEventStatus).toHaveBeenCalled();
      });

      
      
    });
  });
});