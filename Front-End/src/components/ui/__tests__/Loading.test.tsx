import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Loading, PageLoading, ButtonLoading } from "@/components/ui/Loading";

describe("Loading Component", () => {
  describe("Snapshots - Loading", () => {
    it("should match snapshot - default size", () => {
      const { container } = render(<Loading />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - small size", () => {
      const { container } = render(<Loading size="sm" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - medium size", () => {
      const { container } = render(<Loading size="md" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - large size", () => {
      const { container } = render(<Loading size="lg" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with text", () => {
      const { container } = render(<Loading text="Loading data..." />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - large with custom text", () => {
      const { container } = render(
        <Loading size="lg" text="Please wait while we fetch your data" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with custom className", () => {
      const { container } = render(
        <Loading className="my-custom-class" text="Loading..." />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - small with text", () => {
      const { container } = render(<Loading size="sm" text="Processing..." />);
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Snapshots - PageLoading", () => {
    it("should match snapshot - default PageLoading", () => {
      const { container } = render(<PageLoading />);
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Snapshots - ButtonLoading", () => {
    it("should match snapshot - default ButtonLoading", () => {
      const { container } = render(<ButtonLoading />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - ButtonLoading with custom className", () => {
      const { container } = render(<ButtonLoading className="text-white" />);
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality - Loading", () => {
    it("should render with default medium size", () => {
      const { container } = render(<Loading />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass("h-8", "w-8");
    });

    it("should render with small size", () => {
      const { container } = render(<Loading size="sm" />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass("h-4", "w-4");
    });

    it("should render with medium size", () => {
      const { container } = render(<Loading size="md" />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass("h-8", "w-8");
    });

    it("should render with large size", () => {
      const { container } = render(<Loading size="lg" />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass("h-12", "w-12");
    });

    it("should display text when provided", () => {
      render(<Loading text="Loading data..." />);
      expect(screen.getByText("Loading data...")).toBeInTheDocument();
    });

    it("should not display text when not provided", () => {
      const { container } = render(<Loading />);
      const text = container.querySelector("p");
      expect(text).not.toBeInTheDocument();
    });

    it("should apply custom className", () => {
      const { container } = render(<Loading className="custom-class" />);
      const wrapper = container.firstChild;
      expect(wrapper).toHaveClass("custom-class");
    });

    it("should have flex layout with proper alignment", () => {
      const { container } = render(<Loading />);
      const wrapper = container.firstChild;
      expect(wrapper).toHaveClass(
        "flex",
        "flex-col",
        "items-center",
        "justify-center",
        "space-y-2"
      );
    });

    it("should have spinning animation", () => {
      const { container } = render(<Loading />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toBeInTheDocument();
    });

    it("should have proper border styling", () => {
      const { container } = render(<Loading />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass(
        "rounded-full",
        "border-2",
        "border-gray-300",
        "border-t-blue-600"
      );
    });

    it("should render text with proper styling", () => {
      render(<Loading text="Loading..." />);
      const text = screen.getByText("Loading...");
      expect(text).toHaveClass("text-sm", "text-gray-600");
    });
  });

  describe("Functionality - PageLoading", () => {
    it("should render with min-h-screen", () => {
      const { container } = render(<PageLoading />);
      const wrapper = container.firstChild;
      expect(wrapper).toHaveClass(
        "min-h-screen",
        "flex",
        "items-center",
        "justify-center"
      );
    });

    it("should contain Loading component with large size", () => {
      const { container } = render(<PageLoading />);
      const spinner = container.querySelector(".animate-spin");
      expect(spinner).toHaveClass("h-12", "w-12");
    });

    it("should display default loading text", () => {
      render(<PageLoading />);
      expect(screen.getByText("Loading...")).toBeInTheDocument();
    });
  });

  describe("Functionality - ButtonLoading", () => {
    it("should render with small size for button", () => {
      const { container } = render(<ButtonLoading />);
      const spinner = container.firstChild;
      expect(spinner).toHaveClass("h-4", "w-4");
    });

    it("should have transparent border-t for button spinner", () => {
      const { container } = render(<ButtonLoading />);
      const spinner = container.firstChild;
      expect(spinner).toHaveClass("border-t-transparent");
    });

    it("should use border-current color", () => {
      const { container } = render(<ButtonLoading />);
      const spinner = container.firstChild;
      expect(spinner).toHaveClass("border-current");
    });

    it("should apply custom className to ButtonLoading", () => {
      const { container } = render(
        <ButtonLoading className="custom-btn-loading" />
      );
      const spinner = container.firstChild;
      expect(spinner).toHaveClass("custom-btn-loading");
    });

    it("should have spinning animation", () => {
      const { container } = render(<ButtonLoading />);
      const spinner = container.firstChild;
      expect(spinner).toHaveClass("animate-spin");
    });
  });

  describe("Edge Cases", () => {
    it("should handle empty text prop", () => {
      const { container } = render(<Loading text="" />);
      // Empty text renders a p element with empty string
      const paragraph = container.querySelector("p");
      if (paragraph) {
        expect(paragraph).toBeInTheDocument();
        expect(paragraph.textContent).toBe("");
      } else {
        // If component doesn't render p for empty string, that's also valid
        expect(container.querySelector(".animate-spin")).toBeInTheDocument();
      }
    });

    it("should handle long text gracefully", () => {
      const longText =
        "This is a very long loading message that might wrap to multiple lines";
      render(<Loading text={longText} />);
      expect(screen.getByText(longText)).toBeInTheDocument();
    });

    it("should render multiple Loading components independently", () => {
      const { container } = render(
        <div>
          <Loading size="sm" text="Small" />
          <Loading size="md" text="Medium" />
          <Loading size="lg" text="Large" />
        </div>
      );
      expect(screen.getByText("Small")).toBeInTheDocument();
      expect(screen.getByText("Medium")).toBeInTheDocument();
      expect(screen.getByText("Large")).toBeInTheDocument();

      const spinners = container.querySelectorAll(".animate-spin");
      expect(spinners).toHaveLength(3);
    });
  });
});
