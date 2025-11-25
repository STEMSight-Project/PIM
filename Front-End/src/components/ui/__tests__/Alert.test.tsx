import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Alert } from "@/components/ui/Alert";

describe("Alert Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - info variant", () => {
      const { container } = render(
        <Alert variant="info">This is an informational message</Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - success variant", () => {
      const { container } = render(
        <Alert variant="success">Operation completed successfully!</Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - warning variant", () => {
      const { container } = render(
        <Alert variant="warning">Please review before proceeding</Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - error variant", () => {
      const { container } = render(
        <Alert variant="error">An error occurred. Please try again.</Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - alert with custom className", () => {
      const { container } = render(
        <Alert variant="info" className="mt-4 mb-4">
          Custom styled alert
        </Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - alert with complex content", () => {
      const { container } = render(
        <Alert variant="error">
          <div>
            <strong>Error:</strong> Unable to connect to server
            <ul className="mt-2 ml-4 list-disc">
              <li>Check your internet connection</li>
              <li>Verify server status</li>
              <li>Contact support if problem persists</li>
            </ul>
          </div>
        </Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - alert with onClose handler", () => {
      const { container } = render(
        <Alert variant="warning" onClose={() => {}}>
          Dismissible warning
        </Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - success with onClose", () => {
      const { container } = render(
        <Alert variant="success" onClose={() => {}}>
          Success! You can dismiss this message.
        </Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - info with long text", () => {
      const { container } = render(
        <Alert variant="info">
          This is a very long informational message that contains multiple
          sentences. It provides detailed information about a particular
          situation or condition that the user should be aware of. The message
          continues to provide context and helpful details.
        </Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - error without close button", () => {
      const { container } = render(
        <Alert variant="error">Critical error that cannot be dismissed</Alert>
      );
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render with correct variant styling - info", () => {
      const { container } = render(<Alert variant="info">Info message</Alert>);
      const alert = container.firstChild;
      expect(alert).toHaveClass(
        "bg-blue-50",
        "border-blue-200",
        "text-blue-800"
      );
    });

    it("should render with correct variant styling - success", () => {
      const { container } = render(
        <Alert variant="success">Success message</Alert>
      );
      const alert = container.firstChild;
      expect(alert).toHaveClass(
        "bg-green-50",
        "border-green-200",
        "text-green-800"
      );
    });

    it("should render with correct variant styling - warning", () => {
      const { container } = render(
        <Alert variant="warning">Warning message</Alert>
      );
      const alert = container.firstChild;
      expect(alert).toHaveClass(
        "bg-yellow-50",
        "border-yellow-200",
        "text-yellow-800"
      );
    });

    it("should render with correct variant styling - error", () => {
      const { container } = render(
        <Alert variant="error">Error message</Alert>
      );
      const alert = container.firstChild;
      expect(alert).toHaveClass("bg-red-50", "border-red-200", "text-red-800");
    });

    it("should display alert content", () => {
      render(<Alert variant="info">Test Alert Message</Alert>);
      expect(screen.getByText("Test Alert Message")).toBeInTheDocument();
    });

    it("should render close button when onClose is provided", () => {
      render(
        <Alert variant="info" onClose={() => {}}>
          Closable Alert
        </Alert>
      );
      const closeButton = screen.getByRole("button");
      expect(closeButton).toBeInTheDocument();
    });

    it("should not render close button when onClose is not provided", () => {
      render(<Alert variant="info">Non-closable Alert</Alert>);
      expect(screen.queryByRole("button")).not.toBeInTheDocument();
    });

    it("should call onClose when close button is clicked", async () => {
      const user = userEvent.setup();
      const handleClose = vi.fn();

      render(
        <Alert variant="info" onClose={handleClose}>
          Closable Alert
        </Alert>
      );

      const closeButton = screen.getByRole("button");
      await user.click(closeButton);
      expect(handleClose).toHaveBeenCalledTimes(1);
    });

    it("should apply custom className", () => {
      const { container } = render(
        <Alert variant="info" className="custom-class">
          Alert
        </Alert>
      );
      const alert = container.firstChild;
      expect(alert).toHaveClass("custom-class");
    });

    it("should render icon for each variant", () => {
      const { container: infoContainer } = render(
        <Alert variant="info">Info</Alert>
      );
      expect(infoContainer.querySelector("svg")).toBeInTheDocument();

      const { container: successContainer } = render(
        <Alert variant="success">Success</Alert>
      );
      expect(successContainer.querySelector("svg")).toBeInTheDocument();

      const { container: warningContainer } = render(
        <Alert variant="warning">Warning</Alert>
      );
      expect(warningContainer.querySelector("svg")).toBeInTheDocument();

      const { container: errorContainer } = render(
        <Alert variant="error">Error</Alert>
      );
      expect(errorContainer.querySelector("svg")).toBeInTheDocument();
    });

    it("should have flex layout with proper spacing", () => {
      const { container } = render(<Alert variant="info">Alert Content</Alert>);
      const alert = container.firstChild;
      expect(alert).toHaveClass("flex", "items-start", "space-x-3");
    });

    it("should render complex JSX children", () => {
      render(
        <Alert variant="error">
          <div data-testid="complex-content">
            <h4>Error Title</h4>
            <p>Error description</p>
          </div>
        </Alert>
      );
      expect(screen.getByTestId("complex-content")).toBeInTheDocument();
      expect(screen.getByText("Error Title")).toBeInTheDocument();
      expect(screen.getByText("Error description")).toBeInTheDocument();
    });

    it("should maintain structure with icon, content, and close button", () => {
      const { container } = render(
        <Alert variant="warning" onClose={() => {}}>
          Warning message
        </Alert>
      );

      // Icon
      const icon = container.querySelector("svg");
      expect(icon).toBeInTheDocument();
      expect(icon).toHaveClass("h-5", "w-5", "flex-shrink-0");

      // Content
      const content = container.querySelector(".flex-1");
      expect(content).toBeInTheDocument();

      // Close button
      const closeButton = screen.getByRole("button");
      expect(closeButton).toBeInTheDocument();
    });
  });
});
