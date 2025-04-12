export interface Note {
    id: string;
    content: string;
    created_time: string;
    videoTimeSeconds?: number;
    author: string;
    created_at: string;
}

export interface NotesProps {
    sessionId: string;
    setCurrentTimestamp: (time: number) => void;
    currentVideoTime: number;
}