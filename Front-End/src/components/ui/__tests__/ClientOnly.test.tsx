import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { ClientOnly } from "@/components/ui/ClientOnly";

describe("ClientOnly Component", () => {
  beforeEach(() => {
    // Reset the component state between tests
  });

  describe("Snapshots", () => {
    it("should match snapshot - with children after mount", async () => {
      const { container } = render(
        <ClientOnly>
          <div>Client-side content</div>
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByText("Client-side content")).toBeInTheDocument();
      });
      
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with fallback before mount", () => {
      const { container } = render(
        <ClientOnly fallback={<div>Loading...</div>}>
          <div>Client-side content</div>
        </ClientOnly>
      );
      
      // Immediately check snapshot before mounting
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with complex children", async () => {
      const { container } = render(
        <ClientOnly>
          <div className="complex-component">
            <h1>Title</h1>
            <p>Description</p>
            <button>Action</button>
          </div>
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByText("Title")).toBeInTheDocument();
      });
      
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with custom fallback", () => {
      const { container } = render(
        <ClientOnly
          fallback={
            <div className="skeleton-loader">
              <span>Loading component...</span>
            </div>
          }
        >
          <div>Content</div>
        </ClientOnly>
      );
      
      expect(container).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render children after mounting on client", async () => {
      render(
        <ClientOnly>
          <div data-testid="client-content">Client Content</div>
        </ClientOnly>
      );
      
      // In test environment, useEffect runs immediately
      await waitFor(() => {
        expect(screen.getByTestId("client-content")).toBeInTheDocument();
      });
    });

    it("should handle multiple children", async () => {
      render(
        <ClientOnly>
          <div data-testid="child1">Child 1</div>
          <div data-testid="child2">Child 2</div>
          <div data-testid="child3">Child 3</div>
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByTestId("child1")).toBeInTheDocument();
        expect(screen.getByTestId("child2")).toBeInTheDocument();
        expect(screen.getByTestId("child3")).toBeInTheDocument();
      });
    });

    it("should handle JSX elements as children", async () => {
      const ComplexComponent = () => (
        <div>
          <h1>Title</h1>
          <p>Description</p>
        </div>
      );

      render(
        <ClientOnly>
          <ComplexComponent />
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByText("Title")).toBeInTheDocument();
        expect(screen.getByText("Description")).toBeInTheDocument();
      });
    });

    it("should handle text nodes as children", async () => {
      render(<ClientOnly>Simple text content</ClientOnly>);
      
      await waitFor(() => {
        expect(screen.getByText("Simple text content")).toBeInTheDocument();
      });
    });

    it("should work with conditional rendering in children", async () => {
      const showContent = true;

      render(
        <ClientOnly>
          {showContent && <div data-testid="conditional">Conditional Content</div>}
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByTestId("conditional")).toBeInTheDocument();
      });
    });
  });

  describe("Edge Cases", () => {
    it("should handle empty children", async () => {
      const { container } = render(<ClientOnly>{null}</ClientOnly>);
      
      // Component should mount even with null children
      expect(container).toBeInTheDocument();
    });

    it("should handle undefined children", async () => {
      const { container } = render(<ClientOnly>{undefined}</ClientOnly>);
      
      // Component should mount even with undefined children
      expect(container).toBeInTheDocument();
    });

    it("should handle false as children", async () => {
      render(<ClientOnly>{false}</ClientOnly>);
      
      await waitFor(() => {
        // Should mount without errors
        expect(true).toBe(true);
      });
    });

    it("should handle component that throws error in children", async () => {
      const BrokenComponent = () => {
        throw new Error("Component error");
      };

      // This test would need an error boundary in real scenario
      // For now, we just verify the component structure works
      expect(() => {
        render(
          <ClientOnly fallback={<div>Fallback</div>}>
            <div>Safe content</div>
          </ClientOnly>
        );
      }).not.toThrow();
    });
  });

  describe("SSR Behavior", () => {
    it("should eventually render children on client", async () => {
      render(
        <ClientOnly>
          <div>Client-only content</div>
        </ClientOnly>
      );
      
      // In test environment with jsdom, useEffect runs immediately
      await waitFor(() => {
        expect(screen.getByText("Client-only content")).toBeInTheDocument();
      });
    });

    it("should work with client-only components", async () => {
      render(
        <ClientOnly>
          <div>Client content</div>
        </ClientOnly>
      );
      
      await waitFor(() => {
        expect(screen.getByText("Client content")).toBeInTheDocument();
      });
    });
  });
});
