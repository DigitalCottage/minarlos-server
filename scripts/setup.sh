#!/bin/bash

# Get the repo root (one level up from this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Paths
CRON_FILE="$REPO_DIR/scripts/.generated_crontab"
LOG_DIR="$REPO_DIR/scripts/logs"

GIT_PULL_SCRIPT="$SCRIPT_DIR/pull-and-restart.sh"
GIT_PULL_LOGS="$LOG_DIR/pull-and-restart.log"

UPDATE_DNS_SCRIPT="$SCRIPT_DIR/update-dns.sh"
UPDATE_DNS_LOGS="$SCRIPT_DIR/update-dns.log"

# Make sure log folder exists
mkdir -p "$LOG_DIR"

# Create dynamic crontab
cat > "$CRON_FILE" <<EOF
* * * * * $GIT_PULL_SCRIPT >> $GIT_PULL_LOGS 2>&1
*/5 * * * * $UPDATE_DNS_SCRIPT >> $UPDATE_DNS_LOGS 2>&1
EOF

# Install the crontab
crontab "$CRON_FILE"

echo "✅ Cron job installed for repo at $REPO_DIR"
