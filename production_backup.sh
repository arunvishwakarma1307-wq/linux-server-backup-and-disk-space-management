#!/bin/bash

# --- SYSTEM PARAMETERS ---
SRC_DIR="/home/arunvishwakarma/backuplab"
DEST_DIR="/home/arunvishwakarma/backups"
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S_UTC")
BACKUP_FILE="server_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${BACKUP_FILE}"
LOG_FILE="${SRC_DIR}/backup_alerts.log"
THRESHOLD=90
RETENTION_COUNT=7

log_message() {
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - $1" >> "$LOG_FILE"
}

echo "=== BACKUP, INTEGRITY & RETENTION SYSTEM ==="
echo "Timestamp: ${TIMESTAMP}"

# --- VALIDATE SOURCE ---
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Source directory does not exist: ${SRC_DIR}"
    exit 1
fi

# --- VALIDATE DESTINATION ---
if ! mkdir -p "$DEST_DIR"; then
    log_message "ERROR: Backup destination unavailable."
    echo "ERROR: Cannot access backup destination."
    exit 1
fi

# Prevent accidental overwrite if a timestamp collision occurs.
if [ -e "$ARCHIVE_PATH" ]; then
    log_message "ERROR: Archive already exists: ${BACKUP_FILE}"
    echo "ERROR: Backup filename already exists. Aborting."
    exit 1
fi

# --- CREATE CLEAN COMPRESSED BACKUP ---
echo "Creating archive from: ${SRC_DIR}"
echo "Excluding .git, old .tar.gz archives and generated log files."

if tar -czf "$ARCHIVE_PATH" \
    --exclude='./.git' \
    --exclude='./.git/*' \
    --exclude='./*.tar.gz' \
    --exclude='./*.log' \
    --exclude='./*.log.bak' \
    -C "$SRC_DIR" .; then
    echo "Archive creation command completed."
else
    log_message "ERROR: Archive creation failed."
    rm -f -- "$ARCHIVE_PATH"
    echo "ERROR: Archive creation failed. Cleanup cancelled."
    exit 1
fi

# --- VERIFY ARCHIVE INTEGRITY ---
echo "Verifying archive contents..."

if tar -tzf "$ARCHIVE_PATH" > /dev/null; then
    echo "SUCCESS: Archive integrity check passed."
    echo "Backup location: ${ARCHIVE_PATH}"
else
    log_message "ERROR: Archive integrity verification failed: ${BACKUP_FILE}"
    rm -f -- "$ARCHIVE_PATH"
    echo "ERROR: Integrity check failed. Cleanup cancelled."
    exit 1
fi

# --- CHECK ROOT FILESYSTEM USAGE ---
echo "Checking root filesystem usage..."

LIVE_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if ! [[ "$LIVE_USAGE" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: Could not determine filesystem usage."
    echo "ERROR: Cannot determine disk usage. Cleanup cancelled."
    exit 1
fi

echo "Root filesystem usage: ${LIVE_USAGE}%"

# --- RETAIN THE 7 NEWEST VERIFIED BACKUP ARCHIVES ---
echo "Applying backup retention policy: keep ${RETENTION_COUNT} newest archives."

mapfile -t BACKUP_FILES < <(
    find "$DEST_DIR" -maxdepth 1 -type f \
        -name 'server_archive_*.tar.gz' \
        -printf '%T@\t%f\n' |
        sort -nr |
        cut -f2-
)

if [ "${#BACKUP_FILES[@]}" -gt "$RETENTION_COUNT" ]; then
    for OLD_BACKUP in "${BACKUP_FILES[@]:$RETENTION_COUNT}"; do
        if rm -f -- "${DEST_DIR}/${OLD_BACKUP}"; then
            echo "Removed expired backup: ${OLD_BACKUP}"
        else
            log_message "WARNING: Could not remove expired backup: ${OLD_BACKUP}"
            echo "WARNING: Could not remove ${OLD_BACKUP}"
        fi
    done
else
    echo "Retention check passed. Current archive count: ${#BACKUP_FILES[@]}"
fi

# --- EXISTING STORAGE THRESHOLD CLEANUP ---
if [ "$LIVE_USAGE" -gt "$THRESHOLD" ]; then
    log_message "WARNING: Root filesystem usage exceeded ${THRESHOLD}%."
    echo "WARNING: Storage threshold exceeded. Checking old .log.bak files."

    shopt -s nullglob
    for TARGET in "$SRC_DIR"/*.log.bak; do
        if [ -f "$TARGET" ]; then
            echo "Removing eligible old log backup: ${TARGET}"
            rm -f -- "$TARGET"
        fi
    done
    shopt -u nullglob

    echo "Storage cleanup routine completed."
else
    echo "SYSTEM HEALTH: Storage usage is below the threshold."
fi
