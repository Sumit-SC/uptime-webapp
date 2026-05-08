#!/usr/bin/env bash

# ==========================================
# Shared Metrics Helper
# ==========================================

DB="observability/incident-metrics.json"

# ------------------------------------------
# Ensure DB exists
# ------------------------------------------

mkdir -p observability

[ ! -f "$DB" ] && echo "{}" > "$DB"

# ------------------------------------------
# Get slug from site
# ------------------------------------------

get_slug() {

  local SITE="$1"

  jq -r \
    --arg site "$SITE" \
    '.[] | select(.name == $site) | .slug' \
    history/summary.json
}

# ------------------------------------------
# Get latency
# ------------------------------------------

get_latency() {

  local SLUG="$1"

  local FILE="history/$SLUG.yml"

  if [ -f "$FILE" ]; then
    grep 'responseTime:' "$FILE" | awk '{print $2}'
  else
    echo "unknown"
  fi
}

# ------------------------------------------
# Get uptime %
# ------------------------------------------

get_uptime() {

  local SITE="$1"

  jq -r \
    --arg site "$SITE" \
    '.[] | select(.name == $site) | .uptime' \
    history/summary.json
}

# ------------------------------------------
# Calculate MTTR
# ------------------------------------------

get_mttr() {

  local SLUG="$1"

  jq -r \
    --arg slug "$SLUG" \
    '.[$slug].mttr // 0' \
    "$DB"
}

# ------------------------------------------
# Get incident count
# ------------------------------------------

get_incidents() {

  local SLUG="$1"

  jq -r \
    --arg slug "$SLUG" \
    '.[$slug].incidents // 0' \
    "$DB"
}
