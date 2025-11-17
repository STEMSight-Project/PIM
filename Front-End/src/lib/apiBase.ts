const DEFAULT_DEV_API = "http://127.0.0.1:8000";
const PRODUCTION_DEFAULT_API =
  "https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net";
const AZURE_BACKEND_HOST =
  "fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net";

const stripTrailingSlash = (url: string) => url.replace(/\/+$/, "");

const isLocalhost = (hostname: string) =>
  hostname === "localhost" || hostname === "127.0.0.1";

const normalizeBaseUrl = (url: string): string => {
  if (!url) return url;

  try {
    const parsed = new URL(url);
    const needsHttpsSwap =
      parsed.protocol === "http:" &&
      (parsed.hostname === AZURE_BACKEND_HOST ||
        (typeof window !== "undefined" && window.location.protocol === "https:"));

    if (needsHttpsSwap) {
      parsed.protocol = "https:";
      return stripTrailingSlash(parsed.toString());
    }

    return stripTrailingSlash(parsed.toString());
  } catch {
    return stripTrailingSlash(url.replace(/^http:\/\//, "https://"));
  }
};

/**
 * Determine the best API base URL for the current environment.
 * Prefers NEXT_PUBLIC_API_URL when provided, otherwise falls back to
 * localhost during development and the Azure FastAPI backend in production.
 */
export const getApiBaseUrl = (): string => {
  const envUrl = process.env.NEXT_PUBLIC_API_URL?.trim();
  if (envUrl) {
    return normalizeBaseUrl(envUrl);
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
