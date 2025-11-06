/**
 * Unit tests for useClientSide hooks
 * Tests client-side rendering detection and localStorage access
 */

import { useIsClient, useLocalStorage } from "@/hooks/useClientSide";
import { act, renderHook } from "@testing-library/react";

describe("useIsClient", () => {
  it("should return boolean value", () => {
    const { result } = renderHook(() => useIsClient());

    // Should return a boolean
    expect(typeof result.current).toBe("boolean");
  });

  it("should return true in test environment", () => {
    const { result, rerender } = renderHook(() => useIsClient());

    // In test environment, effects run immediately
    // So isClient is true after initial render
    expect(result.current).toBe(true);

    rerender();
    expect(result.current).toBe(true);
  });

  it("should remain stable after multiple renders", () => {
    const { result, rerender } = renderHook(() => useIsClient());

    const firstValue = result.current;

    rerender();
    rerender();
    rerender();

    expect(result.current).toBe(firstValue);
    expect(result.current).toBe(true);
  });
});

describe("useLocalStorage", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("should initialize with null on server side", () => {
    const { result } = renderHook(() => useLocalStorage("testKey"));

    const [value] = result.current;
    expect(value).toBeNull();
  });

  it("should read value from localStorage on client side", () => {
    localStorage.setItem("testKey", "testValue");

    const { result, rerender } = renderHook(() => useLocalStorage("testKey"));

    // Rerender to simulate client side
    rerender();

    const [value] = result.current;
    expect(value).toBe("testValue");
  });

  it("should update localStorage when setValue is called", () => {
    const { result, rerender } = renderHook(() => useLocalStorage("testKey"));

    rerender(); // Simulate client side

    const [, setValue] = result.current;

    act(() => {
      setValue("newValue");
    });

    expect(localStorage.getItem("testKey")).toBe("newValue");
  });

  it("should remove item when setting null", () => {
    localStorage.setItem("testKey", "initialValue");

    const { result, rerender } = renderHook(() => useLocalStorage("testKey"));

    rerender();

    const [, setValue] = result.current;

    act(() => {
      setValue(null);
    });

    expect(localStorage.getItem("testKey")).toBeNull();
  });

  it("should handle multiple keys independently", () => {
    const { result: result1, rerender: rerender1 } = renderHook(() =>
      useLocalStorage("key1")
    );
    const { result: result2, rerender: rerender2 } = renderHook(() =>
      useLocalStorage("key2")
    );

    rerender1();
    rerender2();

    const [, setValue1] = result1.current;
    const [, setValue2] = result2.current;

    act(() => {
      setValue1("value1");
      setValue2("value2");
    });

    expect(localStorage.getItem("key1")).toBe("value1");
    expect(localStorage.getItem("key2")).toBe("value2");
  });
});
