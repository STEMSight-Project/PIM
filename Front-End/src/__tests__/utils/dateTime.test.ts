/**
 * Unit tests for date and time formatting utilities
 * Tests timestamp formatting, duration calculations, and relative time
 */

describe("Date and Time Utilities", () => {
  describe("Date Formatting", () => {
    it("should format ISO dates to readable format", () => {
      const formatDate = (isoString: string) => {
        const date = new Date(isoString);
        return date.toLocaleDateString("en-US", {
          year: "numeric",
          month: "short",
          day: "numeric",
        });
      };

      const date = "2024-11-04T10:30:00Z";
      const formatted = formatDate(date);

      expect(formatted).toMatch(/Nov 4, 2024/);
    });

    it("should format dates with time", () => {
      const formatDateTime = (isoString: string) => {
        const date = new Date(isoString);
        return date.toLocaleString("en-US", {
          year: "numeric",
          month: "short",
          day: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        });
      };

      const date = "2024-11-04T14:30:00Z";
      const formatted = formatDateTime(date);

      expect(formatted).toContain("Nov");
      expect(formatted).toContain("2024");
    });
  });

  describe("Time Formatting", () => {
    it("should format time in HH:MM:SS", () => {
      const formatTime = (seconds: number) => {
        const hrs = Math.floor(seconds / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        const secs = Math.floor(seconds % 60);

        const pad = (num: number) => String(num).padStart(2, "0");

        if (hrs > 0) {
          return `${pad(hrs)}:${pad(mins)}:${pad(secs)}`;
        }
        return `${pad(mins)}:${pad(secs)}`;
      };

      expect(formatTime(0)).toBe("00:00");
      expect(formatTime(65)).toBe("01:05");
      expect(formatTime(3661)).toBe("01:01:01");
      expect(formatTime(7325)).toBe("02:02:05");
    });

    it("should format milliseconds to seconds", () => {
      const msToSeconds = (ms: number) => Math.floor(ms / 1000);

      expect(msToSeconds(1000)).toBe(1);
      expect(msToSeconds(1500)).toBe(1);
      expect(msToSeconds(5432)).toBe(5);
      expect(msToSeconds(60000)).toBe(60);
    });
  });

  describe("Duration Calculation", () => {
    it("should calculate duration between timestamps", () => {
      const calculateDuration = (start: string, end: string) => {
        const startTime = new Date(start).getTime();
        const endTime = new Date(end).getTime();
        return endTime - startTime;
      };

      const start = "2024-11-04T10:00:00Z";
      const end = "2024-11-04T11:30:00Z";

      const duration = calculateDuration(start, end);
      expect(duration).toBe(90 * 60 * 1000); // 90 minutes in ms
    });

    it("should calculate duration in minutes", () => {
      const durationInMinutes = (start: string, end: string) => {
        const startTime = new Date(start).getTime();
        const endTime = new Date(end).getTime();
        return Math.floor((endTime - startTime) / (60 * 1000));
      };

      const start = "2024-11-04T10:00:00Z";
      const end = "2024-11-04T10:45:00Z";

      expect(durationInMinutes(start, end)).toBe(45);
    });

    it("should handle same timestamps", () => {
      const calculateDuration = (start: string, end: string) => {
        return new Date(end).getTime() - new Date(start).getTime();
      };

      const timestamp = "2024-11-04T10:00:00Z";
      expect(calculateDuration(timestamp, timestamp)).toBe(0);
    });
  });

  describe("Relative Time", () => {
    it("should format time ago for recent times", () => {
      const timeAgo = (timestamp: string) => {
        const now = Date.now();
        const time = new Date(timestamp).getTime();
        const diffMs = now - time;
        const diffMins = Math.floor(diffMs / 60000);

        if (diffMins < 1) return "just now";
        if (diffMins < 60)
          return `${diffMins} minute${diffMins > 1 ? "s" : ""} ago`;

        const diffHours = Math.floor(diffMins / 60);
        if (diffHours < 24)
          return `${diffHours} hour${diffHours > 1 ? "s" : ""} ago`;

        const diffDays = Math.floor(diffHours / 24);
        return `${diffDays} day${diffDays > 1 ? "s" : ""} ago`;
      };

      // Test with known values
      const now = Date.now();

      // Just now
      const veryRecent = new Date(now - 30000).toISOString(); // 30 seconds ago
      expect(timeAgo(veryRecent)).toBe("just now");

      // Minutes ago
      const recentMinutes = new Date(now - 5 * 60000).toISOString();
      expect(timeAgo(recentMinutes)).toBe("5 minutes ago");
    });

    it("should handle future timestamps gracefully", () => {
      const isInFuture = (timestamp: string) => {
        return new Date(timestamp).getTime() > Date.now();
      };

      const future = new Date(Date.now() + 60000).toISOString();
      expect(isInFuture(future)).toBe(true);

      const past = new Date(Date.now() - 60000).toISOString();
      expect(isInFuture(past)).toBe(false);
    });
  });

  describe("Session Duration Formatting", () => {
    it("should format session duration for display", () => {
      const formatSessionDuration = (startTime: string, endTime?: string) => {
        const start = new Date(startTime).getTime();
        const end = endTime ? new Date(endTime).getTime() : Date.now();
        const durationMs = end - start;

        const hours = Math.floor(durationMs / (3600 * 1000));
        const minutes = Math.floor((durationMs % (3600 * 1000)) / (60 * 1000));

        if (hours > 0) {
          return `${hours}h ${minutes}m`;
        }
        return `${minutes}m`;
      };

      const start = "2024-11-04T10:00:00Z";
      const end = "2024-11-04T11:30:00Z";

      expect(formatSessionDuration(start, end)).toBe("1h 30m");

      const shortSession = "2024-11-04T10:00:00Z";
      const shortEnd = "2024-11-04T10:15:00Z";

      expect(formatSessionDuration(shortSession, shortEnd)).toBe("15m");
    });

    it("should handle ongoing sessions without end time", () => {
      const formatOngoingSession = (startTime: string) => {
        const start = new Date(startTime).getTime();
        const now = Date.now();
        const durationMs = now - start;

        return durationMs > 0 ? "ongoing" : "not started";
      };

      const past = new Date(Date.now() - 60000).toISOString();
      expect(formatOngoingSession(past)).toBe("ongoing");
    });
  });

  describe("Timezone Handling", () => {
    it("should convert UTC to local time", () => {
      const utcToLocal = (utcString: string) => {
        const date = new Date(utcString);
        return date.toLocaleString();
      };

      const utc = "2024-11-04T10:00:00Z";
      const local = utcToLocal(utc);

      expect(local).toBeTruthy();
      expect(typeof local).toBe("string");
    });

    it("should preserve ISO format in conversions", () => {
      const preserveISO = (isoString: string) => {
        const date = new Date(isoString);
        return date.toISOString();
      };

      const original = "2024-11-04T10:30:45.123Z";
      const preserved = preserveISO(original);

      expect(preserved).toBe(original);
    });
  });

  describe("Time Comparison", () => {
    it("should compare if time is within range", () => {
      const isWithinRange = (timestamp: string, rangeMinutes: number) => {
        const time = new Date(timestamp).getTime();
        const now = Date.now();
        const diffMinutes = Math.abs(now - time) / (60 * 1000);

        return diffMinutes <= rangeMinutes;
      };

      const recent = new Date(Date.now() - 2 * 60000).toISOString(); // 2 mins ago
      expect(isWithinRange(recent, 5)).toBe(true);
      expect(isWithinRange(recent, 1)).toBe(false);
    });

    it("should sort timestamps chronologically", () => {
      const sortByTime = (timestamps: string[]) => {
        return [...timestamps].sort((a, b) => {
          return new Date(a).getTime() - new Date(b).getTime();
        });
      };

      const unsorted = [
        "2024-11-04T12:00:00Z",
        "2024-11-04T10:00:00Z",
        "2024-11-04T11:00:00Z",
      ];

      const sorted = sortByTime(unsorted);

      expect(sorted[0]).toBe("2024-11-04T10:00:00Z");
      expect(sorted[1]).toBe("2024-11-04T11:00:00Z");
      expect(sorted[2]).toBe("2024-11-04T12:00:00Z");
    });
  });

  describe("Timestamp Generation", () => {
    it("should generate current timestamp in ISO format", () => {
      const generateTimestamp = () => new Date().toISOString();

      const timestamp = generateTimestamp();

      expect(timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });

    it("should create timestamp with offset", () => {
      const createFutureTimestamp = (minutesFromNow: number) => {
        const future = new Date(Date.now() + minutesFromNow * 60000);
        return future.toISOString();
      };

      const future = createFutureTimestamp(30);
      const futureTime = new Date(future).getTime();

      expect(futureTime).toBeGreaterThan(Date.now());
    });
  });

  describe("Recording Segment Timing", () => {
    it("should calculate segment duration (10 seconds)", () => {
      const SEGMENT_DURATION = 10; // seconds

      expect(SEGMENT_DURATION).toBe(10);
      expect(SEGMENT_DURATION * 1000).toBe(10000); // milliseconds
    });

    it("should calculate number of segments in duration", () => {
      const calculateSegments = (durationSeconds: number) => {
        const SEGMENT_DURATION = 10;
        return Math.floor(durationSeconds / SEGMENT_DURATION);
      };

      expect(calculateSegments(30)).toBe(3);
      expect(calculateSegments(45)).toBe(4);
      expect(calculateSegments(5)).toBe(0);
    });

    it("should format segment name with timestamp", () => {
      const formatSegmentName = (segmentNumber: number) => {
        return `segment-${String(segmentNumber).padStart(5, "0")}.ts`;
      };

      expect(formatSegmentName(1)).toBe("segment-00001.ts");
      expect(formatSegmentName(99)).toBe("segment-00099.ts");
      expect(formatSegmentName(12345)).toBe("segment-12345.ts");
    });
  });
});
