#!/usr/bin/env bash

# how long to wait before considering transmission-remote hung (in seconds)
TIMEOUT=30

# transmission-remote host/port and credentials
HOST="localhost:9091"
AUTH="transmission:transmission"

# run transmission-remote under timeout, capture both stdout and stderr
OUTPUT=$(timeout "${TIMEOUT}" transmission-remote "${HOST}" -n "${AUTH}" -l 2>&1)
EXIT_CODE=$?

# Check for timeout (exit code 124) or the specific timeout message
if [[ $EXIT_CODE -ne 0 ]]; then
  if echo "${OUTPUT}" | grep -q "Timeout was reached"; then
    echo "$(date): transmission-remote timed out, restarting transmission-daemon" >&2
    sudo systemctl restart transmission-daemon
  else
    sudo systemctl restart transmission-daemon
    echo "$(date): transmission-remote failed with exit code ${EXIT_CODE}:" >&2
    echo "${OUTPUT}" >&2
  fi
else
  echo "${OUTPUT}"
  echo "$(date): transmission-remote succeeded"
fi