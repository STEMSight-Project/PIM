'use client';

import React, { useState, useEffect } from 'react';
import { Grid, List, ChevronLeft, ChevronRight } from 'lucide-react';
/**
 * Session Gallery: displays and manages a gallery of sessions with view and sorting options.
 * When user clicks on one it will take them to the session review (video playback) for that patient session
 * ------------------------------------------------------------------------
 * Current version: uses dummy data; clicking on a session updates the title
 * but does not yet affect video or tab container content (timeline/notes).
 */
interface Detection {
    type: string;
    color: string;
}

interface SessionItem {
    id: string;
    patientId: string;
    date: string;
    time: string;
    ambulanceId: string;
    detections: Detection[];
    detectionCount: number;
    isSelected: boolean;
}

interface ColorConfig {
    bg: string;
    dot: string;
    border: string;
}

interface ColorMap {
    [key: string]: ColorConfig;
}

interface SessionGalleryProps {
    onSessionSelect?: (sessionId: string) => void;
}

const SessionGallery: React.FC<SessionGalleryProps> = ({ onSessionSelect }) => {
    const [viewMode, setViewMode] = useState<'list' | 'grid'>('list');
    const [sortOption, setSortOption] = useState<string>('latest');
    const [sessions, setSessions] = useState<SessionItem[]>([]);

    const colorMap: ColorMap = {
        red: {
            bg: 'bg-red-100',
            dot: 'bg-red-500',
            border: 'border-red-500'
        },
        yellow: {
            bg: 'bg-yellow-100',
            dot: 'bg-yellow-500',
            border: 'border-yellow-500'
        },
        blue: {
            bg: 'bg-blue-100',
            dot: 'bg-blue-500',
            border: 'border-blue-500'
        },
        green: {
            bg: 'bg-green-100',
            dot: 'bg-green-500',
            border: 'border-green-500'
        },
        purple: {
            bg: 'bg-purple-100',
            dot: 'bg-purple-500',
            border: 'border-purple-500'
        },
        orange: {
            bg: 'bg-orange-100',
            dot: 'bg-orange-500',
            border: 'border-orange-500'
        }
    };

    // Mock data for sessions
    const initialSessions: SessionItem[] = [
        {
            id: 'session-123',
            patientId: '28491',
            date: 'March 17, 2025',
            time: '10:35 AM',
            ambulanceId: 'S-103',
            detections: [
                { type: 'myoclonus', color: 'red' },
                { type: 'tremor', color: 'yellow' },
                { type: 'decerebrate', color: 'purple' },
                { type: 'decorticate', color: 'blue' },
            ],
            detectionCount: 4,
            isSelected: true
        },
        {
            id: 'session-124',
            patientId: '28495',
            date: 'March 17, 2025',
            time: '9:22 AM',
            ambulanceId: 'S-217',
            detections: [
                { type: 'versive', color: 'orange' }
            ],
            detectionCount: 1,
            isSelected: false
        },
        {
            id: 'session-125',
            patientId: '28492',
            date: 'March 17, 2025',
            time: '8:47 AM',
            ambulanceId: 'S-103',
            detections: [
                { type: 'ballistic', color: 'green' },
                { type: 'decerebrate', color: 'purple' }
            ],
            detectionCount: 3,
            isSelected: false
        },
        {
            id: 'session-126',
            patientId: '28487',
            date: 'March 16, 2025',
            time: '4:12 PM',
            ambulanceId: 'S-054',
            detections: [
                { type: 'myoclonus', color: 'red' }
            ],
            detectionCount: 1,
            isSelected: false
        },
        {
            id: 'session-127',
            patientId: '28486',
            date: 'March 16, 2025',
            time: '2:38 PM',
            ambulanceId: 'S-217',
            detections: [
                { type: 'tremor', color: 'yellow' }
            ],
            detectionCount: 1,
            isSelected: false
        },
        {
            id: 'session-128',
            patientId: '28483',
            date: 'March 16, 2025',
            time: '11:04 AM',
            ambulanceId: 'S-103',
            detections: [],
            detectionCount: 0,
            isSelected: false
        },
        {
            id: 'session-129',
            patientId: '28480',
            date: 'March 15, 2025',
            time: '7:55 PM',
            ambulanceId: 'S-221',
            detections: [
                { type: 'decerebrate', color: 'red' },
                { type: 'myoclonus', color: 'green' },
                { type: 'ballistic', color: 'orange' }
            ],
            detectionCount: 4,
            isSelected: false
        },
        {
            id: 'session-130',
            patientId: '28478',
            date: 'March 15, 2025',
            time: '3:17 PM',
            ambulanceId: 'S-103',
            detections: [
                { type: 'versive', color: 'purple' },
                { type: 'tremor', color: 'yellow' }
            ],
            detectionCount: 2,
            isSelected: false
        },
        {
            id: 'session-131',
            patientId: '28475',
            date: 'March 15, 2025',
            time: '10:42 AM',
            ambulanceId: 'S-217',
            detections: [
                { type: 'decorticate', color: 'blue' }
            ],
            detectionCount: 1,
            isSelected: false
        },
        {
            id: 'session-132',
            patientId: '28472',
            date: 'March 14, 2025',
            time: '8:09 PM',
            ambulanceId: 'S-103',
            detections: [
                { type: 'ballistic', color: 'orange' },
                { type: 'tremor', color: 'yellow' }
            ],
            detectionCount: 2,
            isSelected: false
        }
    ];

    useEffect(() => {
        setSessions(initialSessions);
    }, []);

    // Function to handle session selection
    const handleSessionSelect = (id: string) => {
        const updatedSessions = sessions.map(session => ({
            ...session,
            isSelected: session.id === id
        }));

        setSessions(updatedSessions);

        // Call the parent component's onSessionSelect if provided
        if (onSessionSelect) {
            onSessionSelect(id);
        }
    };

    // Function to convert date string to Date object for sorting
    const parseDateTime = (date: string, time: string): Date => {
        const [month, day, year] = date.split(' ');
        const monthIndex = ['January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December']
            .indexOf(month);

        const cleanDay = day.replace(',', '');

        const [hourMinute, period] = time.split(' ');
        let [hours, minutes] = hourMinute.split(':').map(Number);

        // Convert to 24-hour format
        if (period === 'PM' && hours < 12) {
            hours += 12;
        } else if (period === 'AM' && hours === 12) {
            hours = 0;
        }

        return new Date(Number(year), monthIndex, Number(cleanDay), hours, minutes);
    };

    // Function to sort sessions based on selected option
    const sortSessions = (option: string) => {
        let sortedSessions = [...sessions];

        switch (option) {
            case 'latest':
                sortedSessions.sort((a, b) => {
                    const dateA = parseDateTime(a.date, a.time);
                    const dateB = parseDateTime(b.date, b.time);
                    return dateB.getTime() - dateA.getTime();
                });
                break;
            case 'oldest':
                sortedSessions.sort((a, b) => {
                    const dateA = parseDateTime(a.date, a.time);
                    const dateB = parseDateTime(b.date, b.time);
                    return dateA.getTime() - dateB.getTime();
                });
                break;
            case 'mostDetections':
                sortedSessions.sort((a, b) => b.detectionCount - a.detectionCount);
                break;
            default:
                break;
        }

        setSessions(sortedSessions);
    };

    // updates sort option when different one is selected
    const handleSortChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const option = e.target.value;
        setSortOption(option);
        sortSessions(option);
    };

    return (
        <div className="bg-white rounded-lg shadow-md overflow-hidden flex flex-col h-full">
            {/* Gallery Header */}
            <div className="p-4 border-b border-gray-200">
                <h2 className="text-lg font-medium text-gray-800 mb-3">Session Gallery</h2>
                <div className="relative">
                </div>
            </div>

            {/* Gallery Controls */}
            <div className="px-4 py-2 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                <div className="flex space-x-1">
                    <button
                        className={`p-1.5 rounded ${viewMode === 'grid' ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-200'}`}
                        onClick={() => setViewMode('grid')}
                        aria-label="Grid view"
                    >
                        <Grid className="w-4 h-4" />
                    </button>
                    <button
                        className={`p-1.5 rounded ${viewMode === 'list' ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-200'}`}
                        onClick={() => setViewMode('list')}
                        aria-label="List view"
                    >
                        <List className="w-4 h-4" />
                    </button>
                </div>

                <div className="flex items-center">
                    <span className="mx-2 text-gray-300">|</span>
                    <select
                        className="text-sm text-gray-600 bg-transparent border-none focus:ring-0"
                        value={sortOption}
                        onChange={handleSortChange}
                    >
                        <option value="latest">Latest First</option>
                        <option value="oldest">Oldest First</option>
                        <option value="mostDetections">Most Detections</option>
                    </select>
                </div>
            </div>

            {/* Session List */}
            <div className="flex-grow overflow-y-auto max-h-[500px]">
                {viewMode === 'list' ? (
                    <div className="divide-y divide-gray-200">
                        {sessions.map(session => (
                            <div
                                key={session.id}
                                className={`p-3 cursor-pointer ${session.isSelected ? 'bg-blue-50 border-l-4 border-blue-500' : 'hover:bg-gray-50'}`}
                                onClick={() => handleSessionSelect(session.id)}
                            >
                                <div className="flex justify-between">
                                    <div>
                                        <h3 className={`text-sm font-medium ${session.isSelected ? 'text-blue-800' : 'text-gray-800'}`}>
                                            Patient ID: {session.patientId}
                                        </h3>
                                        <p className={`text-xs ${session.isSelected ? 'text-blue-600' : 'text-gray-600'}`}>
                                            {session.date} - {session.time}
                                        </p>
                                    </div>
                                    <div className="flex items-start space-x-2">
                                        <div className="flex -space-x-1">
                                            {session.detections.slice(0, 4).map((detection, index) => (
                                                <div
                                                    key={index}
                                                    className={`h-5 w-5 rounded-full ${colorMap[detection.color]?.bg || 'bg-gray-100'} flex items-center justify-center border border-white`}
                                                    title={detection.type}
                                                >
                                                    <div className={`h-2 w-2 rounded-full ${colorMap[detection.color]?.dot || 'bg-gray-500'}`}></div>
                                                </div>
                                            ))}
                                            {session.detections.length > 4 && (
                                                <div className="h-5 w-5 rounded-full bg-gray-100 flex items-center justify-center border border-white text-xs text-gray-600">
                                                    +{session.detections.length - 4}
                                                </div>
                                            )}
                                        </div>
                                        <span className="text-xs bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                                            {session.ambulanceId}
                                        </span>
                                    </div>
                                </div>
                                <div className="mt-1 flex items-center justify-between">
                                    <div className="flex items-center">
                                        <div className={`h-2 w-2 rounded-full ${session.detectionCount > 0 ? 'bg-green-500' : 'bg-gray-500'} mr-1`}></div>
                                        <span className={`text-xs ${session.detectionCount > 0 ? 'text-green-700' : 'text-gray-700'}`}>
                                            {session.detectionCount > 0 ? `${session.detectionCount} detection${session.detectionCount !== 1 ? 's' : ''}` : 'No detections'}
                                        </span>
                                    </div>
                                    <button
                                        className="text-xs text-blue-600 hover:text-blue-800"
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            handleSessionSelect(session.id);
                                        }}
                                    >
                                        View
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                ) : (
                    // Grid View Mode
                    <div className="grid grid-cols-2 gap-2 p-2">
                        {sessions.map(session => (
                            <div
                                key={session.id}
                                className={`${session.isSelected
                                    ? 'bg-blue-50 border-2 border-blue-500'
                                    : 'bg-white border border-gray-200 hover:bg-gray-50'
                                    } rounded-lg p-2 cursor-pointer`}
                                onClick={() => handleSessionSelect(session.id)}
                            >
                                <div className="relative h-24 bg-gray-200 rounded mb-2 overflow-hidden">
                                    <img src="/api/placeholder/150/100" alt="Thumbnail" className="object-cover w-full h-full" />
                                    <div className="absolute top-1 right-1 flex -space-x-1">
                                        {session.detections.slice(0, 3).map((detection, index) => (
                                            <div
                                                key={index}
                                                className={`h-5 w-5 rounded-full ${colorMap[detection.color]?.bg || 'bg-gray-100'} flex items-center justify-center border border-white`}
                                                title={detection.type}
                                            >
                                                <div className={`h-2 w-2 rounded-full ${colorMap[detection.color]?.dot || 'bg-gray-500'}`}></div>
                                            </div>
                                        ))}
                                        {session.detections.length > 3 && (
                                            <div className="h-5 w-5 rounded-full bg-gray-100 flex items-center justify-center border border-white text-xs text-gray-600">
                                                +{session.detections.length - 3}
                                            </div>
                                        )}
                                    </div>
                                </div>
                                <h3 className={`text-xs font-medium ${session.isSelected ? 'text-blue-800' : 'text-gray-800'}`}>
                                    Patient ID: {session.patientId}
                                </h3>
                                <p className={`text-xs ${session.isSelected ? 'text-blue-600' : 'text-gray-600'}`}>
                                    {session.date.split(' ')[0]} {session.date.split(' ')[1].slice(0, -1)}, {session.time}
                                </p>
                                <div className="flex justify-between items-center mt-1">
                                    <span className="text-xs bg-blue-100 text-blue-700 px-1 py-0.5 rounded">
                                        {session.ambulanceId}
                                    </span>
                                    <span className="text-xs text-green-700">
                                        {session.detectionCount} {session.detectionCount === 1 ? 'detection' : 'detections'}
                                    </span>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {sessions.length === 0 && (
                    <div className="py-8 text-center text-gray-500">
                        No sessions found matching your search.
                    </div>
                )}

                <div className="bg-gray-50 px-4 py-2 border-t border-gray-200">
                    <div className="text-xs text-gray-500 text-center">
                        Showing {sessions.length} session{sessions.length !== 1 ? 's' : ''}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default SessionGallery;