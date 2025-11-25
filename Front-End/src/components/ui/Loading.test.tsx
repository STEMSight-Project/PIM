import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { Loading } from "@/components/ui/Loading";

describe("Loading Component", () => {
  it("renders small loading spinner", () => {
    const { container } = render(<Loading size="sm" />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders medium loading spinner", () => {
    const { container } = render(<Loading size="md" />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders large loading spinner", () => {
    const { container } = render(<Loading size="lg" />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders with text", () => {
    const { container } = render(<Loading text="Loading data..." />);
    expect(screen.getByText("Loading data...")).toBeInTheDocument();
    expect(container.firstChild).toMatchSnapshot();
  });

  it("renders without text", () => {
    const { container } = render(<Loading />);
    expect(container.firstChild).toMatchSnapshot();
  });
});
