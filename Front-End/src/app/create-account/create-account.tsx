"use client";

import { api } from "@/services/api";
import Link from "next/link";
import { useRouter } from "next/navigation";
import React, { useEffect, useState } from "react";

// Fallback for the doctor specializations list in case the backend request fails
const FALLBACK_SPECIALIZATIONS = [
    "Choose an option ...",
    "General Practitioner",
    "Internal Medicine",
    "Cardiology",
    "Dermatology",
    "Endocrinology",
    "Gastroenterology",
    "Neurology",
    "Obstetrics",
    "Gynecology",
    "Oncology",
    "Orthopedics",
    "Pediatrics",
    "Psychiatry",
    "Radiology",
    "Urology",
];

export default function CreateAccount() {
    const router = useRouter();

    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [specializations, setSpecializations] = useState<string[]>(FALLBACK_SPECIALIZATIONS);
    const [specialization, setSpecialization] = useState<string>(FALLBACK_SPECIALIZATIONS[0]);
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [phone, setPhone] = useState("");
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState<string | null>(null);
    const [showModal, setShowModal] = useState<boolean>(false);
    const [countdown, setCountdown] = useState<number | null>(null);

    const validate = (): string | null => {
        if (!firstName.trim() || !lastName.trim()) return "First and last name are required.";
        if (!specialization) return "Specialization is required.";
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) return "Please enter a valid email address.";
        if (password.length < 8) return "Password must be at least 8 characters.";
        if (password !== confirmPassword) return "Passwords do not match.";
        const digits = phone.replace(/\D/g, "");
        if (digits.length < 10) return "Primary phone must have at least 10 digits.";
        return null;
    };

    useEffect(() => {
        let cancelled = false;
        (async () => {
            const { data, error } = await api.get<string[]>("/doctors/specializations");
            if (!cancelled) {
                if (data && Array.isArray(data) && data.length > 0) {
                    setSpecializations(data);
                    setSpecialization((prev) => (data.includes(prev) ? prev : data[0]));
                }
                // If error or empty, keep fallback list silently
            }
        })();
        return () => {
            cancelled = true;
        };
    }, []);

    // Handle countdown and redirect when modal is shown
    useEffect(() => {
        if (!showModal) return;
        if (countdown === null) return;
        if (countdown <= 0) {
            router.push("/");
            return;
        }
        const timer = setTimeout(() => {
            setCountdown((prev) => (prev !== null ? prev - 1 : null));
        }, 1000);
        return () => clearTimeout(timer);
    }, [showModal, countdown, router]);

    const onSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);
        setSuccess(null);

        const validationError = validate();
        if (validationError) {
            setError(validationError);
            return;
        }

        setSubmitting(true);
        try {
            // Backend generates UUID automatically from Supabase.
            const payload = {
                first_name: firstName.trim(),
                last_name: lastName.trim(),
                specialization,
                email: email.trim(),
                password: password,
                primary_phone: phone.replace(/\D/g, ""),
            };

            const { data, error } = await api.post("/auth/register-doctor", payload);

            if (error) {
                setError(error);
                return;
            }

            if (data) {
                // Show popup and start 4-->0 countdown, then redirect
                setSuccess("We've sent a verification email to your inbox. Please check your email and follow the instructions to complete your account.");
                setShowModal(true);
                setCountdown(4);
            }
        } catch (err) {
            const msg = err instanceof Error ? err.message : "Failed to create account";
            setError(msg);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="relative flex items-center justify-center h-screen bg-[linear-gradient(355.45deg,rgba(0,120,255,100%)11.26%,rgba(255,255,255,0)95.74%)]">
            {showModal && (
                <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/40">
                    <div className="bg-white rounded-xl shadow-lg p-6 w-full max-w-md text-center">
                        <h3 className="text-lg font-semibold mb-2">Check your email</h3>
                        <p className="text-sm text-gray-700">
                            We've sent a verification email to your inbox. Please check your email and follow the instructions to complete your account.
                        </p>
                        <p className="text-xs text-gray-500 mt-3">Redirecting to sign in in {countdown ?? 4} seconds…</p>
                    </div>
                </div>
            )}
            <div className="bg-white px-8 py-8 rounded-2xl shadow-md w-full max-w-lg z-10">
                <div className="space-y-6">
                    <h2 className="font-bold font-serif text-2xl text-black text-center">
                        Create Doctor Account
                    </h2>

                    {error && <p className="text-red-500 text-sm text-center">{error}</p>}
                    {!showModal && success && (
                        <p className="text-green-600 text-sm text-center">{success}</p>
                    )}

                    <form onSubmit={onSubmit} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700">First Name</label>
                            <input
                                type="text"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={firstName}
                                onChange={(e) => setFirstName(e.target.value)}
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Last Name</label>
                            <input
                                type="text"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={lastName}
                                onChange={(e) => setLastName(e.target.value)}
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Specialization</label>
                            <select
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={specialization}
                                onChange={(e) => setSpecialization(e.target.value)}
                                required
                            >
                                {specializations.map((spec: string) => (
                                    <option key={spec} value={spec}>
                                        {spec}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Work Email</label>
                            <input
                                type="email"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                required
                                autoComplete="email"
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Password</label>
                            <input
                                type="password"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                                autoComplete="new-password"
                            />
                            <p className="mt-1 text-xs text-gray-500">At least 8 characters.</p>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Confirm Password</label>
                            <input
                                type="password"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                required
                                autoComplete="new-password"
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Primary Phone</label>
                            <input
                                type="tel"
                                className="mt-1 w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={phone}
                                onChange={(e) => setPhone(e.target.value)}
                                placeholder="(555) 555-5555"
                                required
                            />
                            <p className="mt-1 text-xs text-gray-500">Digits only; at least 10 numbers.</p>
                        </div>

                        <button
                            type="submit"
                            disabled={submitting}
                            className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-500 disabled:opacity-60"
                        >
                            {submitting ? "Creating..." : "Create Account"}
                        </button>
                    </form>

                    <div className="text-center text-sm text-gray-600">
                        Already have an account?{" "}
                        <Link href="/" className="text-blue-600 hover:underline">
                            Sign in
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}

