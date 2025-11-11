/**
 * Unit tests for form validation utilities
 * Tests email, password, and common validation functions
 */

describe("Form Validation Utilities", () => {
  describe("Email Validation", () => {
    it("should validate correct email format", () => {
      const validEmails = [
        "user@example.com",
        "john.doe@company.co.uk",
        "admin+tag@domain.com",
        "user123@test-domain.org",
      ];

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      validEmails.forEach((email) => {
        expect(emailRegex.test(email)).toBe(true);
      });
    });

    it("should reject invalid email formats", () => {
      const invalidEmails = [
        "notanemail",
        "@example.com",
        "user@",
        "user @example.com",
        "user@.com",
        "user@domain",
        "",
      ];

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      invalidEmails.forEach((email) => {
        expect(emailRegex.test(email)).toBe(false);
      });
    });
  });

  describe("Password Validation", () => {
    it("should validate minimum length password", () => {
      const minLength = 8;

      expect("password123".length >= minLength).toBe(true);
      expect("Pass1!".length >= minLength).toBe(false);
      expect("a".repeat(minLength).length >= minLength).toBe(true);
    });

    it("should validate password complexity requirements", () => {
      const hasUpperCase = (str: string) => /[A-Z]/.test(str);
      const hasLowerCase = (str: string) => /[a-z]/.test(str);
      const hasNumber = (str: string) => /[0-9]/.test(str);
      const hasSpecialChar = (str: string) =>
        /[!@#$%^&*(),.?":{}|<>]/.test(str);

      const complexPassword = "MyP@ssw0rd!";
      expect(hasUpperCase(complexPassword)).toBe(true);
      expect(hasLowerCase(complexPassword)).toBe(true);
      expect(hasNumber(complexPassword)).toBe(true);
      expect(hasSpecialChar(complexPassword)).toBe(true);

      const simplePassword = "password";
      expect(hasUpperCase(simplePassword)).toBe(false);
      expect(hasNumber(simplePassword)).toBe(false);
      expect(hasSpecialChar(simplePassword)).toBe(false);
    });
  });

  describe("Required Field Validation", () => {
    it("should identify empty strings", () => {
      const isEmpty = (value: string) => value.trim().length === 0;

      expect(isEmpty("")).toBe(true);
      expect(isEmpty("   ")).toBe(true);
      expect(isEmpty("text")).toBe(false);
      expect(isEmpty(" text ")).toBe(false);
    });

    it("should validate non-null values", () => {
      const isValid = (value: any) => value !== null && value !== undefined;

      expect(isValid("text")).toBe(true);
      expect(isValid(0)).toBe(true);
      expect(isValid(false)).toBe(true);
      expect(isValid(null)).toBe(false);
      expect(isValid(undefined)).toBe(false);
    });
  });

  describe("Phone Number Validation", () => {
    it("should validate US phone number formats", () => {
      const phoneRegex = /^(\+1)?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/;

      const validPhones = [
        "123-456-7890",
        "(123) 456-7890",
        "123.456.7890",
        "1234567890",
        "+1 123-456-7890",
      ];

      validPhones.forEach((phone) => {
        expect(phoneRegex.test(phone)).toBe(true);
      });
    });

    it("should reject invalid phone formats", () => {
      const phoneRegex = /^(\+1)?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/;

      const invalidPhones = ["123", "abcd", "123-456", "12-34-5678"];

      invalidPhones.forEach((phone) => {
        expect(phoneRegex.test(phone)).toBe(false);
      });
    });
  });

  describe("URL Validation", () => {
    it("should validate HTTP/HTTPS URLs", () => {
      try {
        const validUrls = [
          "https://example.com",
          "http://localhost:8000",
          "https://sub.domain.com/path?query=value",
        ];

        validUrls.forEach((urlString) => {
          const url = new URL(urlString);
          expect(url.protocol).toMatch(/^https?:$/);
        });
      } catch (error) {
        fail("Valid URLs should not throw");
      }
    });

    it("should reject invalid URLs", () => {
      const invalidUrls = ["not a url", "//example.com"]; // FTP is actually valid

      invalidUrls.forEach((urlString) => {
        expect(() => new URL(urlString)).toThrow();
      });
    });
  });

  describe("Date Validation", () => {
    it("should validate date format", () => {
      const isValidDate = (dateString: string) => {
        const date = new Date(dateString);
        return !isNaN(date.getTime());
      };

      expect(isValidDate("2024-01-15")).toBe(true);
      expect(isValidDate("2024-01-15T10:30:00Z")).toBe(true);
      expect(isValidDate("invalid")).toBe(false);
      expect(isValidDate("")).toBe(false);
    });

    it("should validate future dates", () => {
      const isFutureDate = (dateString: string) => {
        const date = new Date(dateString);
        return date.getTime() > Date.now();
      };

      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 1);

      const pastDate = new Date();
      pastDate.setFullYear(pastDate.getFullYear() - 1);

      expect(isFutureDate(futureDate.toISOString())).toBe(true);
      expect(isFutureDate(pastDate.toISOString())).toBe(false);
    });
  });

  describe("Number Range Validation", () => {
    it("should validate numbers within range", () => {
      const isInRange = (value: number, min: number, max: number) => {
        return value >= min && value <= max;
      };

      expect(isInRange(5, 0, 10)).toBe(true);
      expect(isInRange(0, 0, 10)).toBe(true);
      expect(isInRange(10, 0, 10)).toBe(true);
      expect(isInRange(-1, 0, 10)).toBe(false);
      expect(isInRange(11, 0, 10)).toBe(false);
    });

    it("should validate positive numbers", () => {
      const isPositive = (value: number) => value > 0;

      expect(isPositive(1)).toBe(true);
      expect(isPositive(0.1)).toBe(true);
      expect(isPositive(0)).toBe(false);
      expect(isPositive(-1)).toBe(false);
    });
  });

  describe("String Length Validation", () => {
    it("should validate min/max length", () => {
      const validateLength = (str: string, min: number, max: number) => {
        return str.length >= min && str.length <= max;
      };

      expect(validateLength("hello", 1, 10)).toBe(true);
      expect(validateLength("hello", 6, 10)).toBe(false);
      expect(validateLength("hello", 1, 4)).toBe(false);
      expect(validateLength("", 1, 10)).toBe(false);
    });

    it("should trim whitespace before validation", () => {
      const validateTrimmed = (str: string, minLength: number) => {
        return str.trim().length >= minLength;
      };

      expect(validateTrimmed("  hello  ", 5)).toBe(true);
      expect(validateTrimmed("  hi  ", 5)).toBe(false);
      expect(validateTrimmed("   ", 1)).toBe(false);
    });
  });

  describe("Array Validation", () => {
    it("should validate non-empty arrays", () => {
      const isNonEmpty = (arr: any[]) => Array.isArray(arr) && arr.length > 0;

      expect(isNonEmpty([1, 2, 3])).toBe(true);
      expect(isNonEmpty([])).toBe(false);
      expect(isNonEmpty("not an array" as any)).toBe(false);
    });

    it("should validate unique array items", () => {
      const hasUniqueItems = (arr: any[]) => {
        return arr.length === new Set(arr).size;
      };

      expect(hasUniqueItems([1, 2, 3])).toBe(true);
      expect(hasUniqueItems([1, 2, 2, 3])).toBe(false);
      expect(hasUniqueItems(["a", "b", "c"])).toBe(true);
      expect(hasUniqueItems(["a", "b", "a"])).toBe(false);
    });
  });

  describe("Ambulance ID Validation", () => {
    it("should validate ambulance ID format", () => {
      const ambulanceIdRegex = /^AMB-\d{3}$/;

      expect(ambulanceIdRegex.test("AMB-001")).toBe(true);
      expect(ambulanceIdRegex.test("AMB-999")).toBe(true);
      expect(ambulanceIdRegex.test("AMB-1")).toBe(false);
      expect(ambulanceIdRegex.test("AMB-0001")).toBe(false);
      expect(ambulanceIdRegex.test("amb-001")).toBe(false);
    });
  });

  describe("Room Name Validation", () => {
    it("should validate room name format", () => {
      const roomNameRegex = /^AMB-\d{3}-ROOM-\d{3}$/;

      expect(roomNameRegex.test("AMB-001-ROOM-001")).toBe(true);
      expect(roomNameRegex.test("AMB-999-ROOM-999")).toBe(true);
      expect(roomNameRegex.test("AMB-1-ROOM-1")).toBe(false);
      expect(roomNameRegex.test("AMB-001-room-001")).toBe(false);
    });
  });

  describe("UUID Validation", () => {
    it("should validate UUID format (general)", () => {
      // General UUID format (any version)
      const uuidRegex =
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

      const validUUIDs = [
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        "123e4567-e89b-42d3-a456-426614174000",
        "a1b2c3d4-e5f6-7890-abcd-1234567890ab",
      ];

      validUUIDs.forEach((uuid) => {
        expect(uuidRegex.test(uuid)).toBe(true);
      });

      const invalidUUIDs = [
        "not-a-uuid",
        "550e8400e29b41d4a716446655440000", // Missing hyphens
        "550e8400-e29b-41d4-a716", // Too short
        "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz", // Invalid hex
      ];

      invalidUUIDs.forEach((uuid) => {
        expect(uuidRegex.test(uuid)).toBe(false);
      });
    });
  });
});
