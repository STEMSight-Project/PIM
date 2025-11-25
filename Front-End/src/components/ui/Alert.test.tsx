import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { Alert } from "@/components/ui/Alert";

describe("Alert Component", () => {
  it("renders success alert", () => {
    const { container } = render(
      <Alert variant="success">Operation successful!</Alert>
    );
    expect(screen.getByText("Operation successful!")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders error alert", () => {
    const { container } = render(
      <Alert variant="error">An error occurred!</Alert>
    );
    expect(screen.getByText("An error occurred!")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders warning alert", () => {
    const { container } = render(
      <Alert variant="warning">Warning message</Alert>
    );
    expect(screen.getByText("Warning message")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders info alert", () => {
    const { container } = render(
      <Alert variant="info">Information message</Alert>
    );
    expect(screen.getByText("Information message")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });
});
