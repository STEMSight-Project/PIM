"use client";
import { Suspense } from "react";
import ResetPassword from "./reset-password";

export default function App() {
  return (
    <Suspense>
      <ResetPassword />
    </Suspense>
  );
}
