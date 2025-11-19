/**
 * Unit tests for Video Playback page (recordings listing)
 * Covers: loading state, error state, empty sessions, sessions rendering
 */

import VideoPlaybackPage from "@/app/video-playback/page";
import { useRecordings } from "@/hooks";
import "@testing-library/jest-dom";
import { render, screen, fireEvent } from "@testing-library/react";

jest.mock("@/hooks");

const mockUseRecordings = useRecordings as jest.MockedFunction<
  typeof useRecordings
>;

describe("VideoPlaybackPage", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("shows loading state when recordings are loading", () => {
    mockUseRecordings.mockReturnValue({
      sessions: [],
      isLoading: true,
      error: null,
      fetchSessionsWithRecordings: jest.fn(),
      clearError: jest.fn(),
    } as any);

    render(<VideoPlaybackPage />);

    expect(screen.getByText(/Loading recorded sessions/i)).toBeInTheDocument();
  });

  it("shows error card when hook returns error", () => {
    mockUseRecordings.mockReturnValue({
      sessions: [],
      isLoading: false,
      error: "Database unavailable",
      fetchSessionsWithRecordings: jest.fn(),
      clearError: jest.fn(),
    } as any);

    render(<VideoPlaybackPage />);

    expect(screen.getByText(/Error Loading Sessions/i)).toBeInTheDocument();
    expect(screen.getByText(/Database unavailable/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Try Again/i })).toBeInTheDocument();
  });

  it("shows empty state when no sessions", () => {
    mockUseRecordings.mockReturnValue({
      sessions: [],
      isLoading: false,
      error: null,
      fetchSessionsWithRecordings: jest.fn(),
      clearError: jest.fn(),
    } as any);

    render(<VideoPlaybackPage />);

    expect(screen.getByText(/No Recorded Sessions/i)).toBeInTheDocument();
  });

  it("renders sessions grouped by ambulance and allows expand", () => {
    const sessions = [
      {
        session_id: "S-1",
        ambulance_number: "AMB-001",
        session_name: "Morning Shift",
        total_recordings: 2,
        total_duration: 120,
        recordings: [
          { id: "R-1", created_at: "2025-11-17T12:00:00Z" },
        ],
      },
    ];

    mockUseRecordings.mockReturnValue({
      sessions,
      isLoading: false,
      error: null,
      fetchSessionsWithRecordings: jest.fn(),
      clearError: jest.fn(),
    } as any);

    render(<VideoPlaybackPage />);

    // Header and stats
    expect(screen.getByText(/Recorded Sessions by Ambulance/i)).toBeInTheDocument();
    expect(screen.getByText(/Total Recordings/i)).toBeInTheDocument();

    // Ambulance group collapsed by default; expand by clicking the ambulance header
    const ambulanceHeader = screen.getByText(/AMB-001/i);
    fireEvent.click(ambulanceHeader);

    // After expansion the session card should show "View Recordings" button
    expect(screen.getByRole("button", { name: /View Recordings/i })).toBeInTheDocument();
  });
});
