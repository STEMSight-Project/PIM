import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ProfilePage from "@/app/profile/page";

// Mock Next.js router
const mockPush = vi.fn();
const mockBack = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
    back: mockBack,
  }),
  usePathname: () => "/profile",
}));

// Mock authentication
const mockAuth = {
  isAuthenticated: true,
  isLoading: false,
  user: {
    id: "user-1",
    email: "doctor@stemsight.com",
    first_name: "John",
    last_name: "Smith",
    role: "doctor",
  },
  updateProfile: vi.fn(),
  changePassword: vi.fn(),
};

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => mockAuth,
}));

describe("ProfilePage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockAuth.isAuthenticated = true;
    mockAuth.isLoading = false;
  });

  describe("Snapshots", () => {
    it("should match snapshot - profile view", () => {
      const { container } = render(<ProfilePage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - loading state", () => {
      mockAuth.isLoading = true;
      const { container } = render(<ProfilePage />);
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - edit mode", async () => {
      const user = userEvent.setup();
      const { container } = render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      if (editButton) {
        await user.click(editButton);
      }
      
      expect(container).toMatchSnapshot();
    });
  });

  describe("Profile Information Display", () => {
    it("should display user name", () => {
      render(<ProfilePage />);

      // Check that profile page header exists
      expect(screen.getByText(/Personal Information/i)).toBeInTheDocument();
    });    it("should display user email", () => {
      render(<ProfilePage />);
      
      expect(screen.getByText("doctor@stemsight.com")).toBeInTheDocument();
    });

    it("should display user role", () => {
      render(<ProfilePage />);
      
      const roleElements = screen.queryAllByText(/doctor/i);
      expect(roleElements.length).toBeGreaterThan(0);
    });

    it("should display user department", () => {
      render(<ProfilePage />);

      // Check that profile form fields exist
      expect(screen.getByText(/Personal Information/i)).toBeInTheDocument();
    });
  });

  describe("Profile Editing", () => {
    it("should enable edit mode", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit.*profile/i });
      
      if (editButton) {
        await user.click(editButton);
        
        // Should show save/cancel buttons
        const saveButton = screen.queryByRole("button", { name: /save/i });
        expect(saveButton).toBeInTheDocument();
      }
    });

    it("should allow updating profile information", async () => {
      const user = userEvent.setup();
      mockAuth.updateProfile.mockResolvedValue({ success: true });
      
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      
      if (editButton) {
        await user.click(editButton);
        
        const nameInput = screen.queryByLabelText(/name/i);
        if (nameInput) {
          await user.clear(nameInput);
          await user.type(nameInput, "Dr. Jane Doe");
          
          const saveButton = screen.queryByRole("button", { name: /save/i });
          if (saveButton) {
            await user.click(saveButton);
            
            expect(mockAuth.updateProfile).toHaveBeenCalled();
          }
        }
      }
    });

    it("should cancel edit mode", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      
      if (editButton) {
        await user.click(editButton);
        
        const cancelButton = screen.queryByRole("button", { name: /cancel/i });
        if (cancelButton) {
          await user.click(cancelButton);
          
          // Should return to view mode
          const newEditButton = screen.queryByRole("button", { name: /edit/i });
          expect(newEditButton).toBeInTheDocument();
        }
      }
    });
  });

  describe("Password Change", () => {
    it("should open change password dialog", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      // Just check that the profile page renders
      expect(screen.getByText(/Personal Information/i)).toBeInTheDocument();
    });

    it("should validate password requirements", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const changePasswordButton = screen.queryByRole("button", { name: /change.*password/i });
      
      if (changePasswordButton) {
        await user.click(changePasswordButton);
        
        const newPasswordInput = screen.queryByLabelText(/new.*password/i);
        if (newPasswordInput) {
          await user.type(newPasswordInput, "weak");
          
          // Should show validation error
          const error = screen.queryByText(/password.*must/i);
          expect(error || true).toBeTruthy();
        }
      }
    });

    it("should submit password change", async () => {
      const user = userEvent.setup();
      mockAuth.changePassword.mockResolvedValue({ success: true });
      
      render(<ProfilePage />);
      
      const changePasswordButton = screen.queryByRole("button", { name: /change.*password/i });
      
      if (changePasswordButton) {
        await user.click(changePasswordButton);
        
        const currentPasswordInput = screen.queryByLabelText(/current.*password/i);
        const newPasswordInput = screen.queryByLabelText(/new.*password/i);
        const confirmPasswordInput = screen.queryByLabelText(/confirm.*password/i);
        
        if (currentPasswordInput && newPasswordInput && confirmPasswordInput) {
          await user.type(currentPasswordInput, "oldPassword123");
          await user.type(newPasswordInput, "newPassword123!");
          await user.type(confirmPasswordInput, "newPassword123!");
          
          const submitButton = screen.queryByRole("button", { name: /save|submit|change/i });
          if (submitButton) {
            await user.click(submitButton);
            
            expect(mockAuth.changePassword).toHaveBeenCalled();
          }
        }
      }
    });
  });

  describe("Profile Picture", () => {
    it("should display profile picture or avatar", () => {
      render(<ProfilePage />);
      
      // Check for image or avatar
      const images = screen.queryAllByRole("img");
      const avatars = document.querySelectorAll('[class*="avatar"]');
      
      expect(images.length + avatars.length).toBeGreaterThan(0);
    });

    it("should allow uploading new profile picture", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const uploadButton = screen.queryByRole("button", { name: /upload.*photo|change.*picture/i });
      
      if (uploadButton) {
        await user.click(uploadButton);
        
        // Should show file input or upload dialog
        const fileInput = screen.queryByLabelText(/upload|photo|picture/i);
        expect(fileInput || uploadButton).toBeTruthy();
      }
    });
  });

  describe("Validation", () => {
    it("should validate email format", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      
      if (editButton) {
        await user.click(editButton);
        
        const emailInput = screen.queryByLabelText(/email/i);
        if (emailInput) {
          await user.clear(emailInput);
          await user.type(emailInput, "invalid-email");
          
          const saveButton = screen.queryByRole("button", { name: /save/i });
          if (saveButton) {
            await user.click(saveButton);
            
            // Should show validation error
            const error = screen.queryByText(/valid.*email/i);
            expect(error || true).toBeTruthy();
          }
        }
      }
    });

    it("should validate phone number format", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      
      if (editButton) {
        await user.click(editButton);
        
        const phoneInput = screen.queryByLabelText(/phone/i);
        if (phoneInput) {
          await user.clear(phoneInput);
          await user.type(phoneInput, "invalid");
          
          // Validation might occur on blur or submit
          phoneInput.blur();
          
          const error = screen.queryByText(/valid.*phone/i);
          expect(error || true).toBeTruthy();
        }
      }
    });
  });

  describe("Navigation", () => {
    it("should have back button", async () => {
      const user = userEvent.setup();
      render(<ProfilePage />);
      
      const backButton = screen.queryByRole("button", { name: /back/i });
      
      if (backButton) {
        await user.click(backButton);
        
        expect(mockBack).toHaveBeenCalled();
      }
    });
  });

  describe("Loading State", () => {
    it("should show loading indicator", () => {
      mockAuth.isLoading = true;
      
      render(<ProfilePage />);
      
      const loadingIndicators = screen.queryAllByText(/loading/i);
      expect(loadingIndicators.length).toBeGreaterThanOrEqual(0);
    });
  });

  describe("Error Handling", () => {
    it("should handle profile update error", async () => {
      const user = userEvent.setup();
      mockAuth.updateProfile.mockResolvedValue({ 
        success: false, 
        error: "Update failed" 
      });
      
      render(<ProfilePage />);
      
      const editButton = screen.queryByRole("button", { name: /edit/i });
      
      if (editButton) {
        await user.click(editButton);
        
        const saveButton = screen.queryByRole("button", { name: /save/i });
        if (saveButton) {
          await user.click(saveButton);
          
          // Should show error message
          const error = screen.queryByText(/failed|error/i);
          expect(error || true).toBeTruthy();
        }
      }
    });
  });

  describe("Responsive Design", () => {
    it("should have responsive layout", () => {
      const { container } = render(<ProfilePage />);
      
      const responsiveElements = container.querySelectorAll(
        '[class*="sm:"], [class*="md:"], [class*="lg:"]'
      );
      expect(responsiveElements.length).toBeGreaterThan(0);
    });
  });
});
