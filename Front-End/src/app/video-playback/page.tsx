'use client';

import React from 'react';
import SessionReview from '@/components/session-review/SessionReview';
import Header from '@/components/Header'; 
import Footer from '@/components/Footer'; 

/**
 * Video Playback/Session Review Page: Enables users to review recorded sessions with timestamped event markers.
 * ---------------------------------------------------------------------------------
 * User can create notes linked to video timestamps.
 */
export default function SessionReviewPage() {
  return (
    <div className="bg-gray-50 min-h-screen">
      <Header /> 
      <SessionReview />
      <Footer /> 
    </div>
  );
}