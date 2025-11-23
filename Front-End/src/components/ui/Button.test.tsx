import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { Button } from "@/components/ui/Button";

describe("Button Component", () => {
  it("renders with default props", () => {
    const { container } = render(<Button>Click me</Button>);
    expect(screen.getByText("Click me")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders with primary variant", () => {
    const { container } = render(<Button variant="primary">Primary</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders with outline variant", () => {
    const { container } = render(<Button variant="outline">Outline</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders with different sizes", () => {
    const { container: small } = render(<Button size="sm">Small</Button>);
    expect(small.firstChild).toMatchSnapshot();

    const { container: medium } = render(<Button size="md">Medium</Button>);
    expect(medium.firstChild).toMatchSnapshot();

    const { container: large } = render(<Button size="lg">Large</Button>);
    expect(large.firstChild).toMatchSnapshot();
  });

  it("renders in disabled state", () => {
    const { container } = render(<Button disabled>Disabled</Button>);
    expect(screen.getByText("Disabled")).toBeDisabled();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders with loading state", () => {
    const { container } = render(<Button isLoading>Loading</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });
});
