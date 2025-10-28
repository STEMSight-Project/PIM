// Test file for CreateAccount component, and will verify to see if the functionality works as expected
// when a user tries to create a new account as a doctor.

/**
 * @jest-environment jsdom
 */

//imports React, jest libraries, and user actions such as selection and typing
import React from "react";
import "@testing-library/jest-dom";
import { render, screen, waitFor, within } from "@testing-library/react";
import { act } from "react-dom/test-utils";
import userEvent from "@testing-library/user-event";
let user: ReturnType<typeof userEvent.setup>;


// Will mock the router to catch any redirects from the page
const pushMock = jest.fn();
jest.mock("next/navigation", () => ({
    // Will keep other exports
    __esModule: true,
    useRouter: () => ({ push: pushMock }),
}));


// will retrieve any API calls as if it were a client
const getMock = jest.fn();
const postMock = jest.fn();
jest.mock("@/services/api", () => ({
    api: {
        get: (...args: any[]) => getMock(...args),
        post: (...args: any[]) => postMock(...args),
    },
}));


// Will import the CreateAccount component to be tested after mock has been implemented
import CreateAccount from "@/app/create-account/create-account";

// The main test suite for CreateAccount component, will clear each call before and after each
// test to ensure no interference between tests.
describe("Create Account - doctor registration flow", () => {
    beforeEach(() => {
        jest.useFakeTimers();
        user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
        pushMock.mockReset();
        getMock.mockReset();
        postMock.mockReset();
    });

    afterEach(() => {
        jest.useRealTimers();
    });


    it("submits valid form, shows success modal, and redirects after countdown", async () => {
        // Will retrieve the specializations from backend
        getMock.mockResolvedValue({
            data: [
                "Cardiology",
                "Neurology",
                "Pediatrics",
            ], error: null
        });

        // Registration success
        postMock.mockResolvedValue({ data: { ok: true }, error: null });

        render(<CreateAccount />); // Render the CreateAccount component

        // fields are filled out with mock data (labels are not programmatically associated; scope by group container)
        const firstNameGroup = screen.getByText(/first name/i).closest("div") as HTMLElement;
        const firstNameInput = within(firstNameGroup).getByRole("textbox") as HTMLInputElement;
        await user.type(firstNameInput, "John");

        const lastNameGroup = screen.getByText(/last name/i).closest("div") as HTMLElement;
        const lastNameInput = within(lastNameGroup).getByRole("textbox") as HTMLInputElement;
        await user.type(lastNameInput, "Smith");

        // will select a specialization from the dropdown, makes sure they load first
        // Specialization select (query by role since label isn't associated)
        const specSelect = await screen.findByRole("combobox");
        await user.selectOptions(specSelect, "Neurology");
        expect(specSelect).toHaveValue("Neurology");

        const emailGroup = screen.getByText(/work email/i).closest("div") as HTMLElement;
        const emailInput = within(emailGroup).getByRole("textbox") as HTMLInputElement;
        await user.type(emailInput, "johnsmith@stemsight.com");

        const passwordGroup = screen.getByText(/^password$/i).closest("div") as HTMLElement;
        const passwordInput = passwordGroup.querySelector('input') as HTMLInputElement;
        await user.type(passwordInput, "supersecret");

        const confirmGroup = screen.getByText(/confirm password/i).closest("div") as HTMLElement;
        const confirmInput = confirmGroup.querySelector('input') as HTMLInputElement;
        await user.type(confirmInput, "supersecret");

        const phoneGroup = screen.getByText(/primary phone/i).closest("div") as HTMLElement;
        const phoneInput = within(phoneGroup).getByRole("textbox") as HTMLInputElement;
        await user.type(phoneInput, "(916) 222-1234");


        // Will submit the form here
        await user.click(
            screen.getByRole("button", { name: /create account/i })
        );

        // the success overlay appears here
        await screen.findByRole('heading', { name: /check your email/i });
        expect(
            screen.getByText(/we've sent a verification email to your inbox/i)
        ).toBeInTheDocument();

        // we wait since component uses 4-second countdown.
        await waitFor(() => expect(postMock).toHaveBeenCalled());
        // Verify countdown text updates from 4 to 3 seconds as timers advance, to ensure countdown works
        expect(screen.getByText(/Redirecting to sign in in\s*4\s*seconds/i)).toBeInTheDocument();
        await act(async () => {
            jest.advanceTimersByTime(1000);
        });
        expect(screen.getByText(/Redirecting to sign in in\s*3\s*seconds/i)).toBeInTheDocument();
    });


    // Will test to see if the functionality for checking if passwords are the same works, and phone length
    it("shows validation errors for invalid input (mismatched password, short phone)", async () => {
        // Fall back to specializations or if empty
        getMock.mockResolvedValue({ data: [], error: null });

        render(<CreateAccount />);

        // Each field is filled here.
        const firstNameGroup2 = screen.getByText(/first name/i).closest("div") as HTMLElement;
        await user.type(within(firstNameGroup2).getByRole("textbox"), "Jane");

        const lastNameGroup2 = screen.getByText(/last name/i).closest("div") as HTMLElement;
        await user.type(within(lastNameGroup2).getByRole("textbox"), "Doe");

        const emailGroup2 = screen.getByText(/work email/i).closest("div") as HTMLElement;
        await user.type(within(emailGroup2).getByRole("textbox"), "janedoe@stemsight.com");

        const passwordGroup2 = screen.getByText(/^password$/i).closest("div") as HTMLElement;
        await user.type(passwordGroup2.querySelector('input') as HTMLInputElement, "abcdefgh");

        const confirmGroup2 = screen.getByText(/confirm password/i).closest("div") as HTMLElement;
        await user.type(confirmGroup2.querySelector('input') as HTMLInputElement, "abcxxxxx"); // mismatch

        const phoneGroup2 = screen.getByText(/primary phone/i).closest("div") as HTMLElement;
        await user.type(within(phoneGroup2).getByRole("textbox"), "12345"); // too short

        await user.click(
            screen.getByRole("button", { name: /create account/i })
        );

        // Will check for validation error messages on the screen to ensure validity
        expect(
            await screen.findByText(/passwords do not match/i)
        ).toBeInTheDocument();

        // The password mismatch is fixed, but the invalid phone length still exists here, must show error here still
        const confirmInput2 = confirmGroup2.querySelector('input') as HTMLInputElement;
        await user.clear(confirmInput2);
        await user.type(confirmInput2, "abcdefgh");

        await user.click(
            screen.getByRole("button", { name: /create account/i })
        );

        expect(
            await screen.findByText(/primary phone must have at least 10 digits/i)
        ).toBeInTheDocument();
    });
});
