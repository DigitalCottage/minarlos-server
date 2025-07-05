#!/bin/bash

# Get absolute path to the repo (where this script lives)
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

CRON_FILE="$REPO_DIR/.generated_crontab"

# Create the crontab file dynamically
cat > "$CRON_FILE" <<EOF
* * * * * $REPO_DIR/scripts/git-pull.sh >> $REPO_DIR/cron_logs/git-pull.log 2>&1
EOF

# Create the log folder if needed
mkdir -p "$REPO_DIR/cron_logs"

# Install the new crontab
crontab "$CRON_FILE"

echo "✅ Cron job installed for repo at $REPO_DIR"
