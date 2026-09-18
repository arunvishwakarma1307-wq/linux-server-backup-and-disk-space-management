#!/bin/bash

# --- SYSTEM PARAMETERS (V2 ENTERPRISE) ---
SRC_DIR="/home/arunvishwakarma/backuplab"
DEST_DIR="/home/arunvishwakarma/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S_UTC")
BACKUP_FILE="server_archive_${TIMESTAMP}.tar.gz"
THRESHOLD=90

echo "=== INITIALIZING ENTERPRISE V2 BACKUP ENGINE ==="
echo "Timestamp logged: ${TIMESTAMP}"

# --- EXECUTE SECURE COMPRESSION ---
echo "Archiving log databases from ${SRC_DIR}..."
tar -czf "${DEST_DIR}/${BACKUP_FILE}" -C "${SRC_DIR}" . 2> /dev/null

# --- VALIDATE EXIT STATUS STATUS ($?) ---
if [ $? -eq 0 ]
then
    echo "✅ SUCCESS: Compressed archive verified and saved at: ${DEST_DIR}/${BACKUP_FILE}"
    
    # --- AUTOMATED STORAGE BREACH EVALUATOR ---
    echo "Auditing core filesystem partition metrics..."
    LIVE_USAGE=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d '%')
    echo "Your Linux Root Partition (/) Live Storage is currently at: ${LIVE_USAGE}%"
    
    if [ "$LIVE_USAGE" -gt "$THRESHOLD" ]
    then
        echo "$(date) - ⚠️ CRITICAL ALARM: Storage breached ${THRESHOLD}%! Clearing old log buffers." >> "${SRC_DIR}/backup_alerts.log"
        echo "WARNING: Emergency threshold crossed. Executing safe storage cleanup..."
        
        # --- SAFE PURGE LOOP ---
        cd "${SRC_DIR}"
        for TARGET in *.log.bak
        do
            if [ -f "$TARGET" ]
            then
                echo "Evacuating object: ${TARGET}"
                rm -f "${TARGET}"
            fi
        done
        echo "✅ RECOVERY COMPLETE: Filesystem metrics stabilized."
    else
        echo "✅ SYSTEM HEALTH STATUS: Storage metrics are running perfectly smooth."
    fi
else
    echo "❌ ERROR: Archival compression failed! Aborting storage reclamation routine to protect data integrity." >> "${SRC_DIR}/backup_alerts.log"
    echo "CRITICAL: Backup process collapsed. Cleanup safety locks engaged."
    exit 1
fi

