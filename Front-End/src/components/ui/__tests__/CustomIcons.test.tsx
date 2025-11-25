import { describe, it, expect } from "vitest";
import { render } from "@testing-library/react";
import {
  CustomDash,
  CustomPatient,
  CustomRecent,
  CustomReplay,
  CustomCamera,
} from "@/components/ui/CustomIcons";

describe("CustomIcons Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - CustomDash", () => {
      const { container } = render(<CustomDash />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomDash with custom className", () => {
      const { container } = render(<CustomDash className="h-8 w-8" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomPatient", () => {
      const { container } = render(<CustomPatient />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomPatient with custom className", () => {
      const { container } = render(<CustomPatient className="h-10 w-10" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomRecent", () => {
      const { container } = render(<CustomRecent />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomRecent with custom className", () => {
      const { container } = render(
        <CustomRecent className="h-6 w-6 text-blue-500" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomReplay", () => {
      const { container } = render(<CustomReplay />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomReplay with custom className", () => {
      const { container } = render(<CustomReplay className="h-12 w-12" />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomCamera", () => {
      const { container } = render(<CustomCamera />);
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - CustomCamera with custom className", () => {
      const { container } = render(
        <CustomCamera className="h-7 w-7 opacity-80" />
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - all icons together", () => {
      const { container } = render(
        <div className="flex gap-4">
          <CustomDash />
          <CustomPatient />
          <CustomRecent />
          <CustomReplay />
          <CustomCamera />
        </div>
      );
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render CustomDash with correct alt text", () => {
      const { getByAltText } = render(<CustomDash />);
      expect(getByAltText("Dashboard Icon")).toBeInTheDocument();
    });

    it("should render CustomPatient with correct alt text", () => {
      const { getByAltText } = render(<CustomPatient />);
      expect(getByAltText("Patient Icon")).toBeInTheDocument();
    });

    it("should render CustomRecent with correct alt text", () => {
      const { getByAltText } = render(<CustomRecent />);
      expect(getByAltText("Recent Icon")).toBeInTheDocument();
    });

    it("should render CustomReplay with correct alt text", () => {
      const { getByAltText } = render(<CustomReplay />);
      expect(getByAltText("Replay Icon")).toBeInTheDocument();
    });

    it("should render CustomCamera with correct alt text", () => {
      const { getByAltText } = render(<CustomCamera />);
      expect(getByAltText("Camera Icon")).toBeInTheDocument();
    });

    it("should apply custom className to CustomDash", () => {
      const { container } = render(<CustomDash className="custom-class" />);
      const img = container.querySelector("img");
      expect(img).toHaveClass("custom-class");
    });

    it("should use default className when none provided", () => {
      const { container } = render(<CustomDash />);
      const img = container.querySelector("img");
      expect(img).toHaveClass("h-5", "w-5");
    });

    it("should have correct image source paths", () => {
      const { getByAltText: getDash } = render(<CustomDash />);
      const { getByAltText: getPatient } = render(<CustomPatient />);
      const { getByAltText: getRecent } = render(<CustomRecent />);
      const { getByAltText: getReplay } = render(<CustomReplay />);
      const { getByAltText: getCamera } = render(<CustomCamera />);

      expect(getDash("Dashboard Icon")).toHaveAttribute(
        "src",
        expect.stringContaining("dashboard-icon.svg")
      );
      expect(getPatient("Patient Icon")).toHaveAttribute(
        "src",
        expect.stringContaining("patients-icon.svg")
      );
      expect(getRecent("Recent Icon")).toHaveAttribute(
        "src",
        expect.stringContaining("recent-icon.svg")
      );
      expect(getReplay("Replay Icon")).toHaveAttribute(
        "src",
        expect.stringContaining("playback-icon.svg")
      );
      expect(getCamera("Camera Icon")).toHaveAttribute(
        "src",
        expect.stringContaining("camera-icon.svg")
      );
    });

    it("should have correct width and height attributes", () => {
      const { container } = render(<CustomDash />);
      const img = container.querySelector("img");
      expect(img).toHaveAttribute("width", "30");
      expect(img).toHaveAttribute("height", "30");
    });
  });
});
