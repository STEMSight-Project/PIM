import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  // Removed static export for dynamic patient routes
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  serverExternalPackages: [],
  // Fix workspace root detection warning
  outputFileTracingRoot: path.join(__dirname),
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
    // Support either an absolute backend url (http[s]://host) or a root-path proxy '/api'
    // Default to localhost backend for development when env is not set
    const rawBackendUrl = process.env.NEXT_PUBLIC_API_URL ?? process.env.NEXT_PUBLIC_BACKEND_URL ?? "http://localhost:8000";

    let backendUrl = String(rawBackendUrl).trim();

    // If user passed a host like 'localhost:8000' without scheme, normalize it with http
    if (!backendUrl.startsWith('/') && !backendUrl.startsWith('http://') && !backendUrl.startsWith('https://')) {
      backendUrl = `http://${backendUrl}`;
    }

    // Remove any trailing slash for consistent rewrite dest construction
    backendUrl = backendUrl.replace(/\/$/, '');

    const apiDest = backendUrl.startsWith('/') || backendUrl.startsWith('http') ? `${backendUrl}/:path*` : `/${backendUrl}/:path*`;
    const videosDest = backendUrl.startsWith('/') || backendUrl.startsWith('http') ? `${backendUrl}/videos/:path*` : `/${backendUrl}/videos/:path*`;

    return [
      {
        source: '/api/:path*',
        destination: apiDest,
      },
      {
        source: '/videos/:path*',
        destination: videosDest,
      },
    ];
  },
};

module.exports = nextConfig;

export default nextConfig;
