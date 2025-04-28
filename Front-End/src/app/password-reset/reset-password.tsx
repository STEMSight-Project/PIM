"use client";
import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { change_password } from "@/services/authServices";
import Modal from "@/components/ModalPopUp/Modal";

export default function ResetPassword() {
  const router = useRouter(); //The useRouter initialized to handle page navigation

  //The state variables for managing the inputs and messages of this page
  const [access_token, setToken] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [popUp, setPopUp] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const hash = window.location.hash.substring(1);
      const params = new URLSearchParams(hash);
      const token = params.get("access_token");

      if (token) {
        setToken(token);
      }
      // 🔥 Remove token from URL bar (important!)
      window.history.replaceState(null, "", window.location.pathname);
    }
  }, []);

  const handleBackToLogin = () => {
    router.push("/"); //Redirects to login page
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    // Will check to see existence and validity of access token
    if (!access_token) {
      setError("Missing access token."); //Will rise error for missing token
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match."); //will rise error if password fields do not match each other
      return;
    }

    // will send a request to backend to reset password
    await change_password(access_token, password)
      .then((res) => {
        setSuccess(res.message);
        setError("");
        setConfirmPassword("");
        setPopUp(true);
      })
      .catch((error) => {
        setError("Unable to reset your password. Please try again!");
        console.log(error);
      });
    //The form will be reset and show success message below
  };

  return (
    <div className="flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
      <Modal hidden={!popUp}>
        <div className="mx-auto flex size-12 shrink-0 items-center justify-center rounded-full bg-green-100 sm:mx-0 sm:size-10">
          <svg
            className="size-6 text-green-600"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth="1.5"
            stroke="currentColor"
            aria-hidden="true"
            data-slot="icon"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M4.5 12.75l6 6 9-13.5"
            />
          </svg>
        </div>
        <div className="mt-3 text-center sm:text-center">
          <h3
            className="text-center font-semibold text-green-600"
            id="modal-title"
          >
            {success}Success reset password
          </h3>
        </div>
        <button
          onClick={handleBackToLogin}
          className="flex justify-center py-1 px-4 rounded-sm text-sm font-semibold bg-blue-400 hover:bg-blue-400/80"
        >
          Back to Login
        </button>
      </Modal>
      <div className="bg-white px-8 py-8 rounded-2xl shadow-lg w-full max-w-md">
        <h2 className="font-bold font-serif text-2xl text-black text-center mb-4">
          Reset Your Password
        </h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              New Password
            </label>
            <input
              type="password"
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-black"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Confirm Password
            </label>
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
