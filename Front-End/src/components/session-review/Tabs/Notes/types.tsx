export interface NotesProps {
    sessionId: string;
    notes: import('@/services/noteService').Note[]; 
    setNotes: React.Dispatch<React.SetStateAction<import('@/services/noteService').Note[]>>;
    setCurrentTimestamp: (time: number) => void;
    currentVideoTime: number;
    videoId: string;
    patientId: string;
}