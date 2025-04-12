'use client';

import React from 'react';
import { Bell, Settings, User } from 'lucide-react';
import Navbar from '../Navbar';

/**
 * Header component: Renders the application header, including the title, notifications, settings, and user profile 
 * Also includes the navigation bar.
 * ----------------------------------------------------------------------------------------------------------------
 * Current Version: The notifs, settings, and user profile are static (click events not yet implemented for them)
 */

const Header = () => {
    return (
        <header className="bg-white shadow">
            <div className="flex items-center justify-between px-6 py-3">
                <div className="flex items-center space-x-4">
                    <div className="font-bold text-2xl text-blue-700">StemSight</div>
                </div>
                <div className="flex items-center space-x-6">
                    <div className="relative">
                        <button className="p-2 rounded-full hover:bg-gray-100 relative">
                            <Bell className="w-6 h-6 text-gray-600" />
                            <span className="absolute top-0 right-0 h-4 w-4 bg-red-500 rounded-full text-xs text-white flex items-center justify-center">3</span>
                        </button>
                    </div>
                    <button className="p-2 rounded-full hover:bg-gray-100">
                        <Settings className="w-6 h-6 text-gray-600" />
                    </button>
                    <div className="flex items-center space-x-2">
                        <span className="text-sm font-medium text-gray-700">Dr. Sarah Johnson</span>
                        <div className="relative">
                            <div className="w-10 h-10 rounded-full bg-blue-200 flex items-center justify-center">
                                <User className="w-6 h-6 text-blue-700" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <Navbar />
        </header>
    );
};

export default Header;