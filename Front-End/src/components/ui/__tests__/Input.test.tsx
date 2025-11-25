import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Input } from "@/components/ui/Input";

describe("Input Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - default input", () => {
      const { container } = render(
        <Input placeholder="Enter text" id="test-input-1" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with label", () => {
      const { container } = render(
        <Input
          label="Username"
          placeholder="Enter username"
          id="test-input-2"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with error", () => {
      const { container } = render(
        <Input
          label="Email"
          error="Invalid email address"
          placeholder="you@example.com"
          id="test-input-3"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with helper text", () => {
      const { container } = render(
        <Input
          label="Password"
          helperText="Must be at least 8 characters"
          type="password"
          id="test-input-4"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - disabled state", () => {
      const { container } = render(
        <Input
          label="Disabled"
          disabled
          value="Cannot edit"
          id="test-input-5"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with value", () => {
      const { container } = render(
        <Input
          label="Name"
          value="John Doe"
          onChange={() => {}}
          id="test-input-6"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - required field", () => {
      const { container } = render(
        <Input label="Required Field" required id="test-input-7" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with custom className", () => {
      const { container } = render(
        <Input label="Custom" className="custom-class" id="test-input-8" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - email type", () => {
      const { container } = render(
        <Input
          label="Email"
          type="email"
          placeholder="you@example.com"
          id="test-input-9"
        />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - number type", () => {
      const { container } = render(
        <Input label="Age" type="number" min={0} max={120} id="test-input-10" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render with placeholder", () => {
      render(<Input placeholder="Test placeholder" />);
      expect(
        screen.getByPlaceholderText("Test placeholder")
      ).toBeInTheDocument();
    });

    it("should display label when provided", () => {
      render(<Input label="Test Label" />);
      expect(screen.getByText("Test Label")).toBeInTheDocument();
    });

    it("should display error message", () => {
      render(<Input error="This field is required" />);
      expect(screen.getByText("This field is required")).toBeInTheDocument();
    });

    it("should display helper text when no error", () => {
      render(<Input helperText="Enter your full name" />);
      expect(screen.getByText("Enter your full name")).toBeInTheDocument();
    });

    it("should not display helper text when error is present", () => {
      render(<Input helperText="Helper text" error="Error message" />);
      expect(screen.queryByText("Helper text")).not.toBeInTheDocument();
      expect(screen.getByText("Error message")).toBeInTheDocument();
    });

    it("should handle user input", async () => {
      const user = userEvent.setup();
      const handleChange = vi.fn();

      render(<Input onChange={handleChange} />);
      const input = screen.getByRole("textbox");

      await user.type(input, "test");
      expect(handleChange).toHaveBeenCalledTimes(4); // Once per character
    });

    it("should be disabled when disabled prop is true", () => {
      render(<Input disabled />);
      const input = screen.getByRole("textbox");
      expect(input).toBeDisabled();
    });

    it("should apply error styling when error prop is provided", () => {
      render(<Input error="Error" />);
      const input = screen.getByRole("textbox");
      expect(input).toHaveClass("border-red-500");
    });

    it("should associate label with input via htmlFor", () => {
      render(<Input label="Test Label" id="test-input" />);
      const label = screen.getByText("Test Label");
      const input = screen.getByRole("textbox");
      expect(label).toHaveAttribute("for", "test-input");
      expect(input).toHaveAttribute("id", "test-input");
    });

    it("should forward ref to input element", () => {
      const ref = { current: null as HTMLInputElement | null };
      render(<Input ref={ref} />);
      expect(ref.current).toBeInstanceOf(HTMLInputElement);
    });

    it("should handle different input types", () => {
      const { rerender, container } = render(<Input type="email" />);
      let input = container.querySelector("input");
      expect(input).toHaveAttribute("type", "email");

      rerender(<Input type="password" />);
      input = container.querySelector("input");
      expect(input).toHaveAttribute("type", "password");
    });

    it("should accept custom className", () => {
      render(<Input className="custom-class" />);
      const input = screen.getByRole("textbox");
      expect(input).toHaveClass("custom-class");
    });

    it("should handle maxLength attribute", () => {
      render(<Input maxLength={10} />);
      const input = screen.getByRole("textbox");
      expect(input).toHaveAttribute("maxLength", "10");
    });

    it("should handle required attribute", () => {
      render(<Input required />);
      const input = screen.getByRole("textbox");
      expect(input).toBeRequired();
    });
  });
});
