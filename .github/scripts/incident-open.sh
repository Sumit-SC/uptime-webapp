#!/usr/bin/env bash

set -e

source .github/scripts/metrics-helper.sh
source .github/scripts/rca-engine.sh

# ==========================================
# Parse issue title
# ==========================================

TITLE="$ISSUE_TITLE"

SITE=$(echo "$TITLE" \
  | sed -E 's/ is down.*//' \
  | xargs)

echo "Detected site: $SITE"

# ==========================================
# Fetch metrics
# ==========================================

SLUG=$(get_slug "$SITE")

LATENCY=$(get_latency "$SLUG")

UPTIME=$(get_uptime "$SITE")

INCIDENTS=$(get_incidents "$SLUG")

# ==========================================
# Generate RCA
# ==========================================

generate_rca "$SITE" "$LATENCY"

# ==========================================
# Build Telegram message
# ==========================================

MESSAGE="$SEVERITY INCIDENT DETECTED

🌐 Site: $SITE
📡 Status: DOWN
📈 Uptime: $UPTIME
⚡ Last Latency: $LATENCY ms
📉 Incident Count: $INCIDENTS

🛠 Probable Cause:
$RCA

🔍 Suggested Checks:
$CHECKS

⏳ ETA:
$ETA"

echo "$MESSAGE"

==========================================
TEMP DEBUG MODE
==========================================

Uncomment later:
bash .github/scripts/tg-send.sh "$MESSAGE"

Uncomment later:
bash .github/scripts/issue-comment.sh "$MESSAGE"

