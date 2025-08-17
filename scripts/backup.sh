#!/bin/bash

# Database backup script
set -e

# Configuration
DB_HOST="db"
DB_NAME="dimensional_ai_prod"
DB_USER="ai_behar_user"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.sql"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo "Starting database backup..."

# Create database dump
pg_dump -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" > "${BACKUP_FILE}"

# Compress the backup
gzip "${BACKUP_FILE}"

echo "Backup completed: ${BACKUP_FILE}.gz"

# Clean up old backups (keep last 7 days)
find "${BACKUP_DIR}" -name "backup_*.sql.gz" -mtime +7 -delete

echo "Old backups cleaned up"
