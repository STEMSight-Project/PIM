"use client";
import React, { useState } from 'react';
import TextField from "@/components/TextField"; 

export default function PatientDashboard() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(''); 

  const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(event.currentTarget.value);
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }
    setError('');
    setSuccess('A reset link has been sent to your email address.'); // Success message
  };

  return (
    <div className="flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
      <div className="bg-white px-8 py-8 rounded-2xl">
        <div className="flex-row space-y-10">
          <h2 className="font-bold font-serif px-16 text-2xl text-black">
            Forgot Password</h2>
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700">
                Email Address</label>
              <TextField
                type="email"
                value={email}
                onChange={handleEmailChange}
              />
            </div>
            {error && <p className="text-red-500">{error}</p>}
            {success && <p className="text-green-500">{success}</p>} {/* Display success message */}
            <button
              type="submit"
              className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-500"
            >
              Send Reset Link
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

