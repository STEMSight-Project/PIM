'use client';

import React, { useState } from 'react';
import { AlertCircle, CheckCircle, XCircle, Clock } from 'lucide-react';
import { timestampToSeconds } from './timestamp-to-seconds';

type ConfirmationStatus = 'pending' | 'confirmed' | 'dismissed';

type TimelineEvent = {
    id: string;
    type: 'detection' | 'system' | 'user';
    title: string;
    timestamp: string;
    confidence?: number;
    duration?: string;
    color: string;
    confirmationStatus: ConfirmationStatus;
};

interface TimelineProps {
    setCurrentTimestamp: (time: number) => void;
}

const Timeline = ({ setCurrentTimestamp }: TimelineProps) => {
    const [eventStatuses, setEventStatuses] = useState<Record<string, ConfirmationStatus>>({});

    // Mapping for color classes - each color goes with one of the postures/movements
    const getColorClass = (color: string) => {
        const colorMap: Record<string, string> = {
            'red': 'bg-red-500',
            'yellow': 'bg-yellow-500',
            'green': 'bg-green-500',
            'purple': 'bg-purple-500',
            'blue': 'bg-blue-500'
        };
        return colorMap[color] || 'bg-gray-500';
    };

    // handlers for the jump, confirm, and dismiss buttons
    const handleJumpToEvent = (timestamp: string) => {
        const seconds = timestampToSeconds(timestamp);
        console.log("Timeline: Jump to event clicked", timestamp, "converted to seconds:", seconds);

        setCurrentTimestamp(seconds - 0.5); // If we don't add this it wont let the user click on the timestamp twice in a row
        setTimeout(() => {
            setCurrentTimestamp(seconds);
        }, 10);
    };

    const handleConfirmEvent = (eventId: string) => {
        setEventStatuses(prevStatuses => ({
            ...prevStatuses,
            [eventId]: 'confirmed'
        }));
        console.log(`Event ${eventId} confirmed`);

    };

    const handleDismissEvent = (eventId: string) => {
        setEventStatuses(prevStatuses => ({
            ...prevStatuses,
            [eventId]: 'dismissed'
        }));
        console.log(`Event ${eventId} dismissed`);
    };

    const getEventStatus = (eventId: string): ConfirmationStatus => {
        return eventStatuses[eventId] || 'pending';
    };

    const events: TimelineEvent[] = [
        //timestamp format is mm:ss:ms
        {
            id: '1',
            type: 'detection',
            title: 'Possible Myoclonus',
            timestamp: '02:03:00', //(mm:ss:ms)
            confidence: 22,
            duration: '18 seconds',
            color: 'red',
            confirmationStatus: 'pending'
        },
        {
            id: '2',
            type: 'detection',
            title: 'Tremor Detected',
            timestamp: '04:01:02',
            confidence: 92,
            duration: '24 seconds',
            color: 'yellow',
            confirmationStatus: 'pending'
        },
        {
            id: '3',
            type: 'detection',
            title: 'Decerebrate Detected',
            timestamp: '05:01:42',
            confidence: 80,
            duration: '18 seconds',
            color: 'purple',
            confirmationStatus: 'pending'
        },
        {
            id: '4',
            type: 'detection',
            title: 'Decorticate Posture Detected',
            timestamp: '08:02:02',
            confidence: 77,
            duration: '21 seconds',
            color: 'blue',
            confirmationStatus: 'pending'
        }
    ];

    return (
        <div className="space-y-4">
            {events.map((event) => {
                const status = getEventStatus(event.id);

                return (
                    <div
                        key={event.id}
                        className="relative pl-8 pb-4 border-l-2 border-gray-200"
                    >
                        {/* Using the color mapping function for the dot */}
                        <div
                            className={`absolute top-0 left-0 w-4 h-4 -ml-2 rounded-full ${getColorClass(event.color)}`}
                        ></div>

                        <div className="flex justify-between items-start">
                            <div>
                                <p className="text-sm font-medium text-gray-900">{event.title}</p>
                                {event.confidence && (
                                    <p className="text-xs text-gray-500">{event.confidence}% confidence</p>
                                )}
                            </div>
                            <span className="text-xs text-gray-500">{event.timestamp}</span>
                        </div>

                        {event.duration && (
                            <p className="mt-1 text-sm text-gray-600">Duration: {event.duration}</p>
                        )}

                        {/* Conditionally render buttons based on status */}
                        {event.type === 'detection' && status === 'pending' && (
                            <div className="mt-2 flex space-x-2">
                                <button
                                    className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded hover:bg-blue-100 flex items-center"
                                    onClick={() => handleJumpToEvent(event.timestamp)}
                                >
                                    <Clock className="w-3 h-3 mr-1" />
                                    Jump to Event
                                </button>
                                <button
                                    className="px-2 py-1 bg-green-50 text-green-700 text-xs rounded hover:bg-green-100 flex items-center"
                                    onClick={() => handleConfirmEvent(event.id)}
                                >
                                    <CheckCircle className="w-3 h-3 mr-1" />
                                    Confirm
                                </button>

                                <button
                                    className="px-2 py-1 bg-red-50 text-red-700 text-xs rounded hover:bg-red-100 flex items-center"
                                    onClick={() => handleDismissEvent(event.id)}
                                >
                                    <XCircle className="w-3 h-3 mr-1" />
                                    Dismiss
                                </button>
                            </div>
                        )}

                        {/* For confirmed events */}
                        {status === 'confirmed' && (
                            <div className="mt-2 flex flex-wrap gap-2 items-center">
                                <div className="flex space-x-2">
                                    <button
                                        className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded hover:bg-blue-100 flex items-center"
                                        onClick={() => handleJumpToEvent(event.timestamp)}
                                    >
                                        <Clock className="w-3 h-3 mr-1" />
                                        Jump to Event
                                    </button>
                                    <button
                                        onClick={() => setEventStatuses(prevStatuses => ({ ...prevStatuses, [event.id]: 'pending' }))}
                                        className="px-2 py-1 bg-gray-50 text-gray-600 text-xs rounded hover:bg-gray-100"
                                    >
                                        Edit Status
                                    </button>
                                </div>
                                <div className="text-green-600 text-xs flex items-center">
                                    <CheckCircle className="w-3 h-3 mr-1" />
                                    Confirmed
                                </div>
                            </div>
                        )}

                        {/* For dismissed events */}
                        {status === 'dismissed' && (
                            <div className="mt-2 flex flex-wrap gap-2 items-center">
                                <div className="flex space-x-2">
                                    <button
                                        className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded hover:bg-blue-100 flex items-center"
                                        onClick={() => handleJumpToEvent(event.timestamp)}
                                    >
                                        <Clock className="w-3 h-3 mr-1" />
                                        Jump to Event
                                    </button>
                                    <button
                                        onClick={() => setEventStatuses(prevStatuses => ({ ...prevStatuses, [event.id]: 'pending' }))}
                                        className="px-2 py-1 bg-gray-50 text-gray-600 text-xs rounded hover:bg-gray-100"
                                    >
                                        Edit Status
                                    </button>
                                </div>
                                <div className="text-red-600 text-xs flex items-center">
                                    <XCircle className="w-3 h-3 mr-1" />
                                    Dismissed
                                </div>
                            </div>
                        )}
                    </div>
                );
            })}
        </div>
    );
};

export default Timeline;