import React from 'react';
// Ensure React global is available in tests for components using `React` at runtime
(global as any).React = React;
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock next/navigation
const mockPush = jest.fn();
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}));

// Mock authService module
jest.mock('@/services/authService', () => ({
  authService: {
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
  }
}));

import { ForgotPasswordForm } from '@/features/auth/ForgotPasswordForm';
import { PasswordResetForm } from '@/features/auth/PasswordResetForm';
import { authService } from '@/services/authService';

describe('ForgotPasswordForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('shows success message when requestPasswordReset succeeds', async () => {
    (authService.requestPasswordReset as jest.Mock).mockResolvedValue({ error: null });
    render(<ForgotPasswordForm />);

    const emailInput = screen.getByPlaceholderText(/doctor@stemsight.com/i);
    fireEvent.change(emailInput, { target: { value: 'doc@example.com' } });

    const btn = screen.getByRole('button', { name: /Send Reset Link/i });
    fireEvent.click(btn);

    await waitFor(() => expect(authService.requestPasswordReset).toHaveBeenCalledWith('doc@example.com'));
    expect(await screen.findByText(/Password reset link has been sent to your email address./i)).toBeInTheDocument();
  });

  it('shows error message when requestPasswordReset fails', async () => {
    (authService.requestPasswordReset as jest.Mock).mockResolvedValue({ error: 'Server error' });
    render(<ForgotPasswordForm />);

    const emailInput = screen.getByPlaceholderText(/doctor@stemsight.com/i);
    fireEvent.change(emailInput, { target: { value: 'doc@example.com' } });

    const btn = screen.getByRole('button', { name: /Send Reset Link/i });
    fireEvent.click(btn);

    await waitFor(() => expect(authService.requestPasswordReset).toHaveBeenCalled());
    expect(await screen.findByText(/Server error/i)).toBeInTheDocument();
  });
});

describe('PasswordResetForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('validates token missing', () => {
    // Ensure no token in URL
    const originalHref = window.location.href;
    window.history.pushState({}, 'Reset', '/password-reset');
    jest.useFakeTimers();
    render(<PasswordResetForm />);
    expect(screen.getByText(/Invalid or missing reset token/i)).toBeInTheDocument();
    window.history.pushState({}, '', originalHref);
  });

  it('shows validation error for mismatched passwords', async () => {
    // Set token in URL
    const originalHref = window.location.href;
    window.history.pushState({}, 'Reset', '/password-reset?token=tok123');
    render(<PasswordResetForm />);

    const pwd = screen.getByPlaceholderText(/Enter your new password/i);
    const confirm = screen.getByPlaceholderText(/Confirm your new password/i);
    const btn = screen.getByRole('button', { name: /Reset Password/i });

    fireEvent.change(pwd, { target: { value: 'Abcdef1!' } });
    fireEvent.change(confirm, { target: { value: 'Mismatch1!' } });
    fireEvent.click(btn);

    expect(await screen.findByText(/Passwords do not match./i)).toBeInTheDocument();
  });

  it('shows validation error for weak password', async () => {
    const originalHref = window.location.href;
    window.history.pushState({}, 'Reset', '/password-reset?token=tok123');
    render(<PasswordResetForm />);

    const pwd = screen.getByPlaceholderText(/Enter your new password/i);
    const confirm = screen.getByPlaceholderText(/Confirm your new password/i);
    const btn = screen.getByRole('button', { name: /Reset Password/i });

    fireEvent.change(pwd, { target: { value: 'short' } });
    fireEvent.change(confirm, { target: { value: 'short' } });
    fireEvent.click(btn);

    expect(await screen.findByText(/Password must be at least 8 characters long./i)).toBeInTheDocument();
    window.history.pushState({}, '', originalHref);
  });

  it('calls authService.confirmPasswordReset on valid input', async () => {
    (authService.confirmPasswordReset as jest.Mock).mockResolvedValue({ error: null });
    const originalHref = window.location.href;
    window.history.pushState({}, 'Reset', '/password-reset?token=tok123');

    render(<PasswordResetForm />);

    const pwd = screen.getByPlaceholderText(/Enter your new password/i);
    const confirm = screen.getByPlaceholderText(/Confirm your new password/i);
    const btn = screen.getByRole('button', { name: /Reset Password/i });

    fireEvent.change(pwd, { target: { value: 'Abcd1234!' } });
    fireEvent.change(confirm, { target: { value: 'Abcd1234!' } });
    fireEvent.click(btn);

    await waitFor(() => expect(authService.confirmPasswordReset).toHaveBeenCalled());
    expect(await screen.findByText(/Password successfully reset/i)).toBeInTheDocument();

    // Router should be invoked after the success (hook schedules a redirect)
    jest.advanceTimersByTime(3000);
    expect(mockPush).toHaveBeenCalledWith('/');
    jest.useRealTimers();
    window.history.pushState({}, '', originalHref);
  });
});
