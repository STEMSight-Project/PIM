// services/api.ts
const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000";

interface ApiResponse<T> {
  data: T | null;
  error: string | null;
}

const url = (endpoint: string) =>
  /^(http|https):\/\//i.test(endpoint)
    ? endpoint
    : `${BASE_URL}${endpoint.startsWith("/") ? "" : "/"}${endpoint}`;

type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

async function request<T>(
  endpoint: string,
  method: HttpMethod,
  body?: unknown
): Promise<ApiResponse<T>> {
  try {
    const res = await fetch(url(endpoint), {
      method,
      credentials: "include",
      headers: body ? { "Content-Type": "application/json" } : undefined,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);

    return { data: (await res.json()) as T, error: null };
  } catch (err) {
    const errMsg = err instanceof Error ? err.message : "Unknown network error";
    console.error("API error:", errMsg);
    return { data: null, error: errMsg };
  }
}

export const api = {
  get: <T>(e: string) => request<T>(e, "GET"),
  post: <T>(e: string, b: unknown) => request<T>(e, "POST", b),
  put: <T>(e: string, b: unknown) => request<T>(e, "PUT", b),
  patch: <T>(e: string, b: unknown) => request<T>(e, "PATCH", b),
  delete: <T>(e: string) => request<T>(e, "DELETE"),
};
