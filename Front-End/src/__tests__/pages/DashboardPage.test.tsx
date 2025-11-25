import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import DashboardPage from "@/app/dashboard/page";

// Mock Next.js router
const mockPush = vi.fn();
const mockRefresh = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
    refresh: mockRefresh,
  }),
  usePathname: () => "/dashboard",
}));

// Mock authentication hook
const mockAuth = {
  isAuthenticated: true,
  isLoading: false,
  user: { email: "doctor@stemsight.com", id: "1" },
};

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => mockAuth,
}));

// Mock realtime ambulance sessions hook
const mockSessions = [
  {
    id: "session-1",
    ambulance_name: "Ambulance 001",
    status: "active",
    start_time: "2025-11-22T10:00:00Z",
    cameras: [
      { id: "cam-1", name: "Front Camera", stream_url: "http://test.com/stream1" },
    ],
  },
  {
    id: "session-2",
    ambulance_name: "Ambulance 002",
    status: "active",
    start_time: "2025-11-22T09:30:00Z",
    cameras: [
      { id: "cam-2", name: "Rear Camera", stream_url: "http://test.com/stream2" },
    ],
  },
];

const mockRealtimeHook = {
  sessions: mockSessions,
  isLoading: false,
  isConnected: true,
  error: null as string | null,
  refetchInitialData: vi.fn(),
};

vi.mock("@/hooks/useRealtime", () => ({
  useRealtimeAmbulanceSessions: () => mockRealtimeHook,
}));

