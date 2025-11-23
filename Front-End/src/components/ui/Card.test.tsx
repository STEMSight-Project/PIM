import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { Card } from "@/components/ui/Card";

describe("Card Component", () => {
  it("renders basic card", () => {
    const { container } = render(
      <Card>
        <h2>Card Title</h2>
        <p>Card content goes here</p>
      </Card>
    );
    expect(screen.getByText("Card Title")).toBeInTheDocument();
    expect(screen.getByText("Card content goes here")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders card with custom className", () => {
    const { container } = render(
      <Card className="custom-class">Custom Card</Card>
    );
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders card with padding variants", () => {
    const { container } = render(
      <Card className="p-6">
        <p>Padded Card</p>
      </Card>
    );
    expect(container.firstChild).toMatchSnapshot();
  });
});
