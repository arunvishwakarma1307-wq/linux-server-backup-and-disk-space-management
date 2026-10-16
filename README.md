# Linux Server Backup & Disk Space Management System

A hands-on Linux System Administration project built using Bash scripting and Ubuntu Linux in WSL. The project creates timestamped compressed backups, verifies archive readability, checks root filesystem usage, excludes selected generated files, and applies a retention policy to matching backup archives.

## Project Overview

The goal of this project is to practise Linux backup administration, data integrity verification, disk space monitoring, error handling, and recovery testing through a practical Bash script.

The project is designed as a learning lab and is still under development.

## Technologies & Tools

- Ubuntu Linux
- Windows Subsystem for Linux (WSL)
- Bash / Shell Scripting
- `tar` and `gzip`
- Linux filesystem utilities
- Git and GitHub

## Features Implemented

### 1. Timestamped Compressed Backups

The `production_backup.sh` script creates compressed `.tar.gz` archives from the configured source directory.

Each archive receives a UTC-based timestamp in its filename, for example:

`server_archive_20261016_160451_UTC.tar.gz`

The backup destination is configured separately from the source directory so newly generated archives are stored outside the directory being archived.

### 2. Backup Creation Error Handling

The script checks whether the archive creation command succeeds. If archive creation fails, it records an error in `backup_alerts.log`, removes a partial archive at the target path, stops the workflow, and skips retention and storage cleanup.

### 3. Automatic Archive Integrity Verification

After archive creation, the script runs:

`tar -tzf "$ARCHIVE_PATH"`

This checks whether the compressed archive can be read and its contents listed successfully.

If the check fails, the script records an error, removes the failed archive, and stops before retention and storage cleanup.

Passing this test confirms that the archive is readable; it does not guarantee that every restored file will be correct or usable. Restore testing is therefore performed separately.

### 4. Root Filesystem Usage Monitoring

The script checks root filesystem usage with `df -P /` and compares the reported percentage with a configured threshold of 90%.

- At or below 90%: the script reports that storage usage is below the threshold.
- Above 90%: the script runs the configured cleanup routine for eligible `.log.bak` files in the source directory.

The root-usage check is separate from the backup retention policy.

### 5. Controlled Log Backup Cleanup

When root filesystem usage exceeds the configured threshold, the script checks for regular files matching `*.log.bak` in the source directory and removes matching files.

This cleanup routine runs only after successful archive creation and integrity verification. The high-disk-usage cleanup branch has not yet been tested using a simulated filesystem-usage result.

The `.log.bak` cleanup and the `.tar.gz` retention policy are separate operations.

### 6. Backup Restore Testing

A backup archive was extracted into a separate temporary directory to test recovery without overwriting the original project files.

The restore test confirmed:

- The archive could be extracted successfully.
- `production_backup.sh` was restored.
- `README.md` and `index.html` were restored.
- The restored `production_backup.sh` matched the source script used for the test.
- The restored script passed Bash syntax validation.

The restore test was performed manually in a temporary directory. Automatic restore is not part of the current script.

### 7. Backup Exclusions

New archives use `tar` exclude patterns for the following items in the configured source directory:

- The project `.git` directory
- Existing `.tar.gz` archive files
- Generated `.log` files
- `.log.bak` files

An archive-content check confirmed that the tested backup did not contain entries matching these configured patterns. Important project files including `production_backup.sh`, `README.md`, and `index.html` were present in that archive.

These exclusions reduce repeated backup data. The script still includes other source files and directories unless they match an exclusion pattern, so review the source directory before using this project to back up sensitive or production data.

### 8. Backup Retention Policy

After the newly created archive passes its integrity check, the script applies a retention policy to files matching `server_archive_*.tar.gz` in the configured backup destination.

- Retention limit: 7 newest matching archive files, based on file modification time.
- If the count exceeds seven, older matching archives are removed until seven remain.
- Only files matching the configured archive filename pattern in the backup destination are considered by this retention step.
- The retention step is reached after successful archive creation and integrity verification.

