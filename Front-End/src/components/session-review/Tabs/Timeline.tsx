"use client";

import React, { useState } from "react";
import { CheckCircle, XCircle, Clock } from "lucide-react";
import { timestampToSeconds } from "./timestamp-to-seconds";

type ConfirmationStatus = "pending" | "confirmed" | "dismissed";

type TimelineEvent = {
  id: string;
  type: "detection" | "system" | "user";
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
  const [eventStatuses, setEventStatuses] = useState<
    Record<string, ConfirmationStatus>
  >({});

  // Mapping for color classes - each color goes with one of the postures/movements
  const getColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      red: "bg-red-500",
      yellow: "bg-yellow-500",
      green: "bg-green-500",
      purple: "bg-purple-500",
      blue: "bg-blue-500",
    };
    return colorMap[color] || "bg-gray-500";
  };

  // handlers for the jump, confirm, and dismiss buttons
  const handleJumpToEvent = (timestamp: string) => {
    const seconds = timestampToSeconds(timestamp);
    console.log(
      "Timeline: Jump to event clicked",
      timestamp,
      "converted to seconds:",
      seconds
    );

    setCurrentTimestamp(seconds - 0.5); // If we don't add this it wont let the user click on the timestamp twice in a row
    setTimeout(() => {
      setCurrentTimestamp(seconds);
    }, 10);
  };

  const handleConfirmEvent = (eventId: string) => {
    setEventStatuses((prevStatuses) => ({
      ...prevStatuses,
      [eventId]: "confirmed",
    }));
    console.log(`Event ${eventId} confirmed`);
  };

  const handleDismissEvent = (eventId: string) => {
    setEventStatuses((prevStatuses) => ({
      ...prevStatuses,
      [eventId]: "dismissed",
    }));
    console.log(`Event ${eventId} dismissed`);
  };

  const getEventStatus = (eventId: string): ConfirmationStatus => {
    return eventStatuses[eventId] || "pending";
  };

  const events: TimelineEvent[] = [
    //timestamp format is mm:ss:ms
    {
      id: "1",
      type: "detection",
      title: "Possible Myoclonus",
      timestamp: "02:03:00", //(mm:ss:ms)
      confidence: 22,
      duration: "18 seconds",
      color: "red",
      confirmationStatus: "pending",
    },
    {
      id: "2",
      type: "detection",
      title: "Tremor Detected",
      timestamp: "04:01:02",
      confidence: 92,
      duration: "24 seconds",
      color: "yellow",
      confirmationStatus: "pending",
    },
    {
      id: "3",
      type: "detection",
      title: "Decerebrate Detected",
      timestamp: "05:01:42",
      confidence: 80,
      duration: "18 seconds",
      color: "purple",
      confirmationStatus: "pending",
    },
    {
      id: "4",
      type: "detection",
      title: "Decorticate Posture Detected",
      timestamp: "08:02:02",
      confidence: 77,
      duration: "21 seconds",
      color: "blue",
      confirmationStatus: "pending",
    },
  ];

  return (
    <div className="space-y-6">
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          Activity Timeline
        </h3>
        <p className="text-sm text-gray-500">
          {events.length} {events.length === 1 ? "event" : "events"} detected
        </p>
      </div>

      <div className="space-y-6">
        {events.map((event) => {
          const status = getEventStatus(event.id);

          return (
            <div key={event.id} className="relative pl-8 pb-6 last:pb-0">
              {/* Timeline line */}
              <div className="absolute left-2 top-6 bottom-0 w-0.5 bg-gray-200 last:hidden"></div>

              {/* Event dot */}
              <div
                className={`absolute top-2 left-0 w-4 h-4 -ml-2 rounded-full border-2 border-white shadow-sm ${getColorClass(
                  event.color
                )}`}
              ></div>

              {/* Event card */}
              <div className="bg-white border border-gray-200 rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <h4 className="text-sm font-semibold text-gray-900 mb-1">
                      {event.title}
                    </h4>
                    {event.confidence && (
                      <div className="flex items-center">
                        <div className="w-2 h-2 bg-green-400 rounded-full mr-2"></div>
                        <span className="text-xs text-gray-600">
                          {event.confidence}% confidence
                        </span>
                      </div>
                    )}
                  </div>
                  <div className="text-right">
                    <span className="inline-flex items-center px-2 py-1 bg-gray-100 text-gray-700 text-xs font-medium rounded">
                      <Clock className="w-3 h-3 mr-1" />
                      {event.timestamp}
                    </span>
                    {event.duration && (
                      <div className="mt-1 text-xs text-gray-500">
                        Duration: {event.duration}
                      </div>
                    )}
                  </div>
                </div>

                {/* Conditionally render buttons based on status */}
                {event.type === "detection" && status === "pending" && (
                  <div className="mt-2 flex space-x-2">
                    <button
                      className="inline-flex items-center px-3 py-1.5 bg-blue-50 text-blue-700 text-xs font-medium rounded-md hover:bg-blue-100 transition-colors"
                      onClick={() => handleJumpToEvent(event.timestamp)}
                    >
                      <Clock className="w-3 h-3 mr-1" />
                      Jump to Event
                    </button>
                    <button
                      className="inline-flex items-center px-3 py-1.5 bg-green-50 text-green-700 text-xs font-medium rounded-md hover:bg-green-100 transition-colors"
                      onClick={() => handleConfirmEvent(event.id)}
                    >
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Confirm
                    </button>

                    <button
                      className="inline-flex items-center px-3 py-1.5 bg-red-50 text-red-700 text-xs font-medium rounded-md hover:bg-red-100 transition-colors"
                      onClick={() => handleDismissEvent(event.id)}
                    >
                      <XCircle className="w-3 h-3 mr-1" />
                      Dismiss
                    </button>
                  </div>
                )}

                {/* For confirmed events */}
                {status === "confirmed" && (
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
                        onClick={() =>
                          setEventStatuses((prevStatuses) => ({
                            ...prevStatuses,
                            [event.id]: "pending",
                          }))
                        }
                        className="px-2 py-1 bg-gray-50 text-gray-600 text-xs rounded hover:bg-gray-100"
                      >
                        Edit Status
                      </button>
                    </div>
                    <div className="inline-flex items-center px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded-md">
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Confirmed
                    </div>
                  </div>
                )}

                {/* For dismissed events */}
                {status === "dismissed" && (
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
                        onClick={() =>
                          setEventStatuses((prevStatuses) => ({
                            ...prevStatuses,
                            [event.id]: "pending",
                          }))
                        }
                        className="px-2 py-1 bg-gray-50 text-gray-600 text-xs rounded hover:bg-gray-100"
                      >
                        Edit Status
                      </button>
                    </div>
                    <div className="inline-flex items-center px-2 py-1 bg-red-100 text-red-800 text-xs font-medium rounded-md">
                      <XCircle className="w-3 h-3 mr-1" />
                      Dismissed
                    </div>
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default Timeline;
