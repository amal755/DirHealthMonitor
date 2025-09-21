#!/bin/bash

# ==============================
# DirHealthMonitor - Daily Directory Health & Inode Check
# Author: Amal
# Date: 2025-08-19
# ==============================

# Directory to store logs
LOGDIR="/home/amal/forpro/logs"
mkdir -p "$LOGDIR"   # Ensure the folder exists

# Daily log file (new file created every day with date in name)
LOGFILE="$LOGDIR/dirhealth_$(date +%F).log"

# Directories to monitor
DIRS="/var/log /tmp /home"

# Thresholds
SIZE_THRESHOLD_MB=2000   # Max allowed size per directory
INODE_THRESHOLD=80       # Max inode usage in %

# Start log with timestamp
echo "========== Scan started at $(date) ==========" >> "$LOGFILE"

# Loop through directories
for dir in $DIRS; do
    # Calculate size in MB and suppress permission errors
    size=$(/usr/bin/du -sm "$dir" 2>/dev/null | /usr/bin/cut -f1)

    if [ -z "$size" ]; then
        echo "Warning: Cannot read $dir (permission denied)" >> "$LOGFILE"
        continue
    fi

    # Check if directory exceeds size threshold
    if [ "$size" -gt "$SIZE_THRESHOLD_MB" ]; then
        echo "Warning: $dir is $size MB (bigger than $SIZE_THRESHOLD_MB MB)" >> "$LOGFILE"

        # Desktop notification
        notify-send "DirHealthMonitor Alert" "$dir size is $size MB (threshold $SIZE_THRESHOLD_MB MB)"

        # Auto-clean only for /var/log (delete .log files older than 7 days)
        if [ "$dir" == "/var/log" ]; then
            echo "Action: Cleaning old log files in $dir (older than 7 days)" >> "$LOGFILE"
            /usr/bin/find "$dir" -type f -name "*.log" -mtime +7 -delete
        fi
    else
        echo "OK: $dir is $size MB" >> "$LOGFILE"
    fi

    # ----------------------
    # Inode usage check
    # ----------------------
    inodes=$(df -i "$dir" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$inodes" -gt "$INODE_THRESHOLD" ]; then
        echo "Warning: $dir inode usage is ${inodes}% (above ${INODE_THRESHOLD}%)" >> "$LOGFILE"
        notify-send "DirHealthMonitor Alert" "$dir inode usage ${inodes}% (threshold ${INODE_THRESHOLD}%)"
    else
        echo "OK: $dir inode usage is ${inodes}%" >> "$LOGFILE"
    fi
done

# Rotate DirHealth logs (delete monitor logs older than 14 days)
echo "Action: Rotating old DirHealth logs" >> "$LOGFILE"
/usr/bin/find "$LOGDIR" -type f -name "dirhealth_*.log" -mtime +14 -delete 2>/dev/null

# End log with timestamp
echo "========== Scan finished at $(date) ==========" >> "$LOGFILE"
echo "" >> "$LOGFILE"   
# Update symlink to always point to today's log
ln -sf "$LOGFILE" "$LOGDIR/dirhealth.log"

