// React, testing library imports, and the login form component import
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { LoginForm } from "@/features/auth/LoginForm";
import { vi } from "vitest";

// The next/navigation's router is being mocked to test navigation after login
const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

// The useAuth hook is being mocked to control login behavior in tests
const mockLogin = vi.fn();
vi.mock("@/hooks", () => ({
  useAuth: () => ({
    login: mockLogin,
    isLoading: false,
  }),
}));

// The loginForm test suite with 4 test cases
describe("LoginForm", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // Test to ensure that email is valid and criteria are met
  it("shows validation errors for empty fields and invalid email", async () => {
    const { container } = render(<LoginForm />);
    // bypasses the browser HTML5 validation so validation of component runs
    const form = container.querySelector("form") as HTMLFormElement | null;
    if (form) form.noValidate = true;

    // This will simulate submitting empty email and password fields, and ensure error message appears
    fireEvent.change(screen.getByLabelText(/Email Address/i), {
      target: { value: " " },
    });
    fireEvent.change(screen.getByLabelText(/Password/i), {
      target: { value: " " },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign in/i }));
    expect(
      await screen.findByText(/Email and password are required/i)
    ).toBeInTheDocument();

    // This will simulate submitting an invalid email format and ensure error message appears
    fireEvent.change(screen.getByLabelText(/Email Address/i), {
      target: { value: "invalid-email" },
    });
    fireEvent.change(screen.getByLabelText(/Password/i), {
      target: { value: "password123" },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign in/i }));

    expect(
      await screen.findByText(/Please enter a valid email address/i)
    ).toBeInTheDocument();
  });

  // Test to ensure that if login is successful, navigation to dashboard occurs
  it("navigates to dashboard on successful login", async () => {
    mockLogin.mockResolvedValue({ success: true });

    // bypasses the browser HTML5 validation so validation of component runs
    const { container } = render(<LoginForm />);
    const form = container.querySelector("form") as HTMLFormElement | null;
    if (form) form.noValidate = true;

    // Simulate user entering valid credentials and submitting the form
    fireEvent.change(screen.getByLabelText(/Email Address/i), {
      target: { value: "doctor@stemsight.com" },
    });
    fireEvent.change(screen.getByLabelText(/Password/i), {
      target: { value: "correct-password" },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign in/i }));

    // Waits for the login function to be called and checks if navigation to dashboard occurred
    await waitFor(() =>
      expect(mockLogin).toHaveBeenCalledWith({
        email: "doctor@stemsight.com",
        password: "correct-password",
      })
    );
    expect(mockPush).toHaveBeenCalledWith("/dashboard");
  });

  // Test to ensure that server error messages are displayed correctly if user fails to login
  it("shows server error message for wrong password", async () => {
    mockLogin.mockResolvedValue({ success: false, error: "Wrong credentials" });

    // bypasses the browser HTML5 validation so validation of component runs
    const { container } = render(<LoginForm />);
    const form = container.querySelector("form") as HTMLFormElement | null;
    if (form) form.noValidate = true;

    // Simulate user entering invalid credentials and submitting the form
    fireEvent.change(screen.getByLabelText(/Email Address/i), {
      target: { value: "doctor@stemsight.com" },
    });
    fireEvent.change(screen.getByLabelText(/Password/i), {
      target: { value: "wrong-password" },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign in/i }));

    // Waits for the error message to appear on the screen and ensures navigation did NOT occur to dashboard
    expect(await screen.findByText(/Wrong credentials/i)).toBeInTheDocument();
    expect(mockPush).not.toHaveBeenCalled();
  });

  // Test to ensure that unverified account message is displayed correctly
  it("shows unverified account message when server returns that error", async () => {
    mockLogin.mockResolvedValue({
      success: false,
      error: "Account not verified",
    });

    // bypasses the browser HTML5 validation so validation of component runs
    const { container } = render(<LoginForm />);
    const form = container.querySelector("form") as HTMLFormElement | null;
    if (form) form.noValidate = true;

    // Simulate user entering credentials for an unverified account and submitting the form
    fireEvent.change(screen.getByLabelText(/Email Address/i), {
      target: { value: "doctor@stemsight.com" },
    });
    fireEvent.change(screen.getByLabelText(/Password/i), {
      target: { value: "password123" },
    });
    fireEvent.click(screen.getByRole("button", { name: /sign in/i }));

    // Will expect the unverified account error message to appear on screen and ensure no navigation occurred
    expect(
      await screen.findByText(/Account not verified/i)
    ).toBeInTheDocument();
    expect(mockPush).not.toHaveBeenCalled();
  });
});