The retention deletion branch was tested in an isolated temporary environment. The test started with seven test archives, created a new verified archive using a copy of the script redirected to test-only paths, removed the oldest test archive, and confirmed that seven archives remained. The real `~/backups` archives were not used by this test.

This verifies the retention path in the isolated test environment; it does not mean every older existing archive has been individually integrity-checked by the script.

## Project Configuration

The current script uses these paths:

- Source directory: `/home/arunvishwakarma/backuplab`
- Backup destination: `/home/arunvishwakarma/backups`
- Alert log: `backup_alerts.log`
- Backup script: `production_backup.sh`

These absolute paths are configured for the current WSL environment. Update them before using the script under a different Linux username or directory structure.

The source directory is archived with the configured exclusion patterns. The backup destination is outside the source directory, which prevents the script's newly created destination archive from being included in the same run. Review all remaining source files before using the script for important or sensitive data.

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

The script creates an archive in the configured backup destination, checks archive readability, applies retention to matching backup files, and then checks root filesystem usage for the configured `.log.bak` cleanup routine.

## Manual Backup Verification

List the contents of a selected backup archive:

```bash
tar -tzf "$HOME/backups/server_archive_20261016_160451_UTC.tar.gz"
```

Replace the filename with the archive you want to test.

## Manual Restore Test

Create a separate temporary restore directory:

```bash
RESTORE_DIR=$(mktemp -d "$HOME/backup-restore-test.XXXXXX")
```

Extract a selected archive into that directory:

```bash
tar -xzf "$HOME/backups/server_archive_20261016_160451_UTC.tar.gz" -C "$RESTORE_DIR"
```

Verify the restored script syntax:

```bash
bash -n "$RESTORE_DIR/production_backup.sh"
```

Use an archive that you have verified and replace the example filename as needed. Restore into an isolated directory rather than overwriting original project files.

## Verified Test Results

The following checks were performed in the Ubuntu/WSL learning environment:

- `bash -n production_backup.sh` passed syntax validation.
- A timestamped compressed backup was created successfully.
- The archive integrity check passed using `tar -tzf`.
- Root filesystem usage was reported as 1%, below the configured 90% threshold during the recorded run.
- The new archive was checked for excluded `.git`, `.tar.gz`, `.log`, and `.log.bak` patterns; no matching entries were found.
- Important project files including `production_backup.sh`, `README.md`, and `index.html` were present in the tested archive.
- The archive was extracted into a separate temporary directory.
- The restored script matched the source script used for the test and passed Bash syntax validation.
- An isolated retention test confirmed that starting with seven test archives, creating a new archive, and applying retention resulted in seven remaining archives with the oldest test archive removed.

The seven-archive retention deletion path was tested only in an isolated temporary environment. The high-disk-usage `.log.bak` cleanup branch has not yet been simulated or verified.

## Current Limitations

The project is still under development.

Not yet implemented or not yet tested:

- Scheduled backups using cron or a systemd timer
- Backup encryption
- Cloud storage integration
- Automated restore verification as part of the backup script
- Checksums or cryptographic integrity manifests
- Email or external monitoring alerts
- Simulated verification of the high-disk-usage cleanup branch
- Automated checks of the integrity of every older archive before retention

## Future Improvements

Planned improvements may include:

- Configurable source and destination paths
- More granular backup exclusions for temporary or unnecessary files
- Scheduled execution using cron or a systemd timer
- Encrypted off-site or cloud backups
- Automated restore testing
- Checksums or cryptographic integrity manifests
- More robust logging and failure handling
- Disk usage alerts and backup status notifications
- Tests for failure cases and high-disk-usage cleanup

## Project Status

**Status: In Progress**

The project currently supports timestamped compressed backups, archive readability verification, selected file exclusions, retention of the seven newest matching backup archives, root filesystem usage checks, threshold-based cleanup of eligible `.log.bak` files, and manually tested restoration.

The archive-creation, integrity-check, exclusion, restore, and isolated retention flows have been tested. Scheduled execution, cloud storage, encryption, and the high-disk-usage cleanup branch remain future work or untested.

## Author

Arun Vishwakarma

GitHub: https://github.com/arunvishwakarma1307-wq
