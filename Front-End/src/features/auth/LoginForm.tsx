"use client";

import { Alert, Button, Input } from "@/components/ui";
import { useAuth } from "@/hooks";
import { EyeIcon, EyeSlashIcon } from "@heroicons/react/24/outline";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

export function LoginForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { login, isLoading } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!email.trim() || !password.trim()) {
      setError("Email and password are required.");
      return;
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError("Please enter a valid email address.");
      return;
    }

    const result = await login({ email, password });

    if (result.success) {
      router.push("/dashboard");
    } else {
      setError(result.error || "Login failed. Please try again.");
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <Input
        label="Email Address"
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="doctor@stemsight.com"
        required
        autoComplete="email"
      />

      <div className="relative">
        <Input
          label="Password"
          type={showPassword ? "text" : "password"}
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Enter your password"
          required
          autoComplete="current-password"
        />
        <button
          type="button"
          className="absolute right-3 top-8 text-gray-400 hover:text-gray-600"
          onClick={() => setShowPassword(!showPassword)}
        >
          {showPassword ? (
            <EyeSlashIcon className="h-5 w-5" />
          ) : (
            <EyeIcon className="h-5 w-5" />
          )}
        </button>
      </div>

      {error && <Alert variant="error">{error}</Alert>}

      <Button type="submit" isLoading={isLoading} fullWidth size="lg">
        {isLoading ? "Signing in..." : "Sign In"}
      </Button>

      <div className="text-center">
        <Link
          href="/password-forgot"
          className="text-sm text-blue-600 hover:text-blue-500"
        >
          Forgot your password?
        </Link>
      </div>


      <div className="text-center text-sm text-gray-600">
        {/* Gives an option to create an account if user does not have one */}
        Don't have an account?{" "}
        <Link href="/create-account" className="text-blue-600 hover:underline">
          Create an account
        </Link>
      </div>
    </form>
  );
}
