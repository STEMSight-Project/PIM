import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  Card,
  CardHeader,
  CardContent,
  CardFooter,
} from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";

describe("Card Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - basic card", () => {
      const { container } = render(
        <Card>
          <h2>Card Title</h2>
          <p>Card content goes here</p>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with custom className", () => {
      const { container } = render(
        <Card className="custom-class bg-blue-100">
          <h2>Custom Card</h2>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with hover effect", () => {
      const { container } = render(
        <Card className="hover:shadow-lg transition-shadow">
          <div className="p-4">
            <h3 className="font-bold">Hoverable Card</h3>
            <p className="text-gray-600">Hover over me</p>
          </div>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with complex content", () => {
      const { container } = render(
        <Card>
          <div className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold">Session Details</h2>
              <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm">
                Active
              </span>
            </div>
            <div className="space-y-2">
              <p className="text-gray-600">Duration: 45 minutes</p>
              <p className="text-gray-600">Status: In Progress</p>
            </div>
          </div>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with header", () => {
      const { container } = render(
        <Card>
          <CardHeader>
            <h3 className="text-lg font-semibold">Card Header</h3>
          </CardHeader>
          <CardContent>
            <p>Card content section</p>
          </CardContent>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with footer", () => {
      const { container } = render(
        <Card>
          <CardContent>
            <p>Card content</p>
          </CardContent>
          <CardFooter>
            <Button variant="primary">Action</Button>
          </CardFooter>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - full card with all sections", () => {
      const { container } = render(
        <Card>
          <CardHeader>
            <h3 className="text-lg font-semibold">Patient Information</h3>
            <p className="text-sm text-gray-500">Patient ID: P12345</p>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <p>Name: John Doe</p>
              <p>Age: 65</p>
              <p>Diagnosis: Parkinson&apos;s Disease</p>
            </div>
          </CardContent>
          <CardFooter>
            <Button variant="outline" size="sm">
              View Details
            </Button>
            <Button variant="primary" size="sm">
              Start Session
            </Button>
          </CardFooter>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with custom styled sections", () => {
      const { container } = render(
        <Card className="border-blue-500">
          <CardHeader className="bg-blue-50">
            <h3>Custom Header</h3>
          </CardHeader>
          <CardContent className="bg-gray-50">
            <p>Custom Content</p>
          </CardContent>
          <CardFooter className="bg-blue-50 justify-end">
            <Button>Close</Button>
          </CardFooter>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - nested cards", () => {
      const { container } = render(
        <Card>
          <CardHeader>
            <h3>Parent Card</h3>
          </CardHeader>
          <CardContent>
            <Card className="mb-2">
              <CardContent>
                <p>Nested Card 1</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent>
                <p>Nested Card 2</p>
              </CardContent>
            </Card>
          </CardContent>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - card with onClick handler", () => {
      const { container } = render(
        <Card onClick={() => {}} className="cursor-pointer hover:shadow-md">
          <CardContent>
            <p>Clickable Card</p>
          </CardContent>
        </Card>
      );
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render children content", () => {
      render(
        <Card>
          <p data-testid="card-content">Test Content</p>
        </Card>
      );
      expect(screen.getByTestId("card-content")).toBeInTheDocument();
    });

    it("should apply custom className", () => {
      const { container } = render(
        <Card className="custom-class">Content</Card>
      );
      const card = container.firstChild;
      expect(card).toHaveClass("custom-class");
    });

    it("should have default styling classes", () => {
      const { container } = render(<Card>Content</Card>);
      const card = container.firstChild;
      expect(card).toHaveClass(
        "rounded-lg",
        "border",
        "border-gray-200",
        "bg-white",
        "shadow-sm"
      );
    });

    it("should render CardHeader with proper structure", () => {
      render(
        <Card>
          <CardHeader>
            <h3 data-testid="header-content">Header</h3>
          </CardHeader>
        </Card>
      );
      const header = screen.getByTestId("header-content").parentElement;
      expect(header).toHaveClass("flex", "flex-col", "space-y-1.5", "p-6");
    });

    it("should render CardContent with proper structure", () => {
      render(
        <Card>
          <CardContent>
            <p data-testid="content">Content</p>
          </CardContent>
        </Card>
      );
      const content = screen.getByTestId("content").parentElement;
      expect(content).toHaveClass("p-6", "pt-0");
    });

    it("should render CardFooter with proper structure", () => {
      render(
        <Card>
          <CardFooter>
            <button data-testid="footer-button">Action</button>
          </CardFooter>
        </Card>
      );
      const footer = screen.getByTestId("footer-button").parentElement;
      expect(footer).toHaveClass("flex", "items-center", "p-6", "pt-0");
    });

    it("should pass through HTML attributes", () => {
      render(
        <Card data-testid="test-card" id="card-1">
          Content
        </Card>
      );
      const card = screen.getByTestId("test-card");
      expect(card).toHaveAttribute("id", "card-1");
    });

    it("should render multiple CardHeader sections", () => {
      render(
        <Card>
          <CardHeader>
            <h3>Title</h3>
            <p>Subtitle</p>
          </CardHeader>
        </Card>
      );
      expect(screen.getByText("Title")).toBeInTheDocument();
      expect(screen.getByText("Subtitle")).toBeInTheDocument();
    });

    it("should handle empty card", () => {
      const { container } = render(<Card>{null}</Card>);
      expect(container.firstChild).toBeInTheDocument();
    });
  });
});
