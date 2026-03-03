#!/bin/bash
set -e

# Configure file names
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M)
DB_BACKUP_FILE="affine_db_${DATE}.sql.gz"
FILES_BACKUP_FILE="affine_files_${DATE}.tar.gz"
RETENTION_DAYS=30

echo "[$(date)] Starting comprehensive backup process..."

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# 1. Create DB Dump
export PGPASSWORD=$POSTGRES_PASSWORD
echo "[$(date)] Dumping database: $POSTGRES_DB..."
if ! pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_DIR/$DB_BACKUP_FILE"; then
    echo "[$(date)] Database dump FAILED." >&2
    [ -n "$HEALTHCHECKS_URL" ] && curl -fsS -m 10 --retry 5 -o /dev/null "$HEALTHCHECKS_URL/fail"
    exit 1
fi

# 2. Archive Files (Storage & Config)
echo "[$(date)] Archiving AFFiNE storage and config files..."
if ! tar -czf "$BACKUP_DIR/$FILES_BACKUP_FILE" -C /root/.affine storage config 2>/dev/null; then
    echo "[$(date)] WARNING: File archiving encountered an issue (some files may be missing or locked), but continuing." >&2
fi

# 3. Upload to Google Drive
echo "[$(date)] Uploading backups to Google Drive remote: $RCLONE_REMOTE"
UPLOAD_SUCCESS=true

if ! rclone copy "$BACKUP_DIR/$DB_BACKUP_FILE" "$RCLONE_REMOTE"; then
    echo "[$(date)] Database upload FAILED." >&2
    UPLOAD_SUCCESS=false
fi

if ! rclone copy "$BACKUP_DIR/$FILES_BACKUP_FILE" "$RCLONE_REMOTE"; then
    echo "[$(date)] Files upload FAILED." >&2
    UPLOAD_SUCCESS=false
fi

if [ "$UPLOAD_SUCCESS" = false ]; then
    echo "[$(date)] Upload process encountered fatal errors." >&2
    [ -n "$HEALTHCHECKS_URL" ] && curl -fsS -m 10 --retry 5 -o /dev/null "$HEALTHCHECKS_URL/fail"
    exit 1
fi
echo "[$(date)] Upload successful."

# 4. Cleanup
echo "[$(date)] Cleaning up old backups (Retention: $RETENTION_DAYS days)..."
# Local cleanup
find "$BACKUP_DIR" -type f -name "*.gz" -mtime +$RETENTION_DAYS -delete

# Remote cleanup (rclone)
rclone delete "$RCLONE_REMOTE" --min-age "${RETENTION_DAYS}d"

# 5. Success Ping
echo "[$(date)] Comprehensive backup process completed successfully."
[ -n "$HEALTHCHECKS_URL" ] && curl -fsS -m 10 --retry 5 -o /dev/null "$HEALTHCHECKS_URL"

exit 0
