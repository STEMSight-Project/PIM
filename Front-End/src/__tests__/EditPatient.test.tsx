// Test file for edit Patient function, and will verify to see if the functionality works as expected
// when a user tries to edit a patient record from the Patient Management page.

/**
 * @jest-environment jsdom
 */

//imports React, jest libraries, and user actions such as selection and typing
import React from "react";
import "@testing-library/jest-dom";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

// Will mock the router to and use it to track options of 1.saves and 2.cancel of edits
const pushMock = jest.fn();
const backMock = jest.fn();
jest.mock("next/navigation", () => ({
    __esModule: true,
    useRouter: () => ({ push: pushMock, back: backMock }),
}));

// For testability, mock the layout to a simple div to rid of complexities
jest.mock("@/components/layouts/DashboardLayout", () => ({
    DashboardLayout: ({ children }: any) => <div data-testid="layout">{children}</div>,
}));

// The mock UI components to barebones HTML for testability
jest.mock("@/components/ui", () => {
    const React = require("react");

    //The input is being wrapped in a label for accessibility
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

    // Simple button with loading state when isLoading is true
    const Button = ({ children, isLoading, ...props }: any) => (
        <button {...props}>{isLoading ? <span>Loading...</span> : children}</button>
    );

    //The loading component will show text, and alert will be a div with alert role for accessibility
    const Alert = ({ children }: any) => <div role="alert">{children}</div>;
    const Loading = ({ text }: any) => <div>{text || "Loading"}</div>;

    return { Input, Button, Alert, Loading }; //Four mocked components exported
});

// The mock for the patient hook, will return a single patient and will record updates made to it
const getPatientMock = jest.fn();
const updatePatientMock = jest.fn();
jest.mock("@/hooks", () => {
    const nowISO = new Date().toISOString();
    return {
        usePatients: () => ({
            //Will be the default patient returned unless overridden in a test
            getPatient: (id: string) =>
                getPatientMock(id) ||
                Promise.resolve({
                    success: true,
                    data: {
                        id,
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
                }),
            //when edits are saved, test will call updatePatientMock to record the call
            updatePatient: (id: string, data: any) => updatePatientMock(id, data) || Promise.resolve({ success: true }),
        }),
    };
});

// The import is made after the mocks were created to ensure that the mocks are used
import PatientEdit from "../app/patient-edit/PatientEdit";

//The patient edit test suite is below
describe("Patient Edit page", () => {
    beforeEach(() => {
        pushMock.mockReset();
        backMock.mockReset();
        getPatientMock.mockReset();
        updatePatientMock.mockReset();
    });

    // Test to verify that existing data loads, allows edits, saves, and navigates to details page
    it("loads existing data, allows edits, saves, and navigates to details page", async () => {
        // Ensure that data exists to load that won't fail validation
        getPatientMock.mockResolvedValueOnce({
            success: true,
            data: {
                id: "p123",
                first_name: "John",
                last_name: "Doe",
                date_of_birth: "1990-01-01",
                gender: "male",
                email: "john@example.com",
                phone: "5551234567",
                address: "123 Main St",
                emergency_contact: "9165550000",
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
            },
        });
        render(<PatientEdit patientId="p123" />); // Component being rendered for testing

        // Will use the inputs that was loaded earlier and verify their values
        const firstName = await screen.findByLabelText(/first name/i);
        expect(firstName).toHaveValue("John");
        expect(screen.getByLabelText(/last name/i)).toHaveValue("Doe");
        expect(screen.getByLabelText(/email/i)).toHaveValue("john@example.com");
        // The gender select is performed here, and male is the default value
        const gender = screen.getByRole("combobox") as HTMLSelectElement;
        expect(gender.value).toBe("male");

        // The changes are made to address and phone fields for the patient
        await userEvent.clear(screen.getByLabelText(/^address$/i));
        await userEvent.type(screen.getByLabelText(/^address$/i), "789 Pine Rd");
        await userEvent.clear(screen.getByLabelText(/phone/i));
        await userEvent.type(screen.getByLabelText(/phone/i), "(916) 555-2222");

        // The save button is clicked to save the edits
        await userEvent.click(screen.getByRole("button", { name: /save/i }));

        // The updatePatient function is called with the correct parameters from the edits
        await waitFor(() => expect(updatePatientMock).toHaveBeenCalled());
        const [calledId, payload] = updatePatientMock.mock.calls[0];
        expect(calledId).toBe("p123");
        expect(payload.address).toBe("789 Pine Rd");
        expect(payload.phone).toBe("(916) 555-2222");

        // If successful, will navigate to patient details page to show the updated patient record
        await waitFor(() => expect(pushMock).toHaveBeenCalledWith("/patients/p123"));
    });

    //Test to make sure that invalid phone number format is not accepted and shows error
    it("shows validation error for invalid phone format", async () => {
        // Valid data so that it loads without error
        getPatientMock.mockResolvedValueOnce({
            success: true,
            data: {
                id: "p123",
                first_name: "John",
                last_name: "Doe",
                date_of_birth: "1990-01-01",
                gender: "male",
                email: "john@example.com",
                phone: "5551234567",
                address: "123 Main St",
                emergency_contact: "9165550000",
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
            },
        });
        render(<PatientEdit patientId="p123" />); // Component being rendered for testing

        // Is waiting for form to load and verify the first name
        const firstName = await screen.findByLabelText(/first name/i);
        expect(firstName).toHaveValue("John");

        // An invalid phone number is entered to trigger validation error here
        const phone = screen.getByLabelText(/phone/i);
        await userEvent.clear(phone);
        await userEvent.type(phone, "123");

        // A mock click is made to try to save the edits for the patient
        await userEvent.click(screen.getByRole("button", { name: /save/i }));

        // Is expecting to NOT work and the system NOT accept this invalid phone number
        const alert = await screen.findByRole("alert");
        expect(alert).toHaveTextContent(/invalid phone number format/i);

        // This verifies that updatePatient for the mock was NOT called because phone was invalid for validation
        expect(pushMock).not.toHaveBeenCalled();
    });
});

