import { api } from "./api";

interface LoginRequest {
  email: string;
  password: string;
}

interface LoginResponse {
  access_token: string;
  refresh_token: string;
}

interface AuthSession {
  access_token: string;
  refresh_token: string;
  user: {
    id: string;
    aud: string;
    confirmation_sent_at: Date;
    email?: string;
    phone?: string;
    role: string;
    confirmed_at?: Date;
    last_sign_in_at?: Date;
    created_at: Date;
    updated_at: Date;
  };
}

export async function login(
  email: string,
  password: string
): Promise<LoginResponse> {
  const loginRequest: LoginRequest = {
    email,
    password,
  };
  return await api.post<LoginResponse>("/auth/login", loginRequest);
}

export async function reset_password_request(
  email: string
): Promise<{ message: string }> {
  return await api.post<{ message: string }>("/auth/request-password-reset", {
    email,
  });
}

export async function change_password(
  access_token: string,
  new_password: string
): Promise<{ message: string }> {
  return await api.post<{ message: string }>("/auth/confirm-password-reset", {
    access_token,
    new_password,
  });
}

export async function getCurrentAuthSession(): Promise<AuthSession> {
  return await api.get("/auth/me");
}
