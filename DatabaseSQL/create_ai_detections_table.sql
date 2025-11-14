-- AI Detections Table for Live Streaming Movement Detection
-- This table stores real-time AI detection results from camera feeds during ambulance streaming sessions

CREATE TABLE IF NOT EXISTS public.ai_detections (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    session_id uuid NOT NULL,
    camera_id uuid NOT NULL,
    room_id character varying(100),
    detection_type character varying(50) NOT NULL,
    confidence_score numeric(5,4),
    detection_data jsonb NOT NULL,
    detected_patient_id character varying(100),
    patient_biometrics jsonb,
    frame_timestamp timestamp with time zone NOT NULL,
    sequence_number integer,
    model_used character varying(50),
    processing_time_ms integer,
    processed_on character varying(20) DEFAULT 'edge'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ai_detections_processed_on_check CHECK (((processed_on)::text = ANY ((ARRAY['edge'::character varying, 'cloud'::character varying])::text[])))
);

-- Add comments for documentation
COMMENT ON TABLE public.ai_detections IS 'AI detection results from camera feeds with patient identification';
COMMENT ON COLUMN public.ai_detections.session_id IS 'Reference to ambulance_streaming_sessions.id';
COMMENT ON COLUMN public.ai_detections.camera_id IS 'Reference to cameras.id';
COMMENT ON COLUMN public.ai_detections.room_id IS 'Room identifier string (e.g., AMB-001-ROOM-001)';
COMMENT ON COLUMN public.ai_detections.detection_type IS 'Type of movement detected (e.g., tremor, dystonia, normal)';
COMMENT ON COLUMN public.ai_detections.confidence_score IS 'AI confidence score (0.0000 to 1.0000)';
COMMENT ON COLUMN public.ai_detections.detection_data IS 'Additional detection metadata (all_probabilities, temperature, frame_count, etc.)';
COMMENT ON COLUMN public.ai_detections.detected_patient_id IS 'AI-generated patient identifier from lenses/facial recognition';
COMMENT ON COLUMN public.ai_detections.frame_timestamp IS 'Timestamp when detection occurred';
COMMENT ON COLUMN public.ai_detections.sequence_number IS 'Sequential number of detection within session';
COMMENT ON COLUMN public.ai_detections.model_used IS 'AI model identifier (e.g., PoseTCN-T2.00)';
COMMENT ON COLUMN public.ai_detections.processing_time_ms IS 'Time taken for inference in milliseconds';
COMMENT ON COLUMN public.ai_detections.processed_on IS 'Where processing occurred: edge (RPi/broadcaster) or cloud (backend)';

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_ai_detections_session_id ON public.ai_detections(session_id);
CREATE INDEX IF NOT EXISTS idx_ai_detections_camera_id ON public.ai_detections(camera_id);
CREATE INDEX IF NOT EXISTS idx_ai_detections_room_id ON public.ai_detections(room_id);
CREATE INDEX IF NOT EXISTS idx_ai_detections_detection_type ON public.ai_detections(detection_type);
CREATE INDEX IF NOT EXISTS idx_ai_detections_frame_timestamp ON public.ai_detections(frame_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_ai_detections_created_at ON public.ai_detections(created_at DESC);

-- Create composite index for common query patterns
CREATE INDEX IF NOT EXISTS idx_ai_detections_session_type_time ON public.ai_detections(session_id, detection_type, frame_timestamp DESC);

-- Optional: Add foreign key constraints (uncomment if referential integrity is needed)
-- ALTER TABLE public.ai_detections 
--     ADD CONSTRAINT fk_ai_detections_session 
--     FOREIGN KEY (session_id) 
--     REFERENCES public.ambulance_streaming_sessions(id) 
--     ON DELETE CASCADE;

-- ALTER TABLE public.ai_detections 
--     ADD CONSTRAINT fk_ai_detections_camera 
--     FOREIGN KEY (camera_id) 
--     REFERENCES public.cameras(id) 
--     ON DELETE CASCADE;

-- Enable Row Level Security (RLS) if needed
-- ALTER TABLE public.ai_detections ENABLE ROW LEVEL SECURITY;

-- Grant permissions (adjust based on your security requirements)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ai_detections TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ai_detections TO service_role;

-- Example query to verify table creation
-- SELECT table_name, column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'ai_detections'
-- ORDER BY ordinal_position;
