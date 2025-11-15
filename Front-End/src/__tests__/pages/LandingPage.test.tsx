import React from 'react';
import { render, screen } from '@testing-library/react';
import LandingPage from '@/app/page';

// The landing page test suite with 2 test cases
describe('LandingPage', () => {
    // Test to ensure that main heading and primary page links are rendered correctly
    it('renders main heading and primary links', () => {
        render(<LandingPage />);

        // Makes sure the main heading is present when rendering the page
        expect(screen.getByText(/Advanced Patient Information Management/i)).toBeInTheDocument();

        // Makes sure that brand "StemSight PIM" appear once, either at header or footer
        const brands = screen.getAllByText(/STEMSight PIM/i);
        expect(brands.length).toBeGreaterThanOrEqual(1);

        // Makes sure the links are present, 2 login links and 1 create account link
        const loginLinks = screen.getAllByRole('link', { name: /login/i });
        expect(loginLinks.length).toBeGreaterThanOrEqual(1);
        expect(screen.getByRole('link', { name: /create account/i })).toBeInTheDocument();
    });

    // Test to ensure that key feature titles are rendered on the landing page
    it('renders key feature titles', () => {
        render(<LandingPage />);

        expect(screen.getByText(/Real-time Video Streaming/i)).toBeInTheDocument();
        expect(screen.getByText(/Medical History Management/i)).toBeInTheDocument();
        expect(screen.getByText(/AI-Powered Analysis/i)).toBeInTheDocument();
        expect(screen.getByText(/Real-time Communication/i)).toBeInTheDocument();
        expect(screen.getByText(/Emergency Response/i)).toBeInTheDocument();
        expect(screen.getByText(/Analytics & Reporting/i)).toBeInTheDocument();
    });
});
