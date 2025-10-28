"use client";

import React, { useEffect, useState } from "react";
import { Detection } from "@/components/session-review/types";
import { usePatientEvents } from "@/hooks/usePatientEvents";
import { CheckCircle, Clock, XCircle } from "lucide-react";

interface TimelineProps {
  setCurrentTimestamp: (time: number) => void;
  videoId: string;
  patientId: string;
  currentEvents?: Detection[]; // Use Detection type from session-review
}

const Timeline = ({
  setCurrentTimestamp,
  videoId,
  currentEvents,
}: TimelineProps) => {
  const {
    events: hookEvents,
    loading,
    error,
    fetchEventsForVideo,
    updateEventStatus,
    clearError,
  } = usePatientEvents();

  // Always use hookEvents if we're fetching, otherwise use currentEvents
  const [shouldUseFetchedEvents, setShouldUseFetchedEvents] = useState(false);
  const events = shouldUseFetchedEvents ? hookEvents : currentEvents || [];

  useEffect(() => {
    if (videoId && !currentEvents) {
      fetchEventsForVideo(videoId);
      setShouldUseFetchedEvents(true);
    }
  }, [videoId, fetchEventsForVideo, currentEvents]);

  // If we have currentEvents but need to update them, fetch fresh data
  useEffect(() => {
    if (currentEvents && shouldUseFetchedEvents) {
      fetchEventsForVideo(videoId);
    }
  }, [shouldUseFetchedEvents, videoId, fetchEventsForVideo, currentEvents]);

  // Convert timestamp to number if it's a string, then to MM:SS format for display
  const getTimestampAsNumber = (timestamp: string | number): number => {
    if (typeof timestamp === "string") {
      return parseFloat(timestamp) || 0;
    }
    return timestamp;
  };

  const formatTimestamp = (timestamp: string | number): string => {
    const seconds = getTimestampAsNumber(timestamp);
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes.toString().padStart(2, "0")}:${remainingSeconds
      .toString()
      .padStart(2, "0")}`;
  };

  // Mapping for detection types to colors
  const getEventColor = (type: string): string => {
    const typeColorMap: Record<string, string> = {
      myoclonus: "red",
      tremor: "yellow",
      decerebrate: "purple",
      decorticate: "blue",
      seizure: "red",
      abnormal_movement: "orange",
      // Add more mappings as needed
    };
    return typeColorMap[type.toLowerCase()] || "gray";
  };

  const getColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      red: "bg-red-500",
      yellow: "bg-yellow-500",
      green: "bg-green-500",
      purple: "bg-purple-500",
      blue: "bg-blue-500",
      orange: "bg-orange-500",
      gray: "bg-gray-500",
    };
    return colorMap[color] || "bg-gray-500";
  };

  const handleJumpToEvent = (timestamp: string | number) => {
    const seconds = getTimestampAsNumber(timestamp);
    console.log("Timeline: Jump to event clicked", seconds, "seconds");

    // Small trick to allow clicking the same timestamp multiple times
    setCurrentTimestamp(seconds - 0.5);
    setTimeout(() => {
      setCurrentTimestamp(seconds);
    }, 10);
  };

  const handleConfirmEvent = async (eventId: string) => {
    const result = await updateEventStatus(eventId, "confirmed");
    if (result) {
      console.log(`Event ${eventId} confirmed`);
      // If using currentEvents, switch to fetched events to see updates
      if (currentEvents) {
        setShouldUseFetchedEvents(true);
        fetchEventsForVideo(videoId);
      }
    }
  };

  const handleDismissEvent = async (eventId: string) => {
    const result = await updateEventStatus(eventId, "dismissed");
    if (result) {
      console.log(`Event ${eventId} dismissed`);
      // If using currentEvents, switch to fetched events to see updates
      if (currentEvents) {
        setShouldUseFetchedEvents(true);
        fetchEventsForVideo(videoId);
      }
    }
  };

  const handleEditStatus = async (eventId: string) => {
    const result = await updateEventStatus(eventId, "pending");
    if (result) {
      console.log(`Event ${eventId} status reset to pending`);
      // If using currentEvents, switch to fetched events to see updates
      if (currentEvents) {
        setShouldUseFetchedEvents(true);
        fetchEventsForVideo(videoId);
      }
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Activity Timeline
          </h3>
          <p className="text-sm text-gray-500">Loading events...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Activity Timeline
          </h3>
          <div className="text-red-600 text-sm">
            Error loading events: {error}
            <button
              onClick={clearError}
              className="ml-2 text-blue-600 hover:text-blue-800"
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (events.length === 0) {
    return (
      <div className="space-y-6">
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Activity Timeline
          </h3>
          <p className="text-sm text-gray-500">
            No events detected for this video
          </p>
        </div>
      </div>
    );
  }

  // Sort events by timestamp
  const sortedEvents = [...events].sort((a, b) => {
    const timestampA = getTimestampAsNumber(a.timestamp);
    const timestampB = getTimestampAsNumber(b.timestamp);
    return timestampA - timestampB;
  });

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
        {sortedEvents.map((event) => {
          const color = getEventColor(event.type);
          const status = event.validation_status;

          return (
            <div key={event.id} className="relative pl-8 pb-6 last:pb-0">
              {/* Timeline line */}
              <div className="absolute left-2 top-6 bottom-0 w-0.5 bg-gray-200 last:hidden"></div>

              {/* Event dot */}
              <div
                className={`absolute top-2 left-0 w-4 h-4 -ml-2 rounded-full border-2 border-white shadow-sm ${getColorClass(
                  color
                )}`}
              ></div>

              {/* Event card */}
              <div className="bg-white border border-gray-200 rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <h4 className="text-sm font-semibold text-gray-900 mb-1">
                      {event.type.charAt(0).toUpperCase() +
                        event.type.slice(1).replace("_", " ")}{" "}
                      Detected
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
                      {formatTimestamp(event.timestamp)}
                    </span>
                    <div className="mt-1 text-xs text-gray-500">
                      Created: {new Date(event.created_at).toLocaleDateString()}
                    </div>
                  </div>
                </div>

                {/* Buttons based on status */}
                {status === "pending" && (
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
                        onClick={() => handleEditStatus(event.id)}
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
                        onClick={() => handleEditStatus(event.id)}
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
