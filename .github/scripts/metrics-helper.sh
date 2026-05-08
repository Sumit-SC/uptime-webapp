#!/usr/bin/env bash

set -e

# ==========================================
# Shared observability helper functions
# ==========================================

DB="observability/incident-metrics.json"

# ==========================================
# Ensure DB exists
# ==========================================

mkdir -p observability

if [ ! -f "$DB" ]; then
  echo "{}" > "$DB"
fi

# ==========================================
# Get site slug
# ==========================================

get_slug() {

  local SITE="$1"

  jq -r \
    --arg site "$SITE" \
    '.[] | select(.name == $site) | .slug' \
    history/summary.json
}

# ==========================================
# Get latency
# ==========================================

get_latency() {

  local SLUG="$1"

  local FILE="history/$SLUG.yml"

  if [ -f "$FILE" ]; then

    LAT=$(grep 'responseTime:' "$FILE" | awk '{print $2}')

    if [ -n "$LAT" ]; then
      echo "$LAT"
    else
      echo "unknown"
    fi

  else
    echo "unknown"
  fi
}

# ==========================================
# Get uptime
# ==========================================

get_uptime() {

  local SITE="$1"

  UPTIME=$(jq -r \
    --arg site "$SITE" \
    '.[] | select(.name == $site) | .uptime' \
    history/summary.json)

  if [ -z "$UPTIME" ] || [ "$UPTIME" = "null" ]; then
    echo "Unknown"
  else
    echo "$UPTIME"
  fi
}

# ==========================================
# Get MTTR
# ==========================================

get_mttr() {

  local SLUG="$1"

  VALUE=$(jq -r \
    --arg slug "$SLUG" \
    '.[$slug].mttr // 0' \
    "$DB")

  echo "${VALUE:-0}"
}

# ==========================================
# Get incident count
# ==========================================

get_incidents() {

  local SLUG="$1"

  VALUE=$(jq -r \
    --arg slug "$SLUG" \
    '.[$slug].incidents // 0' \
    "$DB")

  echo "${VALUE:-0}"
}
