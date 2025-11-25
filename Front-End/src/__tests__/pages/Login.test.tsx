import React from "react";
import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { LoginForm } from "@/features/auth/LoginForm";

const mockLogin = jest.fn();
const mockPush = jest.fn();

jest.mock("@/hooks", () => ({
  useAuth: () => ({
    login: mockLogin,
    isLoading: false,
  }),
}));

jest.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

describe("LoginForm", () => {
  beforeEach(() => {
    mockLogin.mockReset();
    mockPush.mockReset();
  });

  it("renders the login form correctly", () => {
    render(<LoginForm />);

    expect(screen.getByLabelText(/Email Address/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Password/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Sign In/i })).toBeInTheDocument();
    expect(screen.getByText(/Forgot your password?/i)).toBeInTheDocument();
  });

  it("shows error when email is empty", async () => {
    const { container } = render(<LoginForm />);
    const form = container.querySelector('form') as HTMLFormElement | null;
    if (form) form.noValidate = true;

    fireEvent.change(screen.getByLabelText(/Password/i), { target: { value: "password123" } });
    fireEvent.click(screen.getByRole("button", { name: /Sign In/i }));

    expect(await screen.findByText(/Email and password are required./i)).toBeInTheDocument();
  });

  it("shows error when password is empty", async () => {
    const { container } = render(<LoginForm />);
    const form = container.querySelector('form') as HTMLFormElement | null;
    if (form) form.noValidate = true;

    fireEvent.change(screen.getByLabelText(/Email Address/i), { target: { value: "test@example.com" } });
    fireEvent.click(screen.getByRole("button", { name: /Sign In/i }));

    expect(await screen.findByText(/Email and password are required./i)).toBeInTheDocument();
  });

  it("shows error for invalid email format", async () => {
    const { container } = render(<LoginForm />);
    const form = container.querySelector('form') as HTMLFormElement | null;
    if (form) form.noValidate = true;

    fireEvent.change(screen.getByLabelText(/Email Address/i), { target: { value: "invalid-email" } });
    fireEvent.change(screen.getByLabelText(/Password/i), { target: { value: "password123" } });
    fireEvent.click(screen.getByRole("button", { name: /Sign In/i }));

    expect(await screen.findByText(/Please enter a valid email address./i)).toBeInTheDocument();
  });

  it("calls login and redirects on success", async () => {
    mockLogin.mockResolvedValue({ success: true });

    const { container } = render(<LoginForm />);
    const form = container.querySelector('form') as HTMLFormElement | null;
    if (form) form.noValidate = true;

    fireEvent.change(screen.getByLabelText(/Email Address/i), { target: { value: "test@example.com" } });
    fireEvent.change(screen.getByLabelText(/Password/i), { target: { value: "password123" } });
    fireEvent.click(screen.getByRole("button", { name: /Sign In/i }));

    // wait for login to be called and for router push to be invoked
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalled();
      expect(mockPush).toHaveBeenCalled();
    });
  });

  it("shows error when login fails", async () => {
    mockLogin.mockResolvedValue({ success: false, error: "Invalid credentials" });

    const { container } = render(<LoginForm />);
    const form = container.querySelector('form') as HTMLFormElement | null;
    if (form) form.noValidate = true;

    fireEvent.change(screen.getByLabelText(/Email Address/i), { target: { value: "test@example.com" } });
    fireEvent.change(screen.getByLabelText(/Password/i), { target: { value: "wrongpassword" } });
    fireEvent.click(screen.getByRole("button", { name: /Sign In/i }));

    expect(await screen.findByText(/Invalid credentials/i)).toBeInTheDocument();
  });

  it("toggles password visibility", () => {
    render(<LoginForm />);

    const passwordInput = screen.getByLabelText(/Password/i);
    const toggleButton = screen.getByRole("button", { name: "" }); // The toggle button has no name, but it's the button inside the relative div

    expect(passwordInput).toHaveAttribute("type", "password");

    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute("type", "text");

    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute("type", "password");
  });
});