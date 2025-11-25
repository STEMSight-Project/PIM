import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableCell,
} from "@/components/ui/Table";

describe("Table Component", () => {
  describe("Snapshots", () => {
    it("should match snapshot - simple table", () => {
      const { container } = render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header>Name</TableCell>
              <TableCell header>Age</TableCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell>John Doe</TableCell>
              <TableCell>30</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with alignment", () => {
      const { container } = render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header align="left">
                Name
              </TableCell>
              <TableCell header align="center">
                Age
              </TableCell>
              <TableCell header align="right">
                Score
              </TableCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell align="left">John</TableCell>
              <TableCell align="center">30</TableCell>
              <TableCell align="right">95</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with hover effect", () => {
      const { container } = render(
        <Table>
          <TableBody>
            <TableRow hover>
              <TableCell>Hoverable Row</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - clickable rows", () => {
      const { container } = render(
        <Table>
          <TableBody>
            <TableRow onClick={() => {}} hover>
              <TableCell>Clickable Row</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - complex table", () => {
      const { container } = render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header>ID</TableCell>
              <TableCell header>Patient</TableCell>
              <TableCell header align="center">
                Status
              </TableCell>
              <TableCell header align="right">
                Date
              </TableCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow hover>
              <TableCell>001</TableCell>
              <TableCell>John Doe</TableCell>
              <TableCell align="center">Active</TableCell>
              <TableCell align="right">2024-01-15</TableCell>
            </TableRow>
            <TableRow hover>
              <TableCell>002</TableCell>
              <TableCell>Jane Smith</TableCell>
              <TableCell align="center">Pending</TableCell>
              <TableCell align="right">2024-01-16</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - with custom className", () => {
      const { container } = render(
        <Table className="custom-table-class">
          <TableHeader className="custom-header-class">
            <TableRow className="custom-row-class">
              <TableCell className="custom-cell-class">Header</TableCell>
            </TableRow>
          </TableHeader>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });

    it("should match snapshot - empty table", () => {
      const { container } = render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header>Column 1</TableCell>
              <TableCell header>Column 2</TableCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell colSpan={2} align="center">
                No data available
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );
      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should render table with header and body", () => {
      render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header>Header Cell</TableCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell>Body Cell</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      expect(screen.getByText("Header Cell")).toBeInTheDocument();
      expect(screen.getByText("Body Cell")).toBeInTheDocument();
    });

    it("should handle row click events", async () => {
      const user = userEvent.setup();
      const handleClick = vi.fn();

      render(
        <Table>
          <TableBody>
            <TableRow onClick={handleClick}>
              <TableCell>Clickable</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      const row = screen.getByText("Clickable").closest("tr");
      if (row) {
        await user.click(row);
        expect(handleClick).toHaveBeenCalledTimes(1);
      }
    });

    it("should apply hover styles when hover prop is true", () => {
      render(
        <Table>
          <TableBody>
            <TableRow hover>
              <TableCell>Hover me</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      const row = screen.getByText("Hover me").closest("tr");
      expect(row).toHaveClass("hover:bg-gray-50");
    });

    it("should apply cursor-pointer when onClick is provided", () => {
      render(
        <Table>
          <TableBody>
            <TableRow onClick={() => {}}>
              <TableCell>Clickable</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      const row = screen.getByText("Clickable").closest("tr");
      expect(row).toHaveClass("cursor-pointer");
    });

    it("should apply different alignment classes", () => {
      render(
        <Table>
          <TableBody>
            <TableRow>
              <TableCell align="left">Left</TableCell>
              <TableCell align="center">Center</TableCell>
              <TableCell align="right">Right</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      const leftCell = screen.getByText("Left");
      const centerCell = screen.getByText("Center");
      const rightCell = screen.getByText("Right");

      expect(leftCell).toHaveClass("text-left");
      expect(centerCell).toHaveClass("text-center");
      expect(rightCell).toHaveClass("text-right");
    });

    it("should render header cells with th element", () => {
      render(
        <Table>
          <TableHeader>
            <TableRow>
              <TableCell header>Header</TableCell>
            </TableRow>
          </TableHeader>
        </Table>
      );

      const headerCell = screen.getByText("Header");
      expect(headerCell.tagName).toBe("TH");
    });

    it("should render body cells with td element", () => {
      render(
        <Table>
          <TableBody>
            <TableRow>
              <TableCell>Body</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      const bodyCell = screen.getByText("Body");
      expect(bodyCell.tagName).toBe("TD");
    });

    it("should accept custom className for all components", () => {
      render(
        <Table className="custom-table">
          <TableHeader className="custom-header">
            <TableRow className="custom-row">
              <TableCell className="custom-cell">Content</TableCell>
            </TableRow>
          </TableHeader>
        </Table>
      );

      const table = screen.getByText("Content").closest("table");
      const thead = screen.getByText("Content").closest("thead");
      const row = screen.getByText("Content").closest("tr");
      const cell = screen.getByText("Content");

      expect(table).toHaveClass("custom-table");
      expect(thead).toHaveClass("custom-header");
      expect(row).toHaveClass("custom-row");
      expect(cell).toHaveClass("custom-cell");
    });

    it("should render multiple rows", () => {
      render(
        <Table>
          <TableBody>
            <TableRow>
              <TableCell>Row 1</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>Row 2</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>Row 3</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      expect(screen.getByText("Row 1")).toBeInTheDocument();
      expect(screen.getByText("Row 2")).toBeInTheDocument();
      expect(screen.getByText("Row 3")).toBeInTheDocument();
    });

    it("should render multiple columns", () => {
      render(
        <Table>
          <TableBody>
            <TableRow>
              <TableCell>Col 1</TableCell>
              <TableCell>Col 2</TableCell>
              <TableCell>Col 3</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      );

      expect(screen.getByText("Col 1")).toBeInTheDocument();
      expect(screen.getByText("Col 2")).toBeInTheDocument();
      expect(screen.getByText("Col 3")).toBeInTheDocument();
    });
  });
});
