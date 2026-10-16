#!/bin/bash

# --- SYSTEM PARAMETERS ---
SRC_DIR="/home/arunvishwakarma/backuplab"
DEST_DIR="/home/arunvishwakarma/backups"
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S_UTC")
BACKUP_FILE="server_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${BACKUP_FILE}"
LOG_FILE="${SRC_DIR}/backup_alerts.log"
THRESHOLD=90

echo "=== BACKUP AND INTEGRITY VERIFICATION ==="
echo "Timestamp: ${TIMESTAMP}"

# --- VALIDATE SOURCE DIRECTORY ---
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Source directory does not exist: ${SRC_DIR}"
    exit 1
fi

# --- VALIDATE BACKUP DESTINATION ---
if ! mkdir -p "$DEST_DIR"; then
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - ERROR: Backup destination unavailable." >> "$LOG_FILE"
    echo "ERROR: Cannot create or access backup destination."
    exit 1
fi

# --- CREATE COMPRESSED BACKUP ---
echo "Creating archive from: ${SRC_DIR}"

if tar -czf "$ARCHIVE_PATH" -C "$SRC_DIR" .; then
    echo "Archive creation command completed."
else
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - ERROR: Backup archive creation failed." >> "$LOG_FILE"
    echo "ERROR: Archive creation failed. Cleanup cancelled."
    exit 1
fi

# --- VERIFY ARCHIVE INTEGRITY ---
echo "Verifying archive contents..."

if tar -tzf "$ARCHIVE_PATH" > /dev/null; then
    echo "SUCCESS: Archive created and integrity check passed."
    echo "Backup location: ${ARCHIVE_PATH}"
else
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - ERROR: Backup integrity check failed: ${BACKUP_FILE}" >> "$LOG_FILE"
    echo "ERROR: Archive integrity check failed. Cleanup cancelled."
    exit 1
fi

# --- CHECK ROOT FILESYSTEM USAGE ---
echo "Checking root filesystem usage..."

LIVE_USAGE=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d '%')

if ! [[ "$LIVE_USAGE" =~ ^[0-9]+$ ]]; then
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - ERROR: Could not determine filesystem usage." >> "$LOG_FILE"
    echo "ERROR: Disk usage could not be determined. Cleanup cancelled."
    exit 1
fi

echo "Root filesystem usage: ${LIVE_USAGE}%"

# --- SAFE STORAGE CLEANUP ---
if [ "$LIVE_USAGE" -gt "$THRESHOLD" ]; then
    echo "$(date -u +"%Y-%m-%d %H:%M:%S_UTC") - WARNING: Storage usage exceeded ${THRESHOLD}%." >> "$LOG_FILE"
    echo "WARNING: Threshold exceeded. Checking eligible old log backups."

    cd "$SRC_DIR" || exit 1

    for TARGET in *.log.bak; do
        if [ -f "$TARGET" ]; then
            echo "Removing eligible old log backup: ${TARGET}"
            rm -f -- "$TARGET"
        fi
    done

    echo "Cleanup routine completed."
else
    echo "SYSTEM HEALTH: Storage usage is below the threshold."
fi
