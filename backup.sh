#!/bin/bash
set -e

# Configuration
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M)
BACKUP_FILE="${POSTGRES_DB}_${DATE}.sql.gz"
RETENTION_DAYS=30

echo "[$(date)] Starting backup process for database: $POSTGRES_DB"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# 1. Create Dump
# We use PGPASSWORD env var passed to container implicitly or explicitly, 
# but for .pgpass to work we might need to set it. 
# Docker compose 'postgres' service sets POSTGRES_PASSWORD, so we can use that.
# We need to export it for pg_dump
export PGPASSWORD=$POSTGRES_PASSWORD

echo "[$(date)] Dumping database..."
pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_DIR/$BACKUP_FILE"

if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "[$(date)] Backup created: $BACKUP_FILE"
    
    # 2. Upload to GDrive
    echo "[$(date)] Uploading to Google Drive remote: $RCLONE_REMOTE"
    if rclone copy "$BACKUP_DIR/$BACKUP_FILE" "$RCLONE_REMOTE"; then
        echo "[$(date)] Upload successful."
    else
        echo "[$(date)] Upload FAILED." >&2
        exit 1
    fi
else
    echo "[$(date)] Dump failed, file not found." >&2
    exit 1
fi

# 3. Cleanup
echo "[$(date)] Cleaning up old backups (Retention: $RETENTION_DAYS days)..."
# Local cleanup
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Remote cleanup
rclone delete "$RCLONE_REMOTE" --min-age "${RETENTION_DAYS}d"

echo "[$(date)] Backup process completed successfully."
