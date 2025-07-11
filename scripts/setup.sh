#!/bin/bash
set -euo pipefail

# Ensure we’re root
if [ "$EUID" -ne 0 ]; then
  echo "⛔  Please run as root (e.g. sudo $0)" >&2
  exit 1
fi

# Get the repo root (one level up from this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

mkdir -p "/etc/cron.d"
# Paths
CRON_FILE="/etc/cron.d/minarlos-server"
LOG_DIR="$REPO_DIR/scripts/logs"

GIT_PULL_SCRIPT="$SCRIPT_DIR/pull-and-restart.sh"
GIT_PULL_LOGS="$LOG_DIR/pull-and-restart.log"

UPDATE_DNS_SCRIPT="$SCRIPT_DIR/update-dns.sh"
UPDATE_DNS_LOGS="$LOG_DIR/update-dns.log"

CHECK_TRANSMISSION_SCRIPT="$SCRIPT_DIR/check-transmission-job.sh"
CHECK_TRANSMISSION_LOGS="$LOG_DIR/check-transmission-job.log"

# Make sure log folder exists
mkdir -p "$LOG_DIR"

# Create dynamic crontab
cat > "$CRON_FILE" <<EOF
* * * * * root $GIT_PULL_SCRIPT >> $GIT_PULL_LOGS 2>&1
* * * * * root $CHECK_TRANSMISSION_SCRIPT >> $CHECK_TRANSMISSION_LOGS 2>&1
*/5 * * * * root $UPDATE_DNS_SCRIPT >> $UPDATE_DNS_LOGS 2>&1
EOF

chown root:root "$CRON_FILE"
chmod 644 "$CRON_FILE"

echo "✅ Cron job installed for repo at $REPO_DIR"
