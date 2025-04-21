"use client";
import React, { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";

export default function ResetPassword() {
  const router = useRouter(); //The useRouter initialized to handle page navigation
  const searchParams = useSearchParams(); //paramters from teh url are accessed by this
  const accessToken = searchParams.get("access_token"); //The access token can be accessed by the URL

  //The state variables for managing the inputs and messages of this page
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    // Will check to see existence and validity of access token
    if (!accessToken) {
      setError("Missing access token."); //Will rise error for missing token
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match."); //will rise error if password fields do not match each other
      return;
    }

    try {
      // will send a request to backend to reset password
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/auth/confirm-password-reset`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          access_token: accessToken, //token is being accessed
          new_password: password,  //The new password is being passed
        }),
      });

      const data = await res.json(); //The response data is parsed
      if (!res.ok) {
        setError(data.detail || "Something went wrong."); //If response NOT ok, will set error message
      } 
      //The form will be reset and show success message below
      else {
        setSuccess("Your password has been successfully reset.");
        setPassword("");
        setConfirmPassword("");
        setError("");
        //Below the router will redirect the page to the main login page after 2 seconds
        setTimeout(() => router.push("/page"), 2000); // Redirect after 2 seconds
      }
    } catch (err) {
      console.error("Error sending reset request:", err); //Will log error to console if detected
      setError("Server error. Please try again later.");  // Set error message if server error encountered.
    }
  };

  return (
    <div className="flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
      <div className="bg-white px-8 py-8 rounded-2xl shadow-lg w-full max-w-md">
        <h2 className="font-bold font-serif text-2xl text-black text-center mb-4">
          Reset Your Password
        </h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
            <input
              type="password"
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-black"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
            <input
              type="password"
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-black"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          {success && <p className="text-green-500 text-sm">{success}</p>}
          <button
            type="submit"
            className="mt-4 w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-500"
          >
            Reset Password
          </button>
        </form>
      </div>
    </div>
  );
}
