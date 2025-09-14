import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Removed static export for dynamic patient routes
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  serverExternalPackages: [],
  // Ensure consistent hydration
  reactStrictMode: true,
  // Handle suppressHydrationWarning
  compiler: {
    // Remove console logs in production
    removeConsole: process.env.NODE_ENV === "production",
  },
};

module.exports = nextConfig;

export default nextConfig;
