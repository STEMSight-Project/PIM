const DEFAULT_DEV_API = "http://127.0.0.1:8000";
const PRODUCTION_DEFAULT_API =
  "https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net";

const stripTrailingSlash = (url: string) => url.replace(/\/+$/, "");

const isLocalhost = (hostname: string) =>
  hostname === "localhost" || hostname === "127.0.0.1";

/**
 * Determine the best API base URL for the current environment.
 * Prefers NEXT_PUBLIC_API_URL when provided, otherwise falls back to
 * localhost during development and the Azure FastAPI backend in production.
 */
export const getApiBaseUrl = (): string => {
  const envUrl = process.env.NEXT_PUBLIC_API_URL?.trim();
  if (envUrl) {
    return stripTrailingSlash(envUrl);
  }

  if (typeof window !== "undefined") {
    if (isLocalhost(window.location.hostname)) {
      return DEFAULT_DEV_API;
    }

    return PRODUCTION_DEFAULT_API;
  }

  if (process.env.NODE_ENV === "production") {
    return PRODUCTION_DEFAULT_API;
  }

  return DEFAULT_DEV_API;
};

export default getApiBaseUrl;
