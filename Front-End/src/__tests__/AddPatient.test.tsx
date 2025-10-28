
// Test file for the add Patient functionality, and will verify to see if the functionality works as expected
// when a user tries to add a new patient in Patient Management.

/**
 * @jest-environment jsdom
 */

//imports React, jest libraries, and user actions such as selection and typing
import React from "react";
import "@testing-library/jest-dom";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

// A mock for the router is implemented here to capture any redirects from the page
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
    const Button = ({ children, leftIcon, isLoading, ...props }: any) => (
        <button {...props}>
            {isLoading ? <span>Loading...</span> : null}
            {leftIcon ? <span className="icon">{leftIcon}</span> : null}
            {children}
        </button>
    );

    //Will render it if isOpen is true, implements dialog role for accessibility when searching
    const Modal = ({ isOpen, children, title }: any) =>
        isOpen ? (
            <div role="dialog" aria-label={title || "Modal"}>
                {children}
            </div>
        ) : null;
    const Alert = ({ children }: any) => <div role="alert">{children}</div>;
    const Loading = ({ text }: any) => <div>{text || "Loading"}</div>;

    //Basic HTML table components for testability without complex styling or other features
    const Table = ({ children }: any) => <table>{children}</table>;
    const TableHeader = ({ children }: any) => <thead>{children}</thead>;
    const TableBody = ({ children }: any) => <tbody>{children}</tbody>;
    const TableRow = ({ children, ...props }: any) => <tr {...props}>{children}</tr>;
    const TableCell = ({ children, header, ...props }: any) =>
        header ? <th {...props}>{children}</th> : <td {...props}>{children}</td>;

    // For the test, a select component is added for the mock when choosing genders
    const Select = React.forwardRef(({ label, options = [], ...rest }: any, ref) => {
        return (
            <label>
                {label && <span>{label}</span>}
                <select ref={ref} aria-label={label} {...rest}>
                    {options.map((o: any) => (
                        <option key={o.value} value={o.value}>{o.label}</option>
                    ))}
                </select>
            </label>
        );
    });

    Select.displayName = "Select";

    // All the mock components are exported here instead of using the real components
    return {
        Input,
        Select,
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

// Is creating a mock for utility helpers
jest.mock("@/utils/cn", () => ({
    cn: (...args: any[]) => args.filter(Boolean).join(" "),
    formatDate: (d: string) => new Date(d).toLocaleDateString("en-US"),
}));

// The patients hook is mocked here, create a fake patients to the list, 
// and manage state so the list updates after creation for easy viewing of the list
jest.mock("@/hooks", () => {
    const React = require("react");
    return {
        usePatients: () => {
            const [patients, setPatients] = React.useState([] as any[]);

            // Mocking adding a patient to the list, including an id, and important timestamps
            const createPatient = async (data: any) => {
                const now = new Date().toISOString();
                const newPatient = {
                    id: Math.random().toString(36).slice(2),
                    created_at: now,
                    updated_at: now,
                    ...data,
                } as any;
                setPatients((prev: any[]) => [...prev, newPatient]);
                return { success: true, data: newPatient } as any;
            };

            // usePatients hook is used to return patients, loading state, and createPatient function
            return {
                patients,
                isLoading: false,
                error: null,
                createPatient,
                deletePatient: async () => ({ success: true } as any),
            };
        },
    };
});

// Imports the PatientList using the mocked hooks and components
import { PatientList } from "../features/patients/PatientList";

// The testing suite for adding a patient
describe("Patient Management - Add Patient flow", () => {
    // Test to check for successful patient creation flow
    it("opens the modal, validates input, creates a patient, and displays all entered data", async () => {
        render(<PatientList />); // Renders the PatientList component

        // Makes sure the "Add New Patient" button is present
        expect(screen.getByText(/Patient Management/i)).toBeInTheDocument();
        const addButton = screen.getByRole("button", { name: /add new patient/i });
        expect(addButton).toBeEnabled();

        // Opens a modal dialog when clicking the add button option, and requires it to be present
        await userEvent.click(addButton);
        const dialog = await screen.findByRole("dialog", { name: /add new patient/i });
        expect(dialog).toBeInTheDocument();

        // The form fields are filled out with valid first and last name John Doe
        await userEvent.type(screen.getByLabelText(/first name/i), "John");
        await userEvent.type(screen.getByLabelText(/last name/i), "Doe");

        // The form fields are filled out with valid birth date
        await userEvent.type(screen.getByLabelText(/date of birth/i), "2000-01-02");

        // The gender seleft dropdown is opened, and male is selected, and verified.
        const gender = within(dialog).getByRole("combobox") as HTMLSelectElement;
        await userEvent.selectOptions(gender, "male");
        expect(gender).toHaveValue("male");

        // Contact info is filled out here
        await userEvent.type(screen.getByLabelText(/email address/i), "john@example.com");

        // A formatted phone number is entered here
        await userEvent.type(screen.getByLabelText(/phone number/i), "(555) 123-4567");
        await userEvent.type(
            screen.getByLabelText(/^address$/i),
            "123 Main St, Sacramento, CA 95819"
        );
        await userEvent.type(
            screen.getByLabelText(/emergency contact/i),
            "Jane Doe - 916-555-0000"
        );

        // The "Submit" button is clicked to create the patient in the mock
        const submit = screen.getByRole("button", { name: /create patient/i });
        await userEvent.click(submit);

        // If successful, the modal popup should close automatically to make sure it is functioning properly
        await waitFor(() => {
            expect(screen.queryByRole("dialog", { name: /add new patient/i })).not.toBeInTheDocument();
        });

        // The newly added patient should appear in the patient list with all entered data from the form
        // name must match John Doe
        expect(await screen.findByText(/John Doe/)).toBeInTheDocument();
        // email must match john@example.com
        expect(screen.getByText("john@example.com")).toBeInTheDocument();
        // normalized phone number must match 5551234567
        expect(screen.getByText("5551234567")).toBeInTheDocument();
        // address must match 123 Main St
        expect(screen.getByText(/123 Main St/i)).toBeInTheDocument();

        // The born date must appear correctly formatted
        expect(screen.getByText(/Born:/i)).toBeInTheDocument();

        // Must verify that the Added label appears for the new patient to make sure timestamp is shown
        expect(screen.getByText(/Added/i)).toBeInTheDocument();
    });

    // This is the test to check for validation errors when required fields are missing or invalid in the form
    it("prevents submission and shows an error when required fields are missing or invalid", async () => {
        render(<PatientList />); //renders the PatientList component

        // Opens the add patient modal dialog on screen
        await userEvent.click(screen.getByRole("button", { name: /add new patient/i }));
        const dialog = await screen.findByRole("dialog", { name: /add new patient/i });
        expect(dialog).toBeInTheDocument();

        // The form is only partially filled out, missing required phone number to trigger validation
        await userEvent.type(screen.getByLabelText(/first name/i), "Alice");
        await userEvent.type(screen.getByLabelText(/last name/i), "Smith");
        await userEvent.type(screen.getByLabelText(/date of birth/i), "1999-12-31");
        await userEvent.type(screen.getByLabelText(/^Address$/i), "12 St");

        // The submit button is clicked to try to create the patient
        await userEvent.click(screen.getByRole("button", { name: /create patient/i }));

        // The component will show an error in the modal when validation fails, verify that it appears here
        const alert = await screen.findByRole("alert");
        expect(alert).toHaveTextContent(/phone number is required/i);

        // When it fails to add a patient due to validation, the modal should stay open and allow
        // for corrections to be made so that form can be resubmitted correctly
        expect(screen.getByRole("dialog", { name: /add new patient/i })).toBeInTheDocument();
    });
});

