// This is for the header(title) of the session review page (video playback page) 
// under the navbar it displays the station and patient id and time and date of the session
'use client';

import React from 'react';
import { FileText } from 'lucide-react';

interface SessionHeaderProps {
  stationId: string;
  patientId: string;
  sessionDate: string;
  startTime: string;
  endTime: string;
}

const SessionHeader = ({ 
  stationId, 
  patientId, 
  sessionDate, 
  startTime, 
  endTime 
}: SessionHeaderProps) => {
  return (
    <div className="flex justify-between items-center mb-6 bg-gray-100 p-6 rounded-md">
      <div>
        <h1 className="text-2xl font-bold text-gray-800 mb-1"> Session Video Playback: </h1>
        <p className="text-gray-700">
          Station {stationId} | Patient ID {patientId} | {sessionDate}<br />
          {startTime} - {endTime}
        </p>
      </div>

      {/*  This button will trigger report generation.
           Still need to decide if it'll do so directly from this page (for printing/exporting) 
           or if it should go to another page for report customization first. 
      */}
      <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-3 rounded-md flex flex-col items-center justify-center">
        <FileText className="w-5 h-5 mb-1" />
        <span className="text-sm">Generate<br />Report</span>
      </button>
    </div>
  );
};

export default SessionHeader;