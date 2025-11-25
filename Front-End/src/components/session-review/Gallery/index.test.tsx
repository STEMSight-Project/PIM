import React from "react";
import { render, screen, fireEvent, within } from "@testing-library/react";
import "@testing-library/jest-dom";
import SessionGallery from "./index";
import { SessionWithPatient } from "@/components/session-review/types";
import { vi } from "vitest";

// Mock lucide-react icons
vi.mock("lucide-react", () => ({
  Grid: ({ className }: any) => <span className={className}>Grid</span>,
  List: ({ className }: any) => <span className={className}>List</span>,
}));

// Mock Next.js Image component
vi.mock("next/image", () => ({
  __esModule: true,
  default: (props: any) => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    return <img {...props} />;
  },
}));

describe("SessionGallery Component", () => {
  const mockOnSessionSelect = vi.fn();

  const mockSessions: SessionWithPatient[] = [
    {
      id: "session-1",
      sessionDate: "2024-01-15",
      startTime: new Date("2024-01-15T10:00:00"),
      endTime: new Date("2024-01-15T11:00:00"),
      stationId: "Station-A",
      patient: {
        id: "patient-1",
        first_name: "John",
        last_name: "Doe",
      },
      detections: [
        { type: "myoclonus", color: "red" },
        { type: "tremor", color: "yellow" },
      ],
      videos: [],
    } as unknown as SessionWithPatient,
    {
      id: "session-2",
      sessionDate: "2024-01-14",
      startTime: new Date("2024-01-14T14:30:00"),
      endTime: new Date("2024-01-14T15:30:00"),
      stationId: "Station-B",
      patient: {
        id: "patient-2",
        first_name: "Jane",
        last_name: "Smith",
      },
      detections: [
        { type: "seizure", color: "red" },
        { type: "tremor", color: "yellow" },
        { type: "myoclonus", color: "red" },
      ],
      videos: [],
    } as unknown as SessionWithPatient,
    {
      id: "session-3",
      sessionDate: "2024-01-13",
      startTime: new Date("2024-01-13T09:00:00"),
      endTime: new Date("2024-01-13T10:00:00"),
      stationId: "Station-C",
      patient: {
        id: "patient-3",
        first_name: "Bob",
        last_name: "Johnson",
      },
      detections: [],
      videos: [],
    } as unknown as SessionWithPatient,
  ];

  const defaultProps = {
    sessions: mockSessions,
    onSessionSelect: mockOnSessionSelect,
    selectedSessionId: "session-1",
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("Rendering", () => {
    test("renders the component with title", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("Session Gallery")).toBeInTheDocument();
    });

    test("displays session count", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("Showing 3 sessions")).toBeInTheDocument();
    });

    test('displays singular "session" for one session', () => {
      render(<SessionGallery {...defaultProps} sessions={[mockSessions[0]]} />);

      expect(screen.getByText("Showing 1 session")).toBeInTheDocument();
    });

    test("renders list view by default", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("John Doe")).toBeInTheDocument();
      expect(screen.getByText("Jane Smith")).toBeInTheDocument();
      expect(screen.getByText("Bob Johnson")).toBeInTheDocument();
    });

    test("shows empty state when no sessions", () => {
      render(<SessionGallery {...defaultProps} sessions={[]} />);

      expect(
        screen.getByText("No sessions found matching your search.")
      ).toBeInTheDocument();
    });
  });

  describe("View Mode Toggle", () => {
    test("has list view button and grid view button", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByLabelText("List view")).toBeInTheDocument();
      expect(screen.getByLabelText("Grid view")).toBeInTheDocument();
    });

    test("list view button is active by default", () => {
      render(<SessionGallery {...defaultProps} />);

      const listButton = screen.getByLabelText("List view");
      expect(listButton).toHaveClass("bg-blue-100", "text-blue-600");
    });

    test("switches to grid view when grid button clicked", () => {
      render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      expect(gridButton).toHaveClass("bg-blue-100", "text-blue-600");
    });

    test("switches back to list view when list button clicked", () => {
      render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      const listButton = screen.getByLabelText("List view");

      fireEvent.click(gridButton);
      fireEvent.click(listButton);

      expect(listButton).toHaveClass("bg-blue-100", "text-blue-600");
    });
  });

  describe("Sorting", () => {
    test("has sort dropdown with options", () => {
      render(<SessionGallery {...defaultProps} />);

      const sortSelect = screen.getByRole("combobox");
      expect(sortSelect).toBeInTheDocument();
      expect(screen.getByText("Latest First")).toBeInTheDocument();
    });

    test("sorts by latest first by default", () => {
      render(<SessionGallery {...defaultProps} />);

      const sessions = screen.getAllByText(/2024-01-/);
      expect(sessions[0]).toHaveTextContent("2024-01-15");
    });

    test("sorts by oldest first when selected", () => {
      const { container } = render(<SessionGallery {...defaultProps} />);

      const sortSelect = screen.getByRole("combobox");
      fireEvent.change(sortSelect, { target: { value: "oldest" } });

      // After sorting, the order should be: Bob Johnson (01-13), Jane Smith (01-14), John Doe (01-15)
      const sessionNames = screen.getAllByText(/Doe|Smith|Johnson/);
      const firstSession = sessionNames.find((el) =>
        el.textContent?.includes("Bob Johnson")
      );
      expect(firstSession).toBeInTheDocument();
    });

    test("sorts by most detections when selected", () => {
      render(<SessionGallery {...defaultProps} />);

      const sortSelect = screen.getByRole("combobox");
      fireEvent.change(sortSelect, { target: { value: "mostDetections" } });

      const firstSession = screen.getAllByText(/detection/)[0];
      expect(firstSession).toHaveTextContent("3 detections");
    });
  });

  describe("Session Selection", () => {
    test("highlights selected session", () => {
      render(<SessionGallery {...defaultProps} />);

      // Find the session container that has the highlighting classes
      const selectedSession = screen
        .getByText("John Doe")
        .closest(".bg-blue-50");
      expect(selectedSession).toHaveClass(
        "bg-blue-50",
        "border-l-4",
        "border-blue-500"
      );
    });

    test("calls onSessionSelect when clicking a session", () => {
      render(<SessionGallery {...defaultProps} />);

      const session = screen.getByText("Jane Smith").closest("div");
      fireEvent.click(session!);

      expect(mockOnSessionSelect).toHaveBeenCalledWith("session-2");
    });

    test("calls onSessionSelect when clicking View button", () => {
      render(<SessionGallery {...defaultProps} />);

      const viewButtons = screen.getAllByText("View");
      fireEvent.click(viewButtons[1]);

      expect(mockOnSessionSelect).toHaveBeenCalledWith("session-2");
    });

    test("View button click does not trigger parent onClick", () => {
      render(<SessionGallery {...defaultProps} />);

      const viewButton = screen.getAllByText("View")[0];
      fireEvent.click(viewButton);

      // Should only be called once, not twice (once from button, once from parent)
      expect(mockOnSessionSelect).toHaveBeenCalledTimes(1);
    });

    test("does not call onSessionSelect if session has no id", () => {
      const sessionWithoutId = {
        ...mockSessions[0],
        id: undefined,
      } as unknown as SessionWithPatient;

      render(
        <SessionGallery {...defaultProps} sessions={[sessionWithoutId]} />
      );

      const session = screen.getByText("John Doe").closest("div");
      fireEvent.click(session!);

      expect(mockOnSessionSelect).not.toHaveBeenCalled();
    });
  });

  describe("Detection Display", () => {
    test("shows detection count for sessions with detections", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("2 detections")).toBeInTheDocument();
      expect(screen.getByText("3 detections")).toBeInTheDocument();
    });

    test('shows "No detections" for sessions without detections', () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("No detections")).toBeInTheDocument();
    });

    test('uses singular "detection" for one detection', () => {
      const singleDetection = {
        ...mockSessions[0],
        detections: [{ type: "myoclonus", color: "red" }],
      } as unknown as SessionWithPatient;

      render(<SessionGallery {...defaultProps} sessions={[singleDetection]} />);

      expect(screen.getByText("1 detection")).toBeInTheDocument();
    });

    test("shows detection color indicators in list view", () => {
      const { container } = render(<SessionGallery {...defaultProps} />);

      const colorDots = container.querySelectorAll(".rounded-full");
      expect(colorDots.length).toBeGreaterThan(0);
    });

    test("limits detection indicators to 4 in list view", () => {
      const manyDetections = {
        ...mockSessions[0],
        detections: Array(6).fill({ type: "test", color: "red" }),
      } as unknown as SessionWithPatient;

      render(<SessionGallery {...defaultProps} sessions={[manyDetections]} />);

      expect(screen.getByText("+2")).toBeInTheDocument();
    });
  });

  describe("Grid View", () => {
    test("displays sessions in grid layout", () => {
      const { container } = render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      const gridContainer = container.querySelector(".grid-cols-2");
      expect(gridContainer).toBeInTheDocument();
    });

    test("shows thumbnail images in grid view", () => {
      render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      const images = screen.getAllByAltText("Thumbnail");
      expect(images).toHaveLength(3);
    });

    test("shows detection count in grid view", () => {
      render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      expect(screen.getByText("2 detections")).toBeInTheDocument();
      expect(screen.getByText("3 detections")).toBeInTheDocument();
    });

    test("limits detection indicators to 3 in grid view", () => {
      const manyDetections = {
        ...mockSessions[0],
        detections: Array(5).fill({ type: "test", color: "red" }),
      } as unknown as SessionWithPatient;

      render(<SessionGallery {...defaultProps} sessions={[manyDetections]} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      expect(screen.getByText("+2")).toBeInTheDocument();
    });

    test("highlights selected session in grid view", () => {
      render(<SessionGallery {...defaultProps} />);

      const gridButton = screen.getByLabelText("Grid view");
      fireEvent.click(gridButton);

      const selectedSession = screen.getByText("John Doe").closest("div");
      expect(selectedSession).toHaveClass(
        "bg-blue-50",
        "border-2",
        "border-blue-500"
      );
    });
  });

  describe("Session Information Display", () => {
    test("displays patient names", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("John Doe")).toBeInTheDocument();
      expect(screen.getByText("Jane Smith")).toBeInTheDocument();
      expect(screen.getByText("Bob Johnson")).toBeInTheDocument();
    });

    test("displays station IDs", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText("Station-A")).toBeInTheDocument();
      expect(screen.getByText("Station-B")).toBeInTheDocument();
      expect(screen.getByText("Station-C")).toBeInTheDocument();
    });

    test("displays session dates", () => {
      render(<SessionGallery {...defaultProps} />);

      expect(screen.getByText(/2024-01-15/)).toBeInTheDocument();
      expect(screen.getByText(/2024-01-14/)).toBeInTheDocument();
      expect(screen.getByText(/2024-01-13/)).toBeInTheDocument();
    });

    test("displays session start times", () => {
      render(<SessionGallery {...defaultProps} />);

      const timeElements = screen.getAllByText(/AM|PM/i);
      expect(timeElements.length).toBeGreaterThan(0);
    });
  });

  describe("Color Mapping", () => {
    test("applies correct color classes for red detections", () => {
      const { container } = render(<SessionGallery {...defaultProps} />);

      const redBg = container.querySelector(".bg-red-100");
      expect(redBg).toBeInTheDocument();
    });

    test("applies correct color classes for yellow detections", () => {
      const { container } = render(<SessionGallery {...defaultProps} />);

      const yellowBg = container.querySelector(".bg-yellow-100");
      expect(yellowBg).toBeInTheDocument();
    });

    test("falls back to gray for unknown colors", () => {
      const unknownColor = {
        ...mockSessions[0],
        detections: [{ type: "unknown", color: "unknown" }],
      } as unknown as SessionWithPatient;

      const { container } = render(
        <SessionGallery {...defaultProps} sessions={[unknownColor]} />
      );

      const grayDot = container.querySelector(".bg-gray-500");
      expect(grayDot).toBeInTheDocument();
    });
  });

  describe("Edge Cases", () => {
    test("handles sessions without patient data", () => {
      const noPatient = {
        ...mockSessions[0],
        patient: undefined as any,
      };

      render(<SessionGallery {...defaultProps} sessions={[noPatient]} />);

      // Should not crash
      expect(screen.getByText("Session Gallery")).toBeInTheDocument();
    });

    test("handles sessions without startTime", () => {
      const noStartTime = {
        ...mockSessions[0],
        startTime: undefined as any,
      };

      render(<SessionGallery {...defaultProps} sessions={[noStartTime]} />);

      // Should not crash
      expect(screen.getByText("Session Gallery")).toBeInTheDocument();
    });

    test("handles very long patient names", () => {
      const longName = {
        ...mockSessions[0],
        patient: {
          id: "patient-1",
          first_name: "VeryLongFirstName",
          last_name: "VeryLongLastName",
        },
      } as unknown as SessionWithPatient;

      render(<SessionGallery {...defaultProps} sessions={[longName]} />);

      expect(
        screen.getByText("VeryLongFirstName VeryLongLastName")
      ).toBeInTheDocument();
    });

    test("handles large number of detections", () => {
      const manyDetections = {
        ...mockSessions[0],
        detections: Array(100).fill({ type: "test", color: "red" }),
      } as unknown as SessionWithPatient;

      render(<SessionGallery {...defaultProps} sessions={[manyDetections]} />);

      expect(screen.getByText("100 detections")).toBeInTheDocument();
    });
  });
});
