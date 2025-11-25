import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import React, { useState, useEffect } from "react";
import NoSSR from "@/components/ui/NoSSR";

describe("NoSSR Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - with simple children", () => {
      const { container } = render(
        <NoSSR>
          <div>Client-only content</div>
        </NoSSR>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with complex children", () => {
      const { container } = render(
        <NoSSR>
          <div className="complex-component">
            <h1>Dynamic Content</h1>
            <p>This content is not server-side rendered</p>
            <button>Interactive Element</button>
          </div>
        </NoSSR>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with multiple children", () => {
      const { container } = render(
        <NoSSR>
          <div>Child 1</div>
          <div>Child 2</div>
          <div>Child 3</div>
        </NoSSR>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with nested components", () => {
      const { container } = render(
        <NoSSR>
          <div>
            <header>Header</header>
            <main>
              <section>Section 1</section>
              <section>Section 2</section>
            </main>
            <footer>Footer</footer>
          </div>
        </NoSSR>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with styled components", () => {
      const { container } = render(
        <NoSSR>
          <div className="p-4 bg-blue-500 text-white rounded-lg shadow-md">
            Styled content
          </div>
        </NoSSR>
      );
      expect(container).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render children on client", () => {
      render(
        <NoSSR>
          <div data-testid="client-content">Client Content</div>
        </NoSSR>
      );
      
      expect(screen.getByTestId("client-content")).toBeInTheDocument();
    });

    it("should render text content", () => {
      render(<NoSSR>Simple text</NoSSR>);
      
      expect(screen.getByText("Simple text")).toBeInTheDocument();
    });

    it("should render multiple children elements", () => {
      render(
        <NoSSR>
          <div data-testid="child1">Child 1</div>
          <div data-testid="child2">Child 2</div>
          <div data-testid="child3">Child 3</div>
        </NoSSR>
      );
      
      expect(screen.getByTestId("child1")).toBeInTheDocument();
      expect(screen.getByTestId("child2")).toBeInTheDocument();
      expect(screen.getByTestId("child3")).toBeInTheDocument();
    });

    it("should render complex JSX structures", () => {
      render(
        <NoSSR>
          <div>
            <h1 data-testid="title">Title</h1>
            <p data-testid="description">Description</p>
            <button data-testid="action">Action</button>
          </div>
        </NoSSR>
      );
      
      expect(screen.getByTestId("title")).toBeInTheDocument();
      expect(screen.getByTestId("description")).toBeInTheDocument();
      expect(screen.getByTestId("action")).toBeInTheDocument();
    });

    it("should handle React components as children", () => {
      const CustomComponent = () => (
        <div data-testid="custom">Custom Component</div>
      );

      render(
        <NoSSR>
          <CustomComponent />
        </NoSSR>
      );
      
      expect(screen.getByTestId("custom")).toBeInTheDocument();
    });

    it("should handle conditional rendering", () => {
      const showContent = true;

      render(
        <NoSSR>
          {showContent && <div data-testid="conditional">Conditional</div>}
        </NoSSR>
      );
      
      expect(screen.getByTestId("conditional")).toBeInTheDocument();
    });

    it("should handle fragments", () => {
      render(
        <NoSSR>
          <>
            <div data-testid="fragment1">Fragment 1</div>
            <div data-testid="fragment2">Fragment 2</div>
          </>
        </NoSSR>
      );
      
      expect(screen.getByTestId("fragment1")).toBeInTheDocument();
      expect(screen.getByTestId("fragment2")).toBeInTheDocument();
    });
  });

  describe("Edge Cases", () => {
    it("should handle null children gracefully", () => {
      const { container } = render(<NoSSR>{null}</NoSSR>);
      
      expect(container).toBeInTheDocument();
    });

    it("should handle undefined children gracefully", () => {
      const { container } = render(<NoSSR>{undefined}</NoSSR>);
      
      expect(container).toBeInTheDocument();
    });

    it("should handle false as children", () => {
      const { container } = render(<NoSSR>{false}</NoSSR>);
      
      expect(container).toBeInTheDocument();
    });

    it("should handle empty string", () => {
      render(<NoSSR>{""}</NoSSR>);
      
      expect(document.body).toBeInTheDocument();
    });

    it("should handle number as children", () => {
      render(<NoSSR>{42}</NoSSR>);
      
      expect(screen.getByText("42")).toBeInTheDocument();
    });

    it("should handle zero as children", () => {
      render(<NoSSR>{0}</NoSSR>);
      
      expect(screen.getByText("0")).toBeInTheDocument();
    });

    it("should handle array of elements", () => {
      const items = ["Item 1", "Item 2", "Item 3"];

      render(
        <NoSSR>
          {items.map((item, index) => (
            <div key={index} data-testid={`item-${index}`}>
              {item}
            </div>
          ))}
        </NoSSR>
      );
      
      items.forEach((item, index) => {
        expect(screen.getByTestId(`item-${index}`)).toBeInTheDocument();
        expect(screen.getByText(item)).toBeInTheDocument();
      });
    });
  });

  describe("SSR Prevention", () => {
    it("should be wrapped with dynamic import to prevent SSR", () => {
      // The component is exported with dynamic() which disables SSR
      // This test verifies it renders correctly on client
      render(
        <NoSSR>
          <div data-testid="no-ssr-content">No SSR Content</div>
        </NoSSR>
      );
      
      expect(screen.getByTestId("no-ssr-content")).toBeInTheDocument();
    });

    it("should work with browser-only APIs in children", () => {
      const BrowserOnlyComponent = () => {
        // This would fail on server but should work with NoSSR
        const width = typeof window !== "undefined" ? window.innerWidth : 0;
        return <div data-testid="browser-api">Width: {width}</div>;
      };

      render(
        <NoSSR>
          <BrowserOnlyComponent />
        </NoSSR>
      );
      
      expect(screen.getByTestId("browser-api")).toBeInTheDocument();
    });

    it("should handle localStorage usage in children", () => {
      const LocalStorageComponent = () => {
        const hasStorage = typeof window !== "undefined" && window.localStorage;
        return <div data-testid="storage">{hasStorage ? "Has Storage" : "No Storage"}</div>;
      };

      render(
        <NoSSR>
          <LocalStorageComponent />
        </NoSSR>
      );
      
      expect(screen.getByTestId("storage")).toBeInTheDocument();
    });
  });

  describe("Integration", () => {
    it("should work with state management", () => {
      const StatefulComponent = () => {
        const [count] = useState(0);
        return <div data-testid="stateful">Count: {count}</div>;
      };

      render(
        <NoSSR>
          <StatefulComponent />
        </NoSSR>
      );
      
      expect(screen.getByTestId("stateful")).toBeInTheDocument();
      expect(screen.getByText("Count: 0")).toBeInTheDocument();
    });

    it("should work with effects", () => {
      const EffectComponent = () => {
        useEffect(() => {
          // Effect should run on client
        }, []);
        
        return <div data-testid="effect">Effect Component</div>;
      };

      render(
        <NoSSR>
          <EffectComponent />
        </NoSSR>
      );
      
      expect(screen.getByTestId("effect")).toBeInTheDocument();
    });
  });
});
