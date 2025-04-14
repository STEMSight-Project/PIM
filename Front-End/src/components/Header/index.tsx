"use client";

import React from "react";
import { Bell, Settings, User } from "lucide-react";
import Navbar from "../Navbar";
import Link from "next/link";

const Header = ({ patientId }: { patientId: string | null }) => {
  return (
    <header className="bg-white shadow">
      <div className="flex items-center justify-between px-6 py-3">
        <div className="flex items-center space-x-4">
          {/* Clickable logo that navigates to the patient-dashboard */}
          <Link
            href="/patient-dashboard"
            className="font-bold text-2xl text-blue-700 transition-transform transform hover:scale-105"
          >
            StemSight
          </Link>
        </div>
        <div className="flex items-center space-x-6">
          <div className="relative">
            <button className="p-2 rounded-full hover:bg-gray-100 relative">
              <Bell className="w-6 h-6 text-gray-600" />
              <span className="absolute top-0 right-0 h-4 w-4 bg-red-500 rounded-full text-xs text-white flex items-center justify-center">
                3
              </span>
            </button>
          </div>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Settings className="w-6 h-6 text-gray-600" />
          </button>
          <div className="flex items-center space-x-2">
            {/* Clickable user name */}
            <Link
              href="/"
              className="text-sm font-medium text-gray-700 hover:underline"
            >
              Dr. Sarah Johnson
            </Link>
            {/* Clickable user icon */}
            <Link
              href="/"
              className="relative w-10 h-10 rounded-full bg-blue-200 flex items-center justify-center transition-transform transform hover:scale-110 hover:shadow-lg"
            >
              <User className="w-6 h-6 text-blue-700" />
            </Link>
          </div>
        </div>
      </div>
      {/* Pass patientId to Navbar */}
      <Navbar patientId={patientId} />
    </header>
  );
};

export default Header;
