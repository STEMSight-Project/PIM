// Test file for delete Patient function, and will verify to see if the functionality works as expected
// when a user tries to delete a patient record from the Patient Management page.

/**
 * @jest-environment jsdom
 */

//imports React, jest libraries, and user actions such as selection and typing
import React from "react";
import "@testing-library/jest-dom";
import { render, screen, within, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";


// Will mock the router to catch any redirects from the page
jest.mock("next/link", () => ({
    __esModule: true,
    default: ({ href, children }: any) => <a href={href}>{children}</a>,
}));

// Will mock the UI components to barebones HTML for testability
jest.mock("@/components/ui", () => {
    const React = require("react");
    // Creates simple input component in a label
    const Input = React.forwardRef((props: any, ref: any) => {
        const { label, ...rest } = props || {};
        return (
            <label>
                {label && <span>{label}</span>}
                <input ref={ref} aria-label={label || rest["aria-label"]} {...rest} />
            </label>
        );
    });
    Input.displayName = "Input";

    // Will use a basic button instead, and for modal will render if it is open
    const Button = ({ children, ...props }: any) => <button {...props}>{children}</button>;
    const Modal = ({ isOpen, children, title }: any) =>
        isOpen ? (
            <div role="dialog" aria-label={title || "Modal"}>
                {children}
            </div>
        ) : null;
    const Alert = ({ children }: any) => <div role="alert">{children}</div>;
    const Loading = ({ text }: any) => <div>{text || "Loading"}</div>;
    const Table = ({ children }: any) => <table>{children}</table>;
    const TableHeader = ({ children }: any) => <thead>{children}</thead>;
    const TableBody = ({ children }: any) => <tbody>{children}</tbody>;
    const TableRow = ({ children, ...props }: any) => <tr {...props}>{children}</tr>;
    const TableCell = ({ children, header, ...props }: any) =>
        header ? <th {...props}>{children}</th> : <td {...props}>{children}</td>;

    return {
        Input,
        Button,
        Modal,
        Alert,
        Loading,
        Table,
        TableHeader,
        TableBody,
        TableRow,
        TableCell,
    };
});

// Mock utility helpers used by PatientList
jest.mock("@/utils/cn", () => ({
    cn: (...args: any[]) => args.filter(Boolean).join(" "),
    formatDate: (d: string) => new Date(d).toLocaleDateString("en-US"),
}));

// This is the mock for the patient delete itself, uses usePatients hook
jest.mock("@/hooks", () => {
    const React = require("react");
    const nowISO = new Date().toISOString();
    return {
        usePatients: () => {
            const [patients, setPatients] = React.useState([
                {
                    id: "p1",
                    first_name: "John",
                    last_name: "Doe",
                    date_of_birth: "1990-01-01",
                    gender: "male",
                    email: "john@example.com",
                    phone: "5551234567",
                    address: "123 Main St",
                    emergency_contact: "Jane - 9165550000",
                    created_at: nowISO,
                    updated_at: nowISO,
                },
                {
                    id: "p2",
                    first_name: "Jane",
                    last_name: "Smith",
                    date_of_birth: "1992-02-02",
                    gender: "female",
                    email: "jane@example.com",
                    phone: "5559876543",
                    address: "456 Oak Ave",
                    emergency_contact: "John - 9165551111",
                    created_at: nowISO,
                    updated_at: nowISO,
                },
            ] as any[]);

            // Will use the patient ID to filter out deleted patient from state
            const deletePatient = async (patientId: string) => {
                setPatients((prev: any[]) => prev.filter((p) => p.id !== patientId));
                return { success: true } as any;
            };

            //mocking backend data retrieval and update
            return {
                patients,
                isLoading: false,
                error: null,
                createPatient: async () => ({ success: true } as any),
                updatePatient: async () => ({ success: true } as any),
                deletePatient,
            };
        },
    };
});

// Will import PatientList with the mocked usePatients hook for testing
import { PatientList } from "../features/patients/PatientList";

//description of the test suite
describe("Patient Management - Delete Patient flow", () => {
    beforeEach(() => {
        // Will ensure the confirm dialog always returns true for deletion
        jest.spyOn(window, "confirm").mockReturnValue(true);
    });

    afterEach(() => {
        (window.confirm as jest.Mock).mockRestore?.();
    });

    // Actual test case for deleting a patient
    it("removes the patient after confirming deletion (table view)", async () => {
        render(<PatientList />);

        // Both mock patients should be rendered
        expect(await screen.findByText(/John Doe/)).toBeInTheDocument();
        expect(screen.getByText(/Jane Smith/)).toBeInTheDocument();

        // The views are changed to table view
        await userEvent.click(screen.getByRole("button", { name: /table/i }));

        // Locate our mock patient "Jane Smith"
        const row = screen.getByText(/Jane Smith/).closest("tr");
        expect(row).toBeTruthy();
        const rowUtils = within(row as HTMLElement);

        // Will click on the last button that exists (view, edit, delete)
        const buttons = rowUtils.getAllByRole("button");
        const deleteBtn = buttons[buttons.length - 1];
        await userEvent.click(deleteBtn);

        // Must verify that Jane Smith is no longer in the document
        await waitFor(() => {
            expect(screen.queryByText(/Jane Smith/)).not.toBeInTheDocument();
        });
        // We did not delete John Doe, so he should still be present in our mock data
        expect(screen.getByText(/John Doe/)).toBeInTheDocument();
    });
});
