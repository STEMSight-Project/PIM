import { describe, it, expect } from "vitest";
import { render } from "@testing-library/react";
import { Button } from "@/components/ui/Button";

describe("Button Component", () => {
  it("should match snapshot - primary variant", () => {
    const { container } = render(<Button variant="primary">Click me</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - secondary variant", () => {
    const { container } = render(<Button variant="secondary">Click me</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - outline variant", () => {
    const { container } = render(<Button variant="outline">Click me</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - ghost variant", () => {
    const { container } = render(<Button variant="ghost">Click me</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - destructive variant", () => {
    const { container } = render(<Button variant="destructive">Delete</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - disabled state", () => {
    const { container } = render(<Button disabled>Disabled</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - loading state", () => {
    const { container } = render(<Button isLoading>Loading</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - small size", () => {
    const { container } = render(<Button size="sm">Small</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - large size", () => {
    const { container } = render(<Button size="lg">Large</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("should match snapshot - full width", () => {
    const { container } = render(<Button fullWidth>Full Width</Button>);
    expect(container.firstChild).toMatchSnapshot();
  });
});
