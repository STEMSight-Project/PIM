import "@testing-library/jest-dom";
import { cleanup } from "@testing-library/react";
import { afterEach, expect, vi } from "vitest";

// Cleanup after each test
afterEach(() => {
  cleanup();
});

// Custom snapshot serializer to normalize random Input IDs
expect.addSnapshotSerializer({
  test: (val) => {
    // Test if this is an HTML element or string containing input elements
    if (val && val.outerHTML && typeof val.outerHTML === "string") {
      return val.outerHTML.includes('id="input-');
    }
    return typeof val === "string" && val.includes('id="input-');
  },
  serialize: (val, config, indentation, depth, refs, printer) => {
    // Get HTML string from element or use string directly
    let html = typeof val === "string" ? val : val.outerHTML || String(val);

    // Replace all dynamic Input IDs with a normalized version
    const normalized = html.replace(
      /id="input-[a-z0-9]+"/g,
      'id="input-normalized"'
    );

    // For HTML elements, return the normalized HTML
    if (val && val.nodeType) {
      return normalized;
    }

    return printer(normalized, config, indentation, depth, refs);
  },
});

// Mock Next.js router
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
    back: vi.fn(),
    pathname: "/",
    query: {},
    asPath: "/",
  }),
  usePathname: () => "/",
  useSearchParams: () => new URLSearchParams(),
  useParams: () => ({}),
}));

// Mock window.matchMedia
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});
