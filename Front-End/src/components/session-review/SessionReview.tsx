'use client';

import React, { useState, useEffect } from 'react';
import TabsContainer from './Tabs/TabsContainer';
import VideoPlayer from './VideoPlayer';
import SessionGallery from './Gallery';
import SessionHeader from './SessionHeader';

interface SessionData {
    id: string;
    stationId: string;
    patientId: string;
    sessionDate: string;
    startTime: string;
    endTime: string;
}

const SessionReview = () => {
    // Default session mock data
    const defaultSessionId = 'session-123';
    const defaultSessionData = {
        id: defaultSessionId,
        stationId: 'S-103',
        patientId: '28491',
        sessionDate: 'March 17, 2025',
        startTime: '10:35 AM',
        endTime: '10:50 AM'
    };

    // State for session management
    const [sessionId, setSessionId] = useState<string>(defaultSessionId);
    const [sessionData, setSessionData] = useState<SessionData>(defaultSessionData);

    // States for video player and tabs interaction
    const [currentTimestamp, setCurrentTimestamp] = useState<number>(0); // for "jump to" buttons (tab -> video player)
    const [currentVideoTime, setCurrentVideoTime] = useState<number>(0); // for linking timestamp to note (video player -> tab)

    // Mock session data 
    const mockSessionsData: { [key: string]: SessionData } = {
        'session-123': {
            id: 'session-123',
            stationId: 'S-103',
            patientId: '28491',
            sessionDate: 'March 17, 2025',
            startTime: '10:35 AM',
            endTime: '10:50 AM'
        },
        'session-124': {
            id: 'session-124',
            stationId: 'S-217',
            patientId: '28495',
            sessionDate: 'March 17, 2025',
            startTime: '9:22 AM',
            endTime: '9:40 AM'
        },
        'session-125': {
            id: 'session-125',
            stationId: 'S-103',
            patientId: '28492',
            sessionDate: 'March 17, 2025',
            startTime: '8:47 AM',
            endTime: '9:05 AM'
        },
        'session-126': {
            id: 'session-126',
            stationId: 'S-054',
            patientId: '28487',
            sessionDate: 'March 16, 2025',
            startTime: '4:12 PM',
            endTime: '4:30 PM'
        },
        'session-127': {
            id: 'session-127',
            stationId: 'S-217',
            patientId: '28486',
            sessionDate: 'March 16, 2025',
            startTime: '2:38 PM',
            endTime: '2:55 PM'
        },
        'session-128': {
            id: 'session-128',
            stationId: 'S-103',
            patientId: '28483',
            sessionDate: 'March 16, 2025',
            startTime: '11:04 AM',
            endTime: '11:22 AM'
        },
        'session-129': {
            id: 'session-129',
            stationId: 'S-221',
            patientId: '28480',
            sessionDate: 'March 15, 2025',
            startTime: '7:55 PM',
            endTime: '8:15 PM'
        },
        'session-130': {
            id: 'session-130',
            stationId: 'S-103',
            patientId: '28478',
            sessionDate: 'March 15, 2025',
            startTime: '3:17 PM',
            endTime: '3:35 PM'
        },
        'session-131': {
            id: 'session-131',
            stationId: 'S-217',
            patientId: '28475',
            sessionDate: 'March 15, 2025',
            startTime: '10:42 AM',
            endTime: '11:00 AM'
        },
        'session-132': {
            id: 'session-132',
            stationId: 'S-103',
            patientId: '28472',
            sessionDate: 'March 14, 2025',
            startTime: '8:09 PM',
            endTime: '8:30 PM'
        }
    };

    // This function sets the currentVideoTime to the current time being displayed in the playback 
    const handleTimeUpdate = (time: number) => {
        setCurrentVideoTime(time);
    };

    // This function handles session selection from the gallery
    const handleSessionSelect = (selectedSessionId: string) => {
        setSessionId(selectedSessionId);

        // Find the session data for the selected session
        const newSessionData = mockSessionsData[selectedSessionId] || defaultSessionData;
        setSessionData(newSessionData);

        // Reset video time when switching sessions
        setCurrentTimestamp(0);
        setCurrentVideoTime(0);
    };

    return (
        <div className="container mx-auto bg-gray-50 p-6 min-h-screen">
            {/* Session Header with patient info */}
            <SessionHeader
                stationId={sessionData.stationId}
                patientId={sessionData.patientId}
                sessionDate={sessionData.sessionDate}
                startTime={sessionData.startTime}
                endTime={sessionData.endTime}
            />

            {/* Main Content Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Left Column (Video Player + Tabs) */}
                <div className="lg:col-span-2 space-y-6">
                    {/* Video Player */}
                    <VideoPlayer
                        //sessionId={sessionId}
                        currentTimestamp={currentTimestamp}
                        onTimeUpdate={handleTimeUpdate}
                    />
                    {/* Tabs Container */}
                    <TabsContainer
                        sessionId={sessionId}
                        setCurrentTimestamp={setCurrentTimestamp}
                        currentVideoTime={currentVideoTime}
                    />
                </div>

                {/* Right Column (Session Gallery) */}
                <div className="space-y-6">
                    {/* Session Gallery with selection functionality */}
                    <SessionGallery onSessionSelect={handleSessionSelect} />
                </div>
            </div>
        </div>
    );
};

export default SessionReview;