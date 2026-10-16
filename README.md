
# Linux Server Backup & Disk Space Management System

A hands-on Linux System Administration project built using Bash scripting and Ubuntu Linux in WSL. The project automates compressed backups, verifies archive integrity, checks root filesystem usage, and performs a controlled cleanup of eligible old log backup files.

## Project Overview

The goal of this project is to practise Linux backup administration, data integrity verification, disk space monitoring, error handling, and recovery testing through a practical Bash script.

The project is designed as a learning lab and is still under development.

## Technologies & Tools

- Ubuntu Linux
- Windows Subsystem for Linux (WSL)
- Bash / Shell Scripting
- tar and gzip
- Linux filesystem utilities
- Git and GitHub

## Features Implemented

### 1. Timestamped Compressed Backups

The `production_backup.sh` script creates compressed `.tar.gz` archives from the configured source directory.

Each archive receives a UTC-based timestamp in its filename, for example:

`server_archive_20261016_155215_UTC.tar.gz`

The backup destination is configured separately from the source directory to avoid placing newly generated archives inside the directory being archived.

### 2. Backup Creation Error Handling

The script checks whether the archive creation command succeeds. If archive creation fails, it records an error in `backup_alerts.log`, stops the backup workflow, and skips the cleanup routine.

### 3. Automatic Archive Integrity Verification

After archive creation, the script uses:

`tar -tzf`

to test whether the compressed archive can be read and its contents listed successfully.

If this check fails, the script records an error and stops before performing storage cleanup.

Passing this test confirms that the archive is readable; it does not guarantee that every restored file will be correct or usable.

### 4. Root Filesystem Usage Monitoring

The script checks root filesystem usage using Linux disk-usage utilities.

The configured threshold is 90%.

- Below or at 90%: the script reports that storage usage is below the threshold.
- Above 90%: the script enters the configured cleanup routine.

### 5. Controlled Log Backup Cleanup

When root filesystem usage exceeds the configured threshold, the script checks for files matching `*.log.bak` in the source directory and removes matching regular files.

The cleanup routine runs only after successful archive creation and integrity verification.

**Important:** This cleanup does not delete old `.tar.gz` backup archives. Automatic archive retention and deletion have not yet been implemented.

### 6. Backup Restore Testing

A backup archive was tested separately from the backup script by extracting its contents into a temporary directory.

The restore test confirmed:

- The archive could be extracted successfully.
- `production_backup.sh` was restored.
- `index.html` was restored.
- The restored script matched the upgraded source script.
- The restored script passed Bash syntax validation.

The restore test was performed manually in a separate temporary directory. Automatic restore is not part of the current script.

## Project Configuration

The current script uses these paths:

- Source directory: `/home/arunvishwakarma/backuplab`
- Backup destination: `/home/arunvishwakarma/backups`
- Alert log: `backup_alerts.log`
- Backup script: `production_backup.sh`

These absolute paths are configured for the current WSL environment. Update them before using the script under a different Linux username or directory structure.

The current script archives the contents of the entire source directory, including hidden files. This can include `.git`, logs, test scripts, and existing files that may not be required in a backup. Exclusions and sensitive-data handling should be reviewed before using this script for important data.

## How to Run

Navigate to the project directory:

```bash
cd ~/backuplab
```

Check the Bash syntax:

```bash
bash -n production_backup.sh
```

Run the backup:

```bash
bash production_backup.sh
```

The script creates an archive in the configured backup destination and checks its readability before continuing to the disk usage logic.

## Manual Backup Verification

To list the contents of a selected backup archive:

```bash
tar -tzf "$HOME/backups/server_archive_20261016_155215_UTC.tar.gz"
```

Replace the filename with the archive you want to test.

## Manual Restore Test

Create a separate temporary restore directory:

```bash
RESTORE_DIR=$(mktemp -d "$HOME/backup-restore-test.XXXXXX")
```

Extract a selected archive into that directory:

```bash
tar -xzf "$HOME/backups/server_archive_20261016_155215_UTC.tar.gz" -C "$RESTORE_DIR"
```

Verify the restored script syntax:

```bash
bash -n "$RESTORE_DIR/production_backup.sh"
```

Use a backup you have verified and replace the example archive filename as needed. Restore into an isolated directory rather than overwriting your original project files.

## Verified Test Results

The following checks were performed in the Ubuntu/WSL environment:

- Bash syntax validation passed for `production_backup.sh`.
- A backup archive was created successfully.
- The archive integrity check passed.
- Root filesystem usage was reported as 1%, below the configured 90% threshold.
- The new archive was extracted into a separate temporary directory.
- The restored script matched the upgraded source script.
- Bash syntax validation passed for the restored script.

These results describe the tests actually performed. They do not demonstrate scheduled execution, cloud backups, encryption, or automated recovery.

## Current Limitations

The project is still under development.

Not yet implemented:

- Scheduled backups using cron or a systemd timer
- Backup encryption
- Cloud storage integration
- Automatic retention and deletion of old backup archives
- Automated restore verification
- Backup exclusions for unnecessary files and directories
- Checksums or cryptographic integrity manifests
- Email or external monitoring alerts

## Future Improvements

Planned improvements may include:

- Configurable backup retention policy
- Backup exclusions for `.git`, temporary files, and generated archives
- Automated scheduled execution
- Encrypted off-site or cloud backups
- Recovery testing and integrity reporting
- More robust logging and failure handling
- Disk usage alerts and backup status notifications

## Project Status

**Status: In Progress**

The project currently supports timestamped compressed backups, archive readability verification, root filesystem usage checks, threshold-based cleanup of eligible `.log.bak` files, and manually tested restoration.

Further improvements will be implemented and tested incrementally.

## Author

Arun Vishwakarma

GitHub: https://github.com/arunvishwakarma1307-wq
