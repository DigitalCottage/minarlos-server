#!/usr/bin/env bash
set -euo pipefail

# ———————————————————————————————
# update_and_restart.sh
#
# 1) cd into the script’s directory (your Git repo)
# 2) fetch & pull latest commits
# 3) load .env and, if SET_SERVER_DOWN=true, stop the server & exit
# 4) compare local HEAD vs. upstream (already pulled)
# 5) if updates were applied: restart the Compose stack
# 6) otherwise: exit quietly
# ———————————————————————————————

# Step 1: change into the directory where this script lives
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 2: fetch and pull the latest commits from origin
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Fetching remote changes..."
git fetch --quiet

# compare before pull so we know if there were updates
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Updates found; pulling..."
  git pull --ff-only
  PULLED=true
else
  PULLED=false
fi

# Step 3: load .env (if present) and check for SET_SERVER_DOWN
if [ -f ../.env ]; then
  # shellcheck disable=SC1091
  source ../.env
fi

if [ "${SET_SERVER_DOWN:-false}" = "true" ]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] SET_SERVER_DOWN=true; stopping server and exiting..."
  if docker compose ps --filter "status=running" --quiet | grep -q .; then
    docker compose down
  fi
  exit 0
fi

# If nothing was pulled, no need to restart
if [ "$PULLED" = "false" ]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] No updates applied; exiting."
  exit 0
fi

# Step 5: updates were applied—restart or start the stack
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Restarting stack..."
if docker compose ps --filter "status=running" --quiet | grep -q .; then
  docker compose down
  docker compose up -d
else
  docker compose up -d
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Done."
