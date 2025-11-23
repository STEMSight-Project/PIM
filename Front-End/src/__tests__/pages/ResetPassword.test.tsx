import React from "react";
import {render, screen, fireEvent } from "@testing-library/react";

const mockReset = jest.fn();

jest.mock("@/hooks", () => ({
    usePasswordReset: () => ({
        resetPassword: mockReset,
        isLoading: false,
        error: null,
        success: null,
  }),
}));

jest.mock("next/navigation", () => ({
    useRouter: () => ({ push: jest.fn() }),
}));

jest.mock("@/components/ModalPopUp/Modal", () => ({
    __esModule: true,
    default: ({ children, hidden }: { children: React.ReactNode; hidden: boolean }) => (
    hidden ? null : React.createElement('div', { 'data-testid': 'modal' }, children)
  ),
}));

import ResetPassword from "@/app/password-reset/reset-password";

describe("Reset Password page", () => {
    beforeEach(() => {
        mockReset.mockReset();
  });

    it("shows error when passwords do not match", async () => {
        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "Password1!" } });
        fireEvent.change(inputs[1], { target: { value: "Different1!" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));

        expect(await screen.findByText("Passwords do not match.")).toBeInTheDocument();
  });

    it("shows success message when resetPassword returns true", async () => {
        mockReset.mockResolvedValueOnce(true);

        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "Password1!" } });
        fireEvent.change(inputs[1], { target: { value: "Password1!" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));

        expect(await screen.findByText("Password reset successful!")).toBeInTheDocument();
  });

    it("shows error when password is too short", async () => {
        mockReset.mockResolvedValueOnce(false);

        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "123" } });
        fireEvent.change(inputs[1], { target: { value: "123" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));
    
        expect(await screen.findByText("Unable to reset your password. Please try again!")).toBeInTheDocument();
    });

    it("shows error when password does not have capital letter", async () => {
        mockReset.mockResolvedValueOnce(false);

        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "password1!" } });
        fireEvent.change(inputs[1], { target: { value: "password1!" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));
    
        expect(await screen.findByText("Unable to reset your password. Please try again!")).toBeInTheDocument();
    });

    it("shows error when password does not have special symbol", async () => {
        mockReset.mockResolvedValueOnce(false);

        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "Password12" } });
        fireEvent.change(inputs[1], { target: { value: "Password12" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));

        expect(await screen.findByText("Unable to reset your password. Please try again!")).toBeInTheDocument();
    });

    it("does not call resetPassword when password is empty", async () => {
        render(<ResetPassword />);

        const inputs = document.querySelectorAll('input[type="password"]');
        fireEvent.change(inputs[0], { target: { value: "" } });
        fireEvent.change(inputs[1], { target: { value: "" } });

        fireEvent.click(screen.getByRole("button", { name: /Reset Password/i }));

        expect(mockReset).not.toHaveBeenCalled();
    });

    it("renders correctly", () => {
        render(<ResetPassword />);

        expect(screen.getByText("Reset Your Password")).toBeInTheDocument();
        expect(screen.getByText("New Password")).toBeInTheDocument();
        expect(screen.getByText("Confirm Password")).toBeInTheDocument();
        expect(screen.getByRole("button", { name: /Reset Password/i })).toBeInTheDocument();
    });


});
