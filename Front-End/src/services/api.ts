// services/api.ts
const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000";

const url = (endpoint: string) =>
  /^(http|https):\/\//i.test(endpoint)
    ? endpoint
    : `${BASE_URL}${endpoint.startsWith("/") ? "" : "/"}${endpoint}`;

type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

// async function refreshAccessToken() {
//   const refreshToken = localStorage.getItem("refresh_token");
//   if (!refreshToken) throw new Error("Missing refresh token");

//   const res = await fetch(url("/auth/refresh"), {
//     method: "POST",
//     headers: {
//       "Content-Type": "application/json",
//       Accept: "application/json",
//     },
//     body: JSON.stringify({ refresh_token: refreshToken }),
//   });

//   if (!res.ok) throw new Error("Failed to refresh token");

//   const result = await res.json();

//   localStorage.setItem("access_token", result.access_token);
//   if (result.refresh_token) {
//     localStorage.setItem("refresh_token", result.refresh_token);
//   }

//   return result.access_token;
// }

async function request<T>(
  endpoint: string,
  method: HttpMethod,
  body?: unknown,
  retry = true // Allow one retry after refreshing
): Promise<T> {
  try {
    const headers = new Headers();
    if (body) headers.append("Content-Type", "application/json");
    headers.append("Accept", "application/json");

    // const token = localStorage.getItem("access_token");
    // if (token) headers.append("Authorization", `Bearer ${token}`);

    const res = await fetch(url(endpoint), {
      method,
      credentials: "include",
      headers: headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (res.status === 401 && retry) {
      // await refreshAccessToken();
      return request<T>(endpoint, method, body, false);
    }

    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
    const data = await res.json();
    if (data["refresh_token"]) {
      localStorage.setItem("refresh_token", data["refresh_token"]);
      // maintaining the access token in local storage is not recommended for security reasons
    }
    return data as T;
  } catch (err) {
    const errMsg = err instanceof Error ? err.message : "Unknown network error";
    console.error("API error:", errMsg);
    throw new Error(errMsg);
  }
}

export const api = {
  get: <T>(e: string) => request<T>(e, "GET"),
  post: <T>(e: string, b: unknown) => request<T>(e, "POST", b),
  put: <T>(e: string, b: unknown) => request<T>(e, "PUT", b),
  patch: <T>(e: string, b: unknown) => request<T>(e, "PATCH", b),
  delete: <T>(e: string) => request<T>(e, "DELETE"),
};
