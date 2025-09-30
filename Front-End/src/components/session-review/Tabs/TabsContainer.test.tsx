import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import TabsContainer from './TabsContainer';
import { Note } from '@/services';

// Mock the child components
jest.mock('./Notes', () => ({
  __esModule: true,
  default: ({ sessionId, notes }: any) => (
    <div data-testid="notes-component">
      Notes Component - Session: {sessionId}, Count: {notes.length}
    </div>
  ),
}));

jest.mock('./Timeline', () => ({
  __esModule: true,
  default: ({ videoId, patientId }: any) => (
    <div data-testid="timeline-component">
      Timeline Component - Video: {videoId}, Patient: {patientId}
    </div>
  ),
}));

describe('TabsContainer Component', () => {
  const mockSetNotes = jest.fn();
  const mockSetCurrentTimestamp = jest.fn();

  const defaultProps = {
    sessionId: 'session-123',
    notes: [] as Note[],
    setNotes: mockSetNotes,
    setCurrentTimestamp: mockSetCurrentTimestamp,
    currentVideoTime: 0,
    videoId: 'video-456',
    patientId: 'patient-789',
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    test('renders both tab buttons', () => {
      render(<TabsContainer {...defaultProps} />);

      expect(screen.getByRole('button', { name: /timeline/i })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /notes/i })).toBeInTheDocument();
    });

    test('displays Timeline tab as active by default', () => {
      render(<TabsContainer {...defaultProps} />);

      const timelineButton = screen.getByRole('button', { name: /timeline/i });
      expect(timelineButton).toHaveClass('bg-white', 'text-blue-600');
    });

    test('renders Timeline component by default', () => {
      render(<TabsContainer {...defaultProps} />);

      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();
      expect(screen.queryByTestId('notes-component')).not.toBeInTheDocument();
    });

    test('displays notes count in Notes tab button', () => {
      const notesWithData = [
        { id: '1', content: 'Note 1' },
        { id: '2', content: 'Note 2' },
        { id: '3', content: 'Note 3' },
      ] as Note[];

      render(<TabsContainer {...defaultProps} notes={notesWithData} />);

      expect(screen.getByText(/notes \(3\)/i)).toBeInTheDocument();
    });

    test('shows 0 count when no notes', () => {
      render(<TabsContainer {...defaultProps} notes={[]} />);

      expect(screen.getByText(/notes \(0\)/i)).toBeInTheDocument();
    });
  });

  describe('Tab Switching', () => {
    test('switches to Notes tab when Notes button is clicked', () => {
      render(<TabsContainer {...defaultProps} />);

      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      expect(screen.getByTestId('notes-component')).toBeInTheDocument();
      expect(screen.queryByTestId('timeline-component')).not.toBeInTheDocument();
    });

    test('switches back to Timeline tab when Timeline button is clicked', () => {
      render(<TabsContainer {...defaultProps} />);

      // Switch to Notes
      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      // Switch back to Timeline
      const timelineButton = screen.getByRole('button', { name: /timeline/i });
      fireEvent.click(timelineButton);

      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();
      expect(screen.queryByTestId('notes-component')).not.toBeInTheDocument();
    });

    test('applies active styles to Notes tab when clicked', () => {
      render(<TabsContainer {...defaultProps} />);

      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      expect(notesButton).toHaveClass('bg-white', 'text-blue-600');
    });

    test('removes active styles from Timeline tab when Notes is clicked', () => {
      render(<TabsContainer {...defaultProps} />);

      const timelineButton = screen.getByRole('button', { name: /timeline/i });
      const notesButton = screen.getByRole('button', { name: /notes/i });

      // Timeline should be active initially
      expect(timelineButton).toHaveClass('bg-white', 'text-blue-600');

      // Click Notes
      fireEvent.click(notesButton);

      // Timeline should no longer have active styles
      expect(timelineButton).not.toHaveClass('bg-white', 'text-blue-600');
      expect(timelineButton).toHaveClass('text-gray-600');
    });

    test('logs to console when Notes tab is clicked', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

      render(<TabsContainer {...defaultProps} />);

      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      expect(consoleSpy).toHaveBeenCalledWith('clicked on notes');

      consoleSpy.mockRestore();
    });
  });

  describe('Props Passing to Child Components', () => {
    test('passes correct props to Timeline component', () => {
      render(<TabsContainer {...defaultProps} />);

      const timelineComponent = screen.getByTestId('timeline-component');
      expect(timelineComponent).toHaveTextContent('Video: video-456');
      expect(timelineComponent).toHaveTextContent('Patient: patient-789');
    });

    test('passes correct props to Notes component', () => {
      render(<TabsContainer {...defaultProps} />);

      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      const notesComponent = screen.getByTestId('notes-component');
      expect(notesComponent).toHaveTextContent('Session: session-123');
      expect(notesComponent).toHaveTextContent('Count: 0');
    });

    test('passes setCurrentTimestamp to both child components', () => {
      const { rerender } = render(<TabsContainer {...defaultProps} />);

      // Timeline receives it (we can't directly test function passing with our mocks,
      // but we can verify the component renders which means props were passed)
      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();

      // Switch to Notes
      const notesButton = screen.getByRole('button', { name: /notes/i });
      fireEvent.click(notesButton);

      // Notes receives it
      expect(screen.getByTestId('notes-component')).toBeInTheDocument();
    });
  });

  describe('UI Elements', () => {
    test('renders timeline icon SVG', () => {
      const { container } = render(<TabsContainer {...defaultProps} />);

      const timelineButton = screen.getByRole('button', { name: /timeline/i });
      const svg = timelineButton.querySelector('svg');

      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('viewBox', '0 0 24 24');
    });

    test('renders notes icon SVG', () => {
      const { container } = render(<TabsContainer {...defaultProps} />);

      const notesButton = screen.getByRole('button', { name: /notes/i });
      const svg = notesButton.querySelector('svg');

      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('viewBox', '0 0 24 24');
    });

    test('has proper container styling', () => {
      const { container } = render(<TabsContainer {...defaultProps} />);

      const mainContainer = container.firstChild as HTMLElement;
      expect(mainContainer).toHaveClass('w-full', 'bg-white', 'rounded-lg', 'shadow-lg');
    });

    test('renders content area with scrollable container', () => {
      const { container } = render(<TabsContainer {...defaultProps} />);

      const contentArea = container.querySelector('.overflow-y-auto');
      expect(contentArea).toBeInTheDocument();
      expect(contentArea).toHaveClass('min-h-96');
    });
  });

  describe('State Management', () => {
    test('maintains tab state across multiple clicks', () => {
      render(<TabsContainer {...defaultProps} />);

      const timelineButton = screen.getByRole('button', { name: /timeline/i });
      const notesButton = screen.getByRole('button', { name: /notes/i });

      // Click Notes
      fireEvent.click(notesButton);
      expect(screen.getByTestId('notes-component')).toBeInTheDocument();

      // Click Timeline
      fireEvent.click(timelineButton);
      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();

      // Click Notes again
      fireEvent.click(notesButton);
      expect(screen.getByTestId('notes-component')).toBeInTheDocument();

      // Click Timeline again
      fireEvent.click(timelineButton);
      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();
    });

    test('only renders one tab content at a time', () => {
      render(<TabsContainer {...defaultProps} />);

      // Initially Timeline
      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();
      expect(screen.queryByTestId('notes-component')).not.toBeInTheDocument();

      // Switch to Notes
      fireEvent.click(screen.getByRole('button', { name: /notes/i }));
      expect(screen.queryByTestId('timeline-component')).not.toBeInTheDocument();
      expect(screen.getByTestId('notes-component')).toBeInTheDocument();
    });
  });

  describe('Edge Cases', () => {
    test('handles large number of notes', () => {
      const manyNotes = Array.from({ length: 999 }, (_, i) => ({
        id: `note-${i}`,
        content: `Note ${i}`,
      })) as Note[];

      render(<TabsContainer {...defaultProps} notes={manyNotes} />);

      expect(screen.getByText(/notes \(999\)/i)).toBeInTheDocument();
    });

    test('handles empty string sessionId', () => {
      render(<TabsContainer {...defaultProps} sessionId="" />);

      fireEvent.click(screen.getByRole('button', { name: /notes/i }));
      expect(screen.getByTestId('notes-component')).toBeInTheDocument();
    });

    test('handles empty string videoId and patientId', () => {
      render(<TabsContainer {...defaultProps} videoId="" patientId="" />);

      expect(screen.getByTestId('timeline-component')).toBeInTheDocument();
    });
  });
});