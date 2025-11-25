const DEFAULT_DEV_API = "http://127.0.0.1:8000";
const PRODUCTION_DEFAULT_API = "https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net";
// We remove the specific host constant to make the check more flexible

const stripTrailingSlash = (url: string) => url.replace(/\/+$/, "");

const isLocalhost = (hostname: string) =>
  hostname === "localhost" || hostname === "127.0.0.1";

const normalizeBaseUrl = (url: string): string => {
  if (!url) return url;

  try {
    const parsed = new URL(url);
    
    // 1. FORCE HTTPS for your specific Azure backend
    // This fixes it even if your .env file says "http"
    if (parsed.hostname.includes("fastapibackend-amfucydqayg9h8gb")) {
       parsed.protocol = "https:";
    }

    // 2. Standard safety: If browser is HTTPS, API must be HTTPS
    if (typeof window !== "undefined" && window.location.protocol === "https:" && parsed.protocol === "http:") {
       parsed.protocol = "https:";
    }

    return stripTrailingSlash(parsed.toString());
  } catch {
    // Fallback: simple string replacement if URL parsing fails
    if (url.includes("azurewebsites.net")) {
        return stripTrailingSlash(url.replace("http://", "https://"));
    }
    return stripTrailingSlash(url);
  }
};

export const getApiBaseUrl = (): string => {
  // 1. Try the Environment Variable
  let envUrl = process.env.NEXT_PUBLIC_API_URL?.trim();
  
  if (envUrl) {
    return normalizeBaseUrl(envUrl);
  }

  // 2. Browser Client-Side Fallback
  if (typeof window !== "undefined") {
    if (isLocalhost(window.location.hostname)) {
      return DEFAULT_DEV_API;
    }
    return PRODUCTION_DEFAULT_API;
  }

  // 3. Server-Side Fallback
  if (process.env.NODE_ENV === "production") {
    return PRODUCTION_DEFAULT_API;
  }

  return DEFAULT_DEV_API;
};

export default getApiBaseUrl;