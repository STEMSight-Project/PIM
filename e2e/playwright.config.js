// Playwright config for simple HLS player E2E checks
/** @type {import('@playwright/test').PlaywrightTestConfig} */
module.exports = {
  testDir: './tests',
  timeout: 30 * 1000,
  use: {
    headless: true,
    viewport: { width: 1280, height: 720 },
    actionTimeout: 10 * 1000,
    baseURL: 'http://localhost:8000',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
  ],
};
