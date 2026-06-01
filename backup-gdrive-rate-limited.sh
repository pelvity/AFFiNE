#!/bin/bash
set -e

# Tarball + rclone backup script for AFFiNE with rate limiting for GDrive
BACKUP_DIR=/home/ubuntu/backups
DATE=$(date +%Y%m%d_%H%M)
BACKUP_FILE="affine_backup_${DATE}.tar.gz"
GDRIVE_REMOTE="tutoring-backup-gdrive:affine-backups"
LOG_FILE=/home/ubuntu/backup-gdrive.log

# Rate limiting configuration
RCLONE_TRANSFERS=1      # Single transfer to reduce API calls
RCLONE_CHECKERS=1       # Single checker
SLEEP_BETWEEN_OPS=5     # Seconds between operations

echo "[$(date)] Starting AFFiNE GDrive backup..." | tee -a $LOG_FILE

mkdir -p $BACKUP_DIR

# Step 1: Backup PostgreSQL database
echo "[$(date)] Backing up PostgreSQL..." | tee -a $LOG_FILE
docker exec affine_postgres_prod pg_dump -U affine affine | gzip > $BACKUP_DIR/affine_db.sql.gz
echo "[$(date)] PostgreSQL backup complete ($(du -h $BACKUP_DIR/affine_db.sql.gz | cut -f1))" | tee -a $LOG_FILE

sleep $SLEEP_BETWEEN_OPS

# Step 2: Create tarball of essential data
echo "[$(date)] Creating tarball..." | tee -a $LOG_FILE
tar -czf $BACKUP_DIR/$BACKUP_FILE \
  /home/ubuntu/.affine/prod/config \
  /home/ubuntu/.affine/prod/storage \
  /home/ubuntu/docker-compose.yml \
  $BACKUP_DIR/affine_db.sql.gz 2>/dev/null || true

TAR_SIZE=$(du -h $BACKUP_DIR/$BACKUP_FILE 2>/dev/null | cut -f1)
echo "[$(date)] Tarball created ($TAR_SIZE)" | tee -a $LOG_FILE

sleep $SLEEP_BETWEEN_OPS

# Step 3: Upload to GDrive with rate limiting
echo "[$(date)] Uploading to GDrive (rate limited)..." | tee -a $LOG_FILE

# Use rclone with limited transfers to avoid rate limits
rclone copy \
  --transfers $RCLONE_TRANSFERS \
  --checkers $RCLONE_CHECKERS \
  --tpslimit 1 \
  --tpslimit-burst 3 \
  --retries 3 \
  --retries-sleep 10s \
  $BACKUP_DIR/$BACKUP_FILE \
  $GDRIVE_REMOTE \
  2>&1 | tee -a $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "[$(date)] Upload successful" | tee -a $LOG_FILE
else
    echo "[$(date)] WARNING: Upload may have failed, check log" | tee -a $LOG_FILE
fi

sleep $SLEEP_BETWEEN_OPS

# Step 4: Retention policy (keep last 7 days) - with delay
echo "[$(date)] Applying retention policy (keeping 7 days)..." | tee -a $LOG_FILE
rclone delete \
  --tpslimit 1 \
  --transfers 1 \
  --min-age 7d \
  $GDRIVE_REMOTE \
  2>&1 | tee -a $LOG_FILE

sleep $SLEEP_BETWEEN_OPS

# Step 5: Cleanup local files
echo "[$(date)] Cleaning up local files..." | tee -a $LOG_FILE
rm -f $BACKUP_DIR/$BACKUP_FILE
rm -f $BACKUP_DIR/affine_db.sql.gz

echo "[$(date)] Backup cycle completed!" | tee -a $LOG_FILE
echo "---" | tee -a $LOG_FILE
