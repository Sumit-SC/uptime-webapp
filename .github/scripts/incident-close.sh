#!/usr/bin/env bash

source .github/scripts/metrics-helper.sh
source .github/scripts/tg-send.sh
source .github/scripts/issue-comment.sh

TITLE="${GITHUB_EVENT_ISSUE_TITLE:-${{ github.event.issue.title }}}"

SITE=$(echo "$TITLE" \
  | sed -E 's/ is up.*//' \
  | xargs)

SLUG=$(get_slug "$SITE")

LATENCY=$(get_latency "$SLUG")

UPTIME=$(get_uptime "$SITE")

MTTR=$(get_mttr "$SLUG")

INCIDENTS=$(get_incidents "$SLUG")

RECOVERY_NOTE="Temporary instability resolved automatically."

if [ "$MTTR" -gt 3600 ]; then

  RECOVERY_NOTE="Extended outage recovered successfully.

Recommended:
• Verify application integrity
• Review provider analytics
• Continue latency monitoring"
fi

MESSAGE="🟢 INCIDENT RESOLVED

🌐 Site: $SITE
📡 Status: HEALTHY
📈 Uptime: $UPTIME
⚡ Current Latency: $LATENCY ms
📉 Incident Count: $INCIDENTS
📘 MTTR: $((MTTR / 60)) mins

🛠 Recovery Notes:
$RECOVERY_NOTE"

send_tg "$MESSAGE"

COMMENT="🤖 Automated Recovery Summary

MTTR:
$((MTTR / 60)) mins

Recovery Notes:
$RECOVERY_NOTE"

comment_issue "$COMMENT"
