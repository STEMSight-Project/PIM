// services/api.ts
const BASE_URL = "http://127.0.0.1:8000";

export interface ApiResponse<T> {
  data: T | null;
  error: string | null;
}

export async function fetchData<T>(
  endpoint: string
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${BASE_URL}${endpoint}`);
    if (!response.ok) {
      throw new Error(`Failed to fetch: ${response.status}`);
    }
    const data = await response.json();
    return { data, error: null };
  } catch (error: unknown) {
    console.error("API error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error occurred";
    return { data: null, error: errorMessage };
  }
}

export async function postData<T>(
  endpoint: string,
  data: any
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error(`Failed to post: ${response.status}`);
    }
    const responseData = await response.json();
    return { data: responseData, error: null };
  } catch (error: unknown) {
    console.error("API error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error occurred";
    return { data: null, error: errorMessage };
  }
}

export async function deleteData<T>(
    endpoint: string
  ): Promise<ApiResponse<T>> {
    try {
      const response = await fetch(`${BASE_URL}${endpoint}`, {
        method: "DELETE",
      });
      if (!response.ok) {
        throw new Error(`Failed to delete: ${response.status}`);
      }
      const responseData = await response.json();
      return { data: responseData, error: null };
    } catch (error: unknown) {
      console.error("API error:", error);
      const errorMessage = error instanceof Error ? error.message : "Unknown error occurred";
      return { data: null, error: errorMessage };
    }
  }