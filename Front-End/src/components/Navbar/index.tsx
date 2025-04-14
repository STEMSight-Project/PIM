'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

/**
 * Navbar component: navigation bar with links to different pages of the application.
 * ---------------------------------------------------------------------------------
 * Dynamically checks if a `patientId` is available and updates the `Live Monitoring` link accordingly.
 */
const Navbar = ({ patientId }: { patientId: string | null }) => {
  const pathname = usePathname();

  const isActive = (path: string) => pathname === path;

  return (
    <nav className="bg-blue-700 text-white">
      <div className="px-6 py-2 flex space-x-8">
        <a 
          href="/patient-dashboard" 
          className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/patient-dashboard') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
        >
          Home
        </a>
        <a 
          href={patientId ? `/streamingDash?patientId=${patientId}` : '#'} 
          className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/live-monitoring') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
          onClick={(e) => {
            if (!patientId) {
              e.preventDefault(); // Prevent navigation if no patientId is available
              alert('No patient selected for live monitoring.');
            }
          }}
        >
          Live Monitoring
        </a>
        <Link 
          href="/video-playback" 
          className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/video-playback') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
        >
          Session Review
        </Link>
        <a 
          href="/reports" 
          className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/reports') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
        >
          Reports
        </a>
        <a 
          href="/another" 
          className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/another') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
        >
          Another
        </a>
      </div>
    </nav>
  );
};

export default Navbar;