#!/bin/bash
# Database initialization script for AI Behar Platform

echo "🔧 Initializing AI Behar Platform databases..."

# Create directories
mkdir -p /app/databases/runtime
mkdir -p /app/logs

# Set environment variables if not set
export DATABASE_URL=${DATABASE_URL:-"sqlite:///app/databases/platform.db"}
export REDIS_URL=${REDIS_URL:-"redis://localhost:6379"}

echo "📊 Database URL: $DATABASE_URL"
echo "🔄 Redis URL: $REDIS_URL"

# Wait for PostgreSQL if using it
if [[ $DATABASE_URL == *"postgresql"* ]]; then
    echo "⏳ Waiting for PostgreSQL..."
    until pg_isready -h $(echo $DATABASE_URL | sed 's/.*@\([^:]*\).*/\1/') 2>/dev/null; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 2
    done
    echo "✅ PostgreSQL is ready!"
fi

# Wait for Redis if configured
if [[ $REDIS_URL != *"localhost"* ]]; then
    echo "⏳ Waiting for Redis..."
    until redis-cli -u $REDIS_URL ping 2>/dev/null; do
        echo "Redis is unavailable - sleeping"
        sleep 2
    done
    echo "✅ Redis is ready!"
fi

# Run database migrations if alembic is available
if command -v alembic &> /dev/null; then
    echo "🔄 Running database migrations..."
    alembic upgrade head || echo "⚠️ Migrations failed or not configured"
fi

# Create default SQLite database if using SQLite
if [[ $DATABASE_URL == *"sqlite"* ]]; then
    echo "📝 Setting up SQLite database..."
    python -c "
import sqlite3
import os

db_path = '$DATABASE_URL'.replace('sqlite:///', '')
os.makedirs(os.path.dirname(db_path), exist_ok=True)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Create basic tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    title TEXT,
    model_name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations (id)
)
''')

conn.commit()
conn.close()
print('✅ SQLite database initialized!')
" || echo "⚠️ SQLite initialization failed"
fi

echo "✅ Database initialization complete!"
