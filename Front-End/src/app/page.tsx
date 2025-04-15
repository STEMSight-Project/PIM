"use client";
import Link from "next/link";
import TextField from "@/components/TextField";
import Image from "next/image";
import { useState } from "react";
import { useRouter } from "next/navigation";
import STEMSightLogo from "../assets/STEMSight-Logo.png";

export default function App() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleUsernameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setUsername(event.currentTarget.value);
  };

  const handlePasswordChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(event.currentTarget.value);
  };

  const handleLogin = async (event: React.FormEvent) => {
    event.preventDefault();

    // 1. Check for empty fields before sending request
    if (!username.trim() || !password.trim()) {
      setError("Email and password are required.");
      return;
    }

    try {
      const response = await fetch("http://127.0.0.1:8000/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: username, password }),
      });

      if (response.ok) {
        // Login succeeded
        const data = await response.json();
        console.log("Login successful:", data);
        localStorage.setItem("access_token", data.access_token);
        router.push("/patient-dashboard");
      } else {
        // Login failed
        const errorRes = await response.json();

        // 2. If the server returned 401 with “Invalid credentials,” show a clear message
        if (response.status === 401) {
          setError("Invalid credentials. Please check your email or password.");
        } else {
          // Try to handle the detail array or string
          if (Array.isArray(errorRes.detail) && errorRes.detail.length > 0) {
            // Show the first message (or map over them in your UI)
            setError(errorRes.detail[0].msg);
          } else if (typeof errorRes.detail === "string") {
            setError(errorRes.detail);
          } else {
            setError("Login failed. Please try again.");
          }
        }
      }
    } catch (err) {
      console.error("Error during login:", err);
      setError("An unexpected error occurred. Please try again.");
    }
  };

  return (
    <div className="flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
      <div className="bg-white px-8 py-8 rounded-2xl">
        <form onSubmit={handleLogin} className="flex-row space-y-10">
          <div className="flex w-full h-full justify-center">
            <Image src={STEMSightLogo.src} alt="Logo" className="w-3xs" />
          </div>
          <p className="font-bold font-serif px-16 text-2xl text-black">
            Enter your login credentials
          </p>
          {/* Input Container */}
          <div className="flex-row space-y-2">
            <p className="font-serif text-black">Email:</p>
            <TextField value={username} onChange={handleUsernameChange} />
            <p className="font-serif text-black">Password:</p>
            <TextField
              value={password}
              type="password"
              onChange={handlePasswordChange}
            />
          </div>
          {/* Error Message */}
          {error && <p className="text-red-500 text-sm">{error}</p>}
          {/* Button Container */}
          <div className="flex w-full h-full justify-center">
            <button
              type="submit"
              className="text-white bg-blue-800 hover:bg-blue-400 w-1/2 py-2 rounded-[16px]"
            >
              <p className="font-bold font-serif text-[24px]">Login</p>
            </button>
          </div>
          <div className="flex-row space-y-0.5">
            <p className="font-serif text-black">
              Don't have an account?
              <a
                className="font-serif text-blue-800 hover:text-blue-300"
                href=""
              >
                Contact Support
              </a>
            </p>
            <p className="text-[16px] text-black">
              Forgot password?{" "}
              <Link href="/password-forgot">
                <span className="font-serif text-blue-800 hover:text-blue-300">
                  Reset password
                </span>
              </Link>
            </p>
          </div>
        </form>
      </div>
    </div>
  );
}
