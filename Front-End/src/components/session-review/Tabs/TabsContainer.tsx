"use client";

import React, { useState } from "react";
import Timeline from "./Timeline";
import Notes from "./Notes";
import { Note } from "@/hooks";

type TabType = "timeline" | "notes";

interface TabsContainerProps {
  sessionId: string;
  notes: Note[];
  setNotes: React.Dispatch<React.SetStateAction<Note[]>>;
  setCurrentTimestamp: (time: number) => void;
  currentVideoTime: number;
  videoId: string;
  patientId: string;
}

const TabsContainer = ({
  sessionId,
  setCurrentTimestamp,
  currentVideoTime,
  notes,
  setNotes,
  videoId,
  patientId,
}: TabsContainerProps) => {
  const [currentTab, setCurrentTab] = useState<TabType>("timeline");

  return (
    <div className="bg-white rounded-lg shadow-lg">
      {/* Tab Navigation - Timeline and Notes */}
      <div className="p-4">
        <div className="flex bg-gray-50 rounded-lg p-1 mb-6">
          <button
            className={`flex-1 py-3 px-4 text-center text-sm font-medium transition-all duration-200 rounded-md ${
              currentTab === "timeline"
                ? "bg-white text-blue-600 shadow-sm ring-1 ring-gray-200"
                : "text-gray-600 hover:text-gray-900 hover:bg-white/50"
            }`}
            onClick={() => setCurrentTab("timeline")}
          >
            <div className="flex items-center justify-center">
              <svg
                className="w-4 h-4 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              Timeline
            </div>
          </button>

          <button
            className={`flex-1 py-3 px-4 text-center text-sm font-medium transition-all duration-200 rounded-md ${
              currentTab === "notes"
                ? "bg-white text-blue-600 shadow-sm ring-1 ring-gray-200"
                : "text-gray-600 hover:text-gray-900 hover:bg-white/50"
            }`}
            onClick={() => {
              setCurrentTab("notes");
              console.log("clicked on notes");
            }}
          >
            <div className="flex items-center justify-center">
              <svg
                className="w-4 h-4 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                />
              </svg>
              Notes ({notes.length})
            </div>
          </button>
        </div>
      </div>

      {/* Tab Content */}
      <div className="px-4 pb-4">
        <div className="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
          {currentTab === "timeline" && (
            <Timeline setCurrentTimestamp={setCurrentTimestamp} />
          )}
          {currentTab === "notes" && (
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
    </div>
  );
};

export default TabsContainer;
