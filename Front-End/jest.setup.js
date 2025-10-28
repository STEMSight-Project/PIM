require('@testing-library/jest-dom');

// Mock global fetch for jsdom environment
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: async () => ({ data: null, error: null }),
  })
);

// Mock window.alert for jsdom
global.alert = jest.fn();