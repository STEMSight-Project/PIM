-- Password Resets Table
-- Stores password reset tokens and their metadata
-- Run this in your Supabase SQL Editor to create the table

CREATE TABLE
IF NOT EXISTS password_resets
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid
(),
    user_id UUID NOT NULL,
    email VARCHAR
(255) NOT NULL,
    token VARCHAR
(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ DEFAULT NOW
(),
    updated_at TIMESTAMPTZ DEFAULT NOW
()
);

-- Create index on token for faster lookups
CREATE INDEX
IF NOT EXISTS idx_password_resets_token ON password_resets
(token);

-- Create index on user_id for faster lookups
CREATE INDEX
IF NOT EXISTS idx_password_resets_user_id ON password_resets
(user_id);

-- Create index on email for faster lookups
CREATE INDEX
IF NOT EXISTS idx_password_resets_email ON password_resets
(email);

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_password_resets_updated_at
()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW
();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER password_resets_updated_at
    BEFORE
UPDATE ON password_resets
    FOR EACH ROW
EXECUTE FUNCTION update_password_resets_updated_at
();

-- Add comment to table
COMMENT ON TABLE password_resets IS 'Stores password reset tokens and their status';

-- Cleanup function to remove expired tokens (optional, run periodically)
CREATE OR REPLACE FUNCTION cleanup_expired_password_resets
()
RETURNS void AS $$
BEGIN
    DELETE FROM password_resets
    WHERE expires_at < NOW() - INTERVAL
    '7 days';
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust role name as needed)
-- GRANT SELECT, INSERT, UPDATE ON password_resets TO authenticated;
