import React from 'react';

const Footer = () => {
    return (
        <footer className="bg-white border-t border-gray-200 py-4">
            <div className="container mx-auto px-6">
                <div className="flex justify-between items-center">
                    <div className="text-sm text-gray-600">
                        © 2025 PIM - StemSight - Virtual Neurologist {/* put all three titles for now */}
                    </div>
                    <div className="text-sm text-gray-600">
                        Version 1.0.0
                    </div>
                </div>
            </div>
        </footer>
    );
};

export default Footer;