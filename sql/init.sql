-- Database initialization script for AI Behar Platform
-- This script sets up the initial database structure

-- Create database if not exists (handled by docker-compose)
-- CREATE DATABASE IF NOT EXISTS dimensional_ai_prod;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS ai_platform;
CREATE SCHEMA IF NOT EXISTS user_management;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Users table
CREATE TABLE IF NOT EXISTS user_management.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false
);

-- Conversations table
CREATE TABLE IF NOT EXISTS ai_platform.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_management.users(id) ON DELETE CASCADE,
    title VARCHAR(500),
    model_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE IF NOT EXISTS ai_platform.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES ai_platform.conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    model_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

-- Analytics table
CREATE TABLE IF NOT EXISTS analytics.usage_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_management.users(id) ON DELETE SET NULL,
    model_name VARCHAR(100) NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    tokens_used INTEGER DEFAULT 0,
    response_time_ms INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT true,
    error_message TEXT
);

-- API Keys table
CREATE TABLE IF NOT EXISTS user_management.api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_management.users(id) ON DELETE CASCADE,
    key_hash TEXT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON ai_platform.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON ai_platform.conversations(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON ai_platform.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON ai_platform.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_usage_stats_user_id ON analytics.usage_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_stats_created_at ON analytics.usage_stats(created_at);
CREATE INDEX IF NOT EXISTS idx_usage_stats_model_name ON analytics.usage_stats(model_name);
CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON user_management.api_keys(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON user_management.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON ai_platform.conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (password: admin123 - CHANGE THIS!)
INSERT INTO user_management.users (username, email, password_hash, is_admin)
VALUES (
    'admin',
    'admin@aibehar.com',
    crypt('admin123', gen_salt('bf', 8)),
    true
) ON CONFLICT (username) DO NOTHING;

-- Grant permissions
GRANT USAGE ON SCHEMA ai_platform TO ai_behar_user;
GRANT USAGE ON SCHEMA user_management TO ai_behar_user;
GRANT USAGE ON SCHEMA analytics TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ai_platform TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA user_management TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ai_platform TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA user_management TO ai_behar_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA analytics TO ai_behar_user;
