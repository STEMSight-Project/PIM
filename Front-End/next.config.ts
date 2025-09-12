import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  experimental: {
    serverComponentsExternalPackages: [],
  },
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
