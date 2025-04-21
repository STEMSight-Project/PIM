'use client';

import React, { useState } from 'react';
import Timeline from './Timeline';
import Notes from './Notes';
import { Note } from "@/services/noteService";

type TabType = 'timeline' | 'notes';

interface TabsContainerProps {
    sessionId: string;
    notes: Note[];
    setNotes: React.Dispatch<React.SetStateAction<Note[]>>;
    setCurrentTimestamp: (time: number) => void;
    currentVideoTime: number;
    videoId: string;
    patientId: string;
}

const TabsContainer = ({ sessionId, setCurrentTimestamp, currentVideoTime, notes, setNotes, videoId, patientId }: TabsContainerProps) => {
    const [currentTab, setCurrentTab] = useState<TabType>('timeline');

    return (
        <div className="bg-white rounded-lg shadow-md">
            {/* Tab Navigation - Timeline and Notes */}
            <div className="border-b border-gray-200">
                <nav className="flex -mb-px">
                    <button
                        className={`py-4 px-6 text-center text-sm font-medium ${currentTab === 'timeline'
                            ? 'border-b-2 border-blue-500 text-blue-600'
                            : 'text-gray-500 hover:text-gray-700 hover:border-gray-300'
                            }`}
                        onClick={() => setCurrentTab('timeline')}
                    >
                        Timeline
                    </button>

                    <button
                        className={`py-4 px-6 text-center text-sm font-medium ${currentTab === 'notes'
                            ? 'border-b-2 border-blue-500 text-blue-600'
                            : 'text-gray-500 hover:text-gray-700 hover:border-gray-300'
                            }`}
                        onClick={() => { setCurrentTab('notes'); console.log('clicked on notes') }}
                    >
                        Notes
                    </button>
                </nav>
            </div>

            {/* Tab Content */}
            <div className="p-4 overflow-y-auto max-h-96">
                {currentTab === 'timeline' && <Timeline setCurrentTimestamp={setCurrentTimestamp} />}
                {currentTab === 'notes' && (
                    <Notes
                        sessionId={sessionId}
                        notes={notes}
                        setNotes={setNotes}
                        setCurrentTimestamp={setCurrentTimestamp}
                        currentVideoTime={currentVideoTime}
                        videoId={videoId}
                        patientId={patientId}
                    />

                )}

            </div>
        </div>

    );
};

export default TabsContainer;