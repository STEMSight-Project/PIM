import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Modal } from "@/components/ui/Modal";

describe("Modal Component", () => {
  beforeEach(() => {
    // Reset document.body overflow style
    document.body.style.overflow = "unset";
  });

  describe("Snapshots", () => {
    it("should match snapshot - closed state", () => {
      const { container } = render(
        <Modal isOpen={false} onClose={() => {}}>
          <div>Modal content</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - open state", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}}>
          <div>Modal content</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with title", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} title="Modal Title">
          <div>Modal content</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - small size", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} size="sm">
          <div>Small modal</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - large size", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} size="lg">
          <div>Large modal</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - extra large size", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} size="xl">
          <div>Extra large modal</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - without close button", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} showCloseButton={false}>
          <div>No close button</div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });

    it("should match snapshot - with complex content", () => {
      const { container } = render(
        <Modal isOpen={true} onClose={() => {}} title="Complex Modal">
          <div>
            <p>Paragraph 1</p>
            <button>Action Button</button>
            <p>Paragraph 2</p>
          </div>
        </Modal>
      );
      expect(container).toMatchSnapshot();
    });
  });

  describe("Functionality", () => {
    it("should not render when isOpen is false", () => {
      render(
        <Modal isOpen={false} onClose={() => {}}>
          <div data-testid="modal-content">Content</div>
        </Modal>
      );
      expect(screen.queryByTestId("modal-content")).not.toBeInTheDocument();
    });

    it("should render when isOpen is true", () => {
      render(
        <Modal isOpen={true} onClose={() => {}}>
          <div data-testid="modal-content">Content</div>
        </Modal>
      );
      expect(screen.getByTestId("modal-content")).toBeInTheDocument();
    });

    it("should display title when provided", () => {
      render(
        <Modal isOpen={true} onClose={() => {}} title="Test Title">
          <div>Content</div>
        </Modal>
      );
      expect(screen.getByText("Test Title")).toBeInTheDocument();
    });

    it("should call onClose when close button is clicked", async () => {
      const user = userEvent.setup();
      const handleClose = vi.fn();

      render(
        <Modal isOpen={true} onClose={handleClose}>
          <div>Content</div>
        </Modal>
      );

      const closeButton = screen.getByRole("button");
      await user.click(closeButton);
      expect(handleClose).toHaveBeenCalledTimes(1);
    });

    it("should call onClose when overlay is clicked and closeOnOverlayClick is true", async () => {
      const user = userEvent.setup();
      const handleClose = vi.fn();

      const { container } = render(
        <Modal isOpen={true} onClose={handleClose} closeOnOverlayClick={true}>
          <div>Content</div>
        </Modal>
      );

      // Click on overlay (the backdrop div with bg-black/50)
      const overlay = container.querySelector(".fixed.inset-0.bg-black\\/50");
      if (overlay) {
        await user.click(overlay);
        expect(handleClose).toHaveBeenCalledTimes(1);
      }
    });

    it("should not call onClose when overlay is clicked and closeOnOverlayClick is false", async () => {
      const user = userEvent.setup();
      const handleClose = vi.fn();

      const { container } = render(
        <Modal isOpen={true} onClose={handleClose} closeOnOverlayClick={false}>
          <div>Content</div>
        </Modal>
      );

      // Try clicking overlay
      const overlay = container.querySelector(".fixed.inset-0.bg-black\\/50");
      if (overlay) {
        await user.click(overlay);
        expect(handleClose).not.toHaveBeenCalled();
      }
    });

    it("should call onClose when Escape key is pressed", async () => {
      const user = userEvent.setup();
      const handleClose = vi.fn();

      render(
        <Modal isOpen={true} onClose={handleClose}>
          <div>Content</div>
        </Modal>
      );

      await user.keyboard("{Escape}");
      expect(handleClose).toHaveBeenCalledTimes(1);
    });

    it("should set body overflow to hidden when open", () => {
      render(
        <Modal isOpen={true} onClose={() => {}}>
          <div>Content</div>
        </Modal>
      );
      expect(document.body.style.overflow).toBe("hidden");
    });

    it("should restore body overflow when closed", async () => {
      const { rerender } = render(
        <Modal isOpen={true} onClose={() => {}}>
          <div>Content</div>
        </Modal>
      );

      expect(document.body.style.overflow).toBe("hidden");

      rerender(
        <Modal isOpen={false} onClose={() => {}}>
          <div>Content</div>
        </Modal>
      );

      await waitFor(() => {
        expect(document.body.style.overflow).toBe("unset");
      });
    });

    it("should not render close button when showCloseButton is false", () => {
      render(
        <Modal isOpen={true} onClose={() => {}} showCloseButton={false}>
          <div>Content</div>
        </Modal>
      );
      expect(screen.queryByRole("button")).not.toBeInTheDocument();
    });

    it("should render children content", () => {
      render(
        <Modal isOpen={true} onClose={() => {}}>
          <div data-testid="child-content">
            <h2>Title</h2>
            <p>Description</p>
          </div>
        </Modal>
      );

      expect(screen.getByTestId("child-content")).toBeInTheDocument();
      expect(screen.getByText("Title")).toBeInTheDocument();
      expect(screen.getByText("Description")).toBeInTheDocument();
    });

    it("should apply correct size classes", () => {
      const { rerender, container } = render(
        <Modal isOpen={true} onClose={() => {}} size="sm">
          <div>Content</div>
        </Modal>
      );

      // The modal content div has the size class
      let modalContent = container.querySelector(".relative.w-full");
      expect(modalContent).toHaveClass("max-w-md");

      rerender(
        <Modal isOpen={true} onClose={() => {}} size="md">
          <div>Content</div>
        </Modal>
      );
      modalContent = container.querySelector(".relative.w-full");
      expect(modalContent).toHaveClass("max-w-lg");

      rerender(
        <Modal isOpen={true} onClose={() => {}} size="lg">
          <div>Content</div>
        </Modal>
      );
      modalContent = container.querySelector(".relative.w-full");
      expect(modalContent).toHaveClass("max-w-2xl");

      rerender(
        <Modal isOpen={true} onClose={() => {}} size="xl">
          <div>Content</div>
        </Modal>
      );
      modalContent = container.querySelector(".relative.w-full");
      expect(modalContent).toHaveClass("max-w-4xl");
    });
  });
});
