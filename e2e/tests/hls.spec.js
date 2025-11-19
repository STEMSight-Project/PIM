const { test, expect } = require('@playwright/test');
const fs = require('fs');

test.describe('HLS Test Player', () => {
  test('loads test player page and shows UI', async ({ page }) => {
    // Visit the backend-provided test player for the room we create in CI
    const roomId = 'TEST-E2E-ROOM';
    await page.goto(`/videos/test-player/${roomId}`);

    // Expect the title to be present
    await expect(page.locator('h1')).toContainText('HLS Test Player');

    // Video element should exist
    const video = page.locator('video');
    await expect(video).toHaveCount(1);

    // Take a screenshot of the player area
    await page.screenshot({ path: '../e2e-screenshots/hls-player.png', fullPage: false });
  });
});
