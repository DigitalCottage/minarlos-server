#!/usr/bin/env bash
set -euo pipefail

# ———————————————————————————————
# update_and_restart.sh
#
# 1) cd into the script’s directory (your Git repo)
# 2) fetch latest remote commits
# 3) compare local HEAD vs. upstream
# 4) if they differ: pull & restart the Compose stack
# 5) otherwise: exit quietly
# ———————————————————————————————

# Step 1: change into the directory where this script lives
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 2: fetch the latest commits from origin
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Fetching remote changes..."
git fetch --quiet

# Step 3: compare local HEAD to upstream
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No updates available; exiting."
  exit 0
fi

# Step 4: there are new commits—pull and restart
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Updates found; pulling and restarting stack..."
git pull --ff-only

# If the stack is already running, restart; otherwise, just start it
if docker compose ps --filter "status=running" --quiet | grep -q .; then
  docker compose down
  docker compose up -d
else
  docker compose up -d
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Done."
