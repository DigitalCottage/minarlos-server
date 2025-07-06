#!/usr/bin/env bash
set -euo pipefail

# ———————————————————————————————
# duckdns_update.sh
#
# Cron script to refresh your Duck DNS record.
# Requires a .env file with:
#   DOMAIN=<your-duckdns-subdomain>
#   DUCKDNS_TOKEN=<your-duckdns-token>
# ———————————————————————————————

# 1) cd to the script dir (where .env lives)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) load env vars
if [ -f ../.env ]; then
  # shellcheck disable=SC1091
  source ../.env
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: .env not found" >&2
  exit 1
fi

# 3) determine public IP
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PUBLIC_IP=$(curl -sf https://api.ipify.org) || {
  echo "[$TIMESTAMP] ERROR: failed to fetch public IP" >&2
  exit 1
}

# 4) call Duck DNS and output status
URL="https://www.duckdns.org/update?domains=${DOMAIN}&token=${DUCKDNS_TOKEN}&ip=${PUBLIC_IP}"
STATUS=$(curl -sf "${URL}" || echo "curl-failed")
echo "[${TIMESTAMP}] ${STATUS}"
