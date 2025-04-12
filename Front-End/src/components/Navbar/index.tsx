'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

/**
 * Navbar component: navigation bar with links to different pages of the application.
 * ---------------------------------------------------------------------------------
 * Current version: The only page that has content is the video-playback (session review) page. 
 */
const Navbar = () => {
    const pathname = usePathname();

    const isActive = (path: string) => pathname === path;

    const preventNavigation = (e: React.MouseEvent<HTMLAnchorElement>) => {
        e.preventDefault();
    };

    return (
        <nav className="bg-blue-700 text-white">
            <div className="px-6 py-2 flex space-x-8">
                <a 
                    href="/home" 
                    className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/home') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
                    onClick={preventNavigation}
                >
                    Home
                </a>
                <a 
                    href="/live-monitoring" 
                    className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/live-monitoring') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
                    onClick={preventNavigation}
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
                    onClick={preventNavigation}
                >
                    Reports
                </a>
                <a 
                    href="/another" 
                    className={`px-3 py-2 rounded-md text-sm font-medium ${isActive('/another') ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
                    onClick={preventNavigation}
                >
                    Another
                </a>
            </div>
        </nav>
    );
};

export default Navbar;