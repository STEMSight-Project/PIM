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
  // ESLint configuration
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: true,
  },
  // Handle suppressHydrationWarning
  compiler: {
    // Remove console logs in production
    removeConsole: process.env.NODE_ENV === "production",
  },
  // Proxy API requests to backend
  async rewrites() {
    const backendUrl =
      process.env.NEXT_PUBLIC_API_URL;

    return [
      {
        source: "/api/:path*",
        destination: `${backendUrl}/:path*`,
      },
      {
        source: "/videos/:path*",
        destination: `${backendUrl}/videos/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;

export default nextConfig;