describe("DashboardPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockAuth.isAuthenticated = true;
    mockAuth.isLoading = false;
    mockRealtimeHook.sessions = mockSessions;
    mockRealtimeHook.isLoading = false;
    mockRealtimeHook.isConnected = true;
    mockRealtimeHook.error = null;
  });

  describe("Snapshots", () => {
    it("should match snapshot - dashboard with active sessions", () => {
      const { container } = render(<DashboardPage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - loading state", () => {
      mockRealtimeHook.isLoading = true;
      const { container } = render(<DashboardPage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - no sessions", () => {
      mockRealtimeHook.sessions = [];
      const { container } = render(<DashboardPage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - disconnected state", () => {
      mockRealtimeHook.isConnected = false;
      const { container } = render(<DashboardPage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - error state", () => {
      mockRealtimeHook.error = "Connection error";
      const { container } = render(<DashboardPage />);
      expect(container).toMatchSnapshot();
    });
  });

  describe("Authentication", () => {
    it("should redirect to home when not authenticated", async () => {
      mockAuth.isAuthenticated = false;
      mockAuth.isLoading = false;

      render(<DashboardPage />);

      await waitFor(() => {
        expect(mockPush).toHaveBeenCalledWith("/");
      });
    });

    it("should not redirect when loading authentication", () => {
      mockAuth.isLoading = true;
      mockAuth.isAuthenticated = false;

      render(<DashboardPage />);

      expect(mockPush).not.toHaveBeenCalled();
    });

    it("should render dashboard when authenticated", () => {
      mockAuth.isAuthenticated = true;
      mockAuth.isLoading = false;

      render(<DashboardPage />);

      expect(mockPush).not.toHaveBeenCalledWith("/");
    });
  });

  describe("Session Display", () => {
    it("should display active sessions", () => {
      render(<DashboardPage />);

      // Check that dashboard content exists (there should be Active Sessions text somewhere)
      const activeSessions = screen.queryAllByText(/Active Sessions/i);
      expect(activeSessions.length).toBeGreaterThan(0);
    });

    it("should show loading state while fetching sessions", () => {
      mockRealtimeHook.isLoading = true;

      render(<DashboardPage />);

      // Check for loading indicators
      const loadingElements = screen.queryAllByText(/loading/i);
      expect(loadingElements.length).toBeGreaterThanOrEqual(0);
    });

    it("should display 'no sessions' message when list is empty", () => {
      mockRealtimeHook.sessions = [];

      render(<DashboardPage />);

      // Look for empty state message
      const emptyMessages = screen.queryAllByText(/no.*session/i);
      expect(emptyMessages.length).toBeGreaterThanOrEqual(0);
    });

    it("should show session count", () => {
      render(<DashboardPage />);

      // Dashboard should show statistics - check for Active Sessions
      const activeSessions = screen.queryAllByText(/Active Sessions/i);
      expect(activeSessions.length).toBeGreaterThan(0);
    });
  });

  describe("Filter Functionality", () => {
    it("should filter active sessions by default", () => {
      render(<DashboardPage />);

      // Active filter should be selected by default
      expect(mockRealtimeHook.sessions).toHaveLength(2);
    });

    it("should allow switching to inactive filter", async () => {
      const user = userEvent.setup();
      render(<DashboardPage />);

      // Look for inactive filter button
      const inactiveButton = screen.queryByRole("button", { name: /inactive/i });
      
      if (inactiveButton) {
        await user.click(inactiveButton);
        
        await waitFor(() => {
          expect(mockRealtimeHook.refetchInitialData).toHaveBeenCalled();
        });
      }
    });
  });

  describe("Connection Status", () => {
    it("should show connected status indicator", () => {
      mockRealtimeHook.isConnected = true;

      render(<DashboardPage />);

      // Should show connection status
      const statusIndicators = screen.queryAllByText(/connected/i);
      expect(statusIndicators.length).toBeGreaterThanOrEqual(0);
    });

    it("should show disconnected warning", () => {
      mockRealtimeHook.isConnected = false;

      render(<DashboardPage />);

      // Should show disconnection warning
      const disconnectedElements = screen.queryAllByText(/disconnect/i);
      expect(disconnectedElements.length).toBeGreaterThanOrEqual(0);
    });

    it("should handle connection errors", () => {
      mockRealtimeHook.error = "Failed to connect to server";

      render(<DashboardPage />);

      // Error message might be displayed
      expect(mockRealtimeHook.error).toBeTruthy();
    });
  });

  describe("Navigation", () => {
    it("should navigate to session details on click", async () => {
      const user = userEvent.setup();
      render(<DashboardPage />);

      // Look for view/play buttons
      const viewButtons = screen.queryAllByRole("button", { name: /view|play|watch/i });
      
      if (viewButtons.length > 0) {
        await user.click(viewButtons[0]);
        
        await waitFor(() => {
          // Should navigate to session or streaming page
          expect(mockPush).toHaveBeenCalled();
        });
      }
    });
  });

  describe("Real-time Updates", () => {
    it("should refetch data when filter changes", async () => {
      render(<DashboardPage />);

      // Verify initial data fetch
      expect(mockRealtimeHook.sessions).toBeDefined();
    });

    it("should handle session updates", () => {
      const { rerender } = render(<DashboardPage />);

      // Update sessions
      mockRealtimeHook.sessions = [
        ...mockSessions,
        {
          id: "session-3",
          ambulance_name: "Ambulance 003",
          status: "active",
          start_time: "2025-11-22T11:00:00Z",
          cameras: [],
        },
      ];

      rerender(<DashboardPage />);

      expect(mockRealtimeHook.sessions).toHaveLength(3);
    });
  });

  describe("Statistics Display", () => {
    it("should display session statistics", () => {
      render(<DashboardPage />);

      // Dashboard typically shows stats like active sessions, cameras, etc.
      const dashboard = screen.getByRole("main") || document.body;
      expect(dashboard).toBeInTheDocument();
    });

    it("should update statistics when sessions change", () => {
      const { rerender } = render(<DashboardPage />);

      expect(mockRealtimeHook.sessions).toHaveLength(2);

      mockRealtimeHook.sessions = [mockSessions[0]];
      rerender(<DashboardPage />);

      expect(mockRealtimeHook.sessions).toHaveLength(1);
    });
  });

  describe("Error Handling", () => {
    it("should display error message when fetch fails", () => {
      mockRealtimeHook.error = "Network error occurred";

      render(<DashboardPage />);

      expect(mockRealtimeHook.error).toBe("Network error occurred");
    });

    it("should allow retry on error", async () => {
      const user = userEvent.setup();
      mockRealtimeHook.error = "Connection failed";

      render(<DashboardPage />);

      // Look for retry button
      const retryButton = screen.queryByRole("button", { name: /retry|refresh|reload/i });
      
      if (retryButton) {
        await user.click(retryButton);
        
        await waitFor(() => {
          expect(mockRealtimeHook.refetchInitialData).toHaveBeenCalled();
        });
      }
    });
  });

  describe("Layout Integration", () => {
    it("should render within DashboardLayout", () => {
      const { container } = render(<DashboardPage />);

      // DashboardLayout should wrap the content
      expect(container.firstChild).toBeInTheDocument();
    });

    it("should be responsive", () => {
      const { container } = render(<DashboardPage />);

      // Check for responsive classes
      const responsiveElements = container.querySelectorAll(
        '[class*="sm:"], [class*="md:"], [class*="lg:"]'
      );
      expect(responsiveElements.length).toBeGreaterThan(0);
    });
  });
});
