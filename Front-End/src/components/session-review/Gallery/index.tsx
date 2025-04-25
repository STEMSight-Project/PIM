'use client';

import React, { useState } from 'react';
import { Grid, List } from 'lucide-react';
import { SessionWithPatient } from "@/components/session-review/types";

interface ColorConfig {
  bg: string;
  dot: string;
  border: string;
}

interface ColorMap {
  [key: string]: ColorConfig;
}

interface SessionGalleryProps {
  sessions: SessionWithPatient[];
  onSessionSelect: (sessionId: string) => void;
  selectedSessionId: string;
}

const SessionGallery: React.FC<SessionGalleryProps> = ({
  sessions,
  onSessionSelect,
  selectedSessionId,
}) => {
  const [viewMode, setViewMode] = useState<'list' | 'grid'>('list');
  const [sortOption, setSortOption] = useState<string>('latest');

  const colorMap: ColorMap = {
    red: { bg: 'bg-red-100', dot: 'bg-red-500', border: 'border-red-500' },
    yellow: { bg: 'bg-yellow-100', dot: 'bg-yellow-500', border: 'border-yellow-500' },
    blue: { bg: 'bg-blue-100', dot: 'bg-blue-500', border: 'border-blue-500' },
    green: { bg: 'bg-green-100', dot: 'bg-green-500', border: 'border-green-500' },
    purple: { bg: 'bg-purple-100', dot: 'bg-purple-500', border: 'border-purple-500' },
    orange: { bg: 'bg-orange-100', dot: 'bg-orange-500', border: 'border-orange-500' }
  };

  const handleSortChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSortOption(e.target.value);
  };

  const sortedSessions = [...sessions].sort((a, b) => {
    const dateA = new Date(`${a.session.sessionDate} ${a.session.startTime}`);
    const dateB = new Date(`${b.session.sessionDate} ${b.session.startTime}`);

    switch (sortOption) {
      case 'latest':
        return dateB.getTime() - dateA.getTime();
      case 'oldest':
        return dateA.getTime() - dateB.getTime();
      case 'mostDetections':
        return b.detections.length - a.detections.length;
      default:
        return 0;
    }
  });

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden flex flex-col h-full">
      <div className="p-4 border-b border-gray-200">
        <h2 className="text-lg font-medium text-gray-800 mb-3">Session Gallery</h2>
      </div>

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

      <div className="flex-grow overflow-y-auto max-h-[500px]">
        {viewMode === 'list' ? (
          <div className="divide-y divide-gray-200">
            {sortedSessions.map(({ session, patient, detections }) => {
              const isSelected = session.id === selectedSessionId;

              return (
                <div
                  key={session.id}
                  className={`p-3 cursor-pointer ${isSelected ? 'bg-blue-50 border-l-4 border-blue-500' : 'hover:bg-gray-50'}`}
                  onClick={() => onSessionSelect(session.id)}
                >
                  <div className="flex justify-between">
                    <div>
                      <h3 className={`text-sm font-medium ${isSelected ? 'text-blue-800' : 'text-gray-800'}`}>
                        {patient?.first_name} {patient?.last_name}
                      </h3>
                      <p className={`text-xs ${isSelected ? 'text-blue-600' : 'text-gray-600'}`}>
                        {session.sessionDate} - {session.startTime}
                      </p>
                    </div>
                    <div className="flex items-start space-x-2">
                      <div className="flex -space-x-1">
                        {detections.slice(0, 4).map((detection, index) => (
                          <div
                            key={index}
                            className={`h-5 w-5 rounded-full ${colorMap[detection.color]?.bg || 'bg-gray-100'} flex items-center justify-center border border-white`}
                            title={detection.type}
                          >
                            <div className={`h-2 w-2 rounded-full ${colorMap[detection.color]?.dot || 'bg-gray-500'}`}></div>
                          </div>
                        ))}
                        {detections.length > 4 && (
                          <div className="h-5 w-5 rounded-full bg-gray-100 flex items-center justify-center border border-white text-xs text-gray-600">
                            +{detections.length - 4}
                          </div>
                        )}
                      </div>
                      <span className="text-xs bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                        {session.stationId}
                      </span>
                    </div>
                  </div>
                  <div className="mt-1 flex items-center justify-between">
                    <div className="flex items-center">
                      <div className={`h-2 w-2 rounded-full ${detections.length > 0 ? 'bg-green-500' : 'bg-gray-500'} mr-1`}></div>
                      <span className={`text-xs ${detections.length > 0 ? 'text-green-700' : 'text-gray-700'}`}>
                        {detections.length > 0 ? `${detections.length} detection${detections.length !== 1 ? 's' : ''}` : 'No detections'}
                      </span>
                    </div>
                    <button
                      className="text-xs text-blue-600 hover:text-blue-800"
                      onClick={(e) => {
                        e.stopPropagation();
                        onSessionSelect(session.id);
                      }}
                    >
                      View
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          // Grid view — you can update this loop too if needed
          <div className="grid grid-cols-2 gap-2 p-2">
            {sortedSessions.map(({ session, patient, detections }) => {
              const isSelected = session.id === selectedSessionId;
              return (
                <div
                  key={session.id}
                  className={`${isSelected ? 'bg-blue-50 border-2 border-blue-500' : 'bg-white border border-gray-200 hover:bg-gray-50'} rounded-lg p-2 cursor-pointer`}
                  onClick={() => onSessionSelect(session.id)}
                >
                  <div className="relative h-24 bg-gray-200 rounded mb-2 overflow-hidden">
                    <img src="https://i.gyazo.com/37a2c6d33fcb30e6e020d5b684b6adb9.jpg" alt="Thumbnail" className="object-cover w-full h-full" />
                    <div className="absolute top-1 right-1 flex -space-x-1">
                      {detections.slice(0, 3).map((detection, index) => (
                        <div
                          key={index}
                          className={`h-5 w-5 rounded-full ${colorMap[detection.color]?.bg || 'bg-gray-100'} flex items-center justify-center border border-white`}
                          title={detection.type}
                        >
                          <div className={`h-2 w-2 rounded-full ${colorMap[detection.color]?.dot || 'bg-gray-500'}`}></div>
                        </div>
                      ))}
                      {detections.length > 3 && (
                        <div className="h-5 w-5 rounded-full bg-gray-100 flex items-center justify-center border border-white text-xs text-gray-600">
                          +{detections.length - 3}
                        </div>
                      )}
                    </div>
                  </div>
                  <h3 className={`text-xs font-medium ${isSelected ? 'text-blue-800' : 'text-gray-800'}`}>
                    {patient?.first_name} {patient?.last_name}
                  </h3>
                  <p className={`text-xs ${isSelected ? 'text-blue-600' : 'text-gray-600'}`}>
                    {session.sessionDate}, {session.startTime}
                  </p>
                  <div className="flex justify-between items-center mt-1">
                    <span className="text-xs bg-blue-100 text-blue-700 px-1 py-0.5 rounded">
                      {session.stationId}
                    </span>
                    <span className="text-xs text-green-700">
                      {detections.length} {detections.length === 1 ? 'detection' : 'detections'}
                    </span>
                  </div>
                </div>
              );
            })}
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
