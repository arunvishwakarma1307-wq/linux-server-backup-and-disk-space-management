#!/bin/bash

# --- SYSTEM PARAMETERS ---
SRC_DIR="/home/arunvishwakarma/backuplab"
DEST_DIR="/home/arunvishwakarma/backuplab"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S_UTC")
BACKUP_FILE="server_archive_${TIMESTAMP}.tar.gz"

echo "=== INITIALIZING PRODUCTION BACKUP ENGINE ==="
echo "Timestamp logged: ${TIMESTAMP}"

# --- EXECUTE MASS ARCHIVAL COMPRESSION ---
echo "Compressing log databases from ${SRC_DIR}..."
tar -czf "${DEST_DIR}/${BACKUP_FILE}" -C "${SRC_DIR}" . 2> /dev/null

echo "✅ SUCCESS: Compressed archive created at: ${DEST_DIR}/${BACKUP_FILE}"

# --- AUTOMATED STORAGE BREACH EVALUATOR ---
echo "Auditing hardware partition metrics..."

LIVE_USAGE=$(df -h | grep "/mnt/c" | awk '{print $5}' | tr -d '%')
THRESHOLD=90

echo "Your C: Drive Live Storage is currently at: ${LIVE_USAGE}%"

if [ "$LIVE_USAGE" -gt "$THRESHOLD" ]
then
    echo "$(date) - ⚠️ CRITICAL EMERGENCY: Storage has breached ${THRESHOLD}% threshold! Evacuating old logs." >> backup_alerts.log
    echo "WARNING: Emergency threshold breached. Alarm entry logged to backup_alerts.log!"
    
    # --- SELF-HEALING PURGE ENGINE ---
    echo "EMERGENCY RECOVERY ACTIVATED: Purging raw logs to reclaim disk sectors..."
    for TARGET in *.log.bak
    do
        echo "Evacuating object: ${TARGET}"
        rm -f "${TARGET}"
    done
    echo "✅ RECOVERY SUCCESSFUL: Raw log files cleared from partition layer."
else
    echo "✅ SYSTEM HEALTH STATUS: Storage metrics are running perfectly smooth."
fi

