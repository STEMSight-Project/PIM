import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, act } from "@testing-library/react";
import { ApiErrorProvider, useApiErrors } from "@/contexts/ApiErrorContext";

// Test component to access context
function TestComponent() {
  const { errors, addError, clearErrors, hasTimeoutError, hasNetworkError } =
    useApiErrors();

  return (
    <div>
      <div data-testid="error-count">{errors.length}</div>
      <div data-testid="has-timeout">{hasTimeoutError ? "yes" : "no"}</div>
      <div data-testid="has-network">{hasNetworkError ? "yes" : "no"}</div>
      <button
        onClick={() =>
          addError({
            message: "Test error",
            endpoint: "/test",
            timestamp: Date.now(),
            status: 500,
          })
        }
      >
        Add Error
      </button>
      <button onClick={clearErrors}>Clear Errors</button>
    </div>
  );
}

describe("ApiErrorContext", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should match snapshot - initial state", () => {
    const { container } = render(
      <ApiErrorProvider>
        <TestComponent />
      </ApiErrorProvider>
    );
    expect(container).toMatchSnapshot();
  });

  it("should match snapshot - with timeout errors", () => {
    const { container } = render(
      <ApiErrorProvider>
        <TestComponent />
      </ApiErrorProvider>
    );

    // Add multiple timeout errors
    act(() => {
      const button = screen.getByText("Add Error");
      button.click();
      button.click();
      button.click();
    });

    expect(container).toMatchSnapshot();
  });

  it("should match snapshot - after clearing errors", () => {
    const { container } = render(
      <ApiErrorProvider>
        <TestComponent />
      </ApiErrorProvider>
    );

    // Add errors then clear
    act(() => {
      screen.getByText("Add Error").click();
      screen.getByText("Add Error").click();
    });

    act(() => {
      screen.getByText("Clear Errors").click();
    });

    expect(container).toMatchSnapshot();
  });
});
