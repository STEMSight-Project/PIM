"use client";
import Link from "next/link";
import Image from "next/image";
import TextField from "@/components/TextField";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { login } from "@/services/authServices";

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

    await login(username, password)
      .then(async (res) => {
        if (!res) {
          console.error("No data received from API");
          setError("Login failed. Please try again.");
          return null;
        }
        console.log("Login successful:", res);

        router.push("/patient-dashboard");
      })
      .catch((error) => {
        // 2. If the server returned 401 with “Invalid credentials,” show a clear message
        if (error.status === 401) {
          setError("Invalid credentials. Please check your email or password.");
        } else {
          // Try to handle the detail array or string
          if (Array.isArray(error.detail) && error.detail.length > 0) {
            // Show the first message (or map over them in your UI)
            setError(error.detail[0].msg);
            window.alert(error.detail[0].msg); // Alert the first error message
          } else if (typeof error.detail === "string") {
            setError(error.detail);
          } else {
            setError("Login failed. Please try again.");
          }
          console.error("Error:", error);
          setError("Login failed. Please try again.");
          return null;
        }
      });
  };

  return (
    <div className="flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
      <div className="bg-white px-8 py-8 rounded-2xl">
        <form onSubmit={handleLogin} className="flex-row space-y-10">
          <div className="flex w-full h-full justify-center">
            <Image
              src="/STEMSight-Logo.png"
              alt="STEMSight Logo"
              width={256}
              height={256}
              className="object-contain"
            />
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
              <Link href="/create-account">
                {" "}
                {/*-- call render function for NewUserForm */}
                <span className="font-serif text-blue-800 hover:text-blue-300">
                  Contact Support {/* Create New User Account */}
                </span>
              </Link>
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
