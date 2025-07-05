#!/bin/bash

# Get the repo root (one level up from this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Paths
CRON_FILE="$REPO_DIR/.generated_crontab"
LOG_DIR="$REPO_DIR/cronLogs"
GIT_PULL_SCRIPT="$SCRIPT_DIR/git-pull.sh"
LOG_FILE="$LOG_DIR/git-pull.log"

# Make sure log folder exists
mkdir -p "$LOG_DIR"

# Create dynamic crontab
cat > "$CRON_FILE" <<EOF
* * * * * $GIT_PULL_SCRIPT >> $LOG_FILE 2>&1
EOF

# Install the crontab
crontab "$CRON_FILE"

echo "✅ Cron job installed for repo at $REPO_DIR"
