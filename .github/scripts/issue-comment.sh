#!/usr/bin/env bash

set -e

COMMENT="$1"

echo "=================================="
echo "💬 GitHub Issue Enrichment Engine"
echo "=================================="

# ==========================================
# Export authentication token
# ==========================================

export GH_TOKEN="$GH_TOKEN"

# ==========================================
# Initial sync wait
# GitHub issue indexing can lag
# ==========================================

echo "Waiting for GitHub issue sync..."

sleep 10

# ==========================================
# Verify GitHub authentication
# ==========================================

echo "=================================="
echo "🔐 GitHub Authentication"
echo "=================================="

gh auth status || true

# ==========================================
# Verify issue exists
# ==========================================

echo "=================================="
echo "🔍 Validating issue existence"
echo "=================================="

if ! gh issue view "$ISSUE_NUMBER" >/dev/null 2>&1; then

  echo "❌ GitHub issue not accessible"
  echo "Issue: #$ISSUE_NUMBER"

  exit 1

fi

echo "✅ Issue exists"

# ==========================================
# Comment retry logic
# ==========================================

echo "=================================="
echo "💬 Posting GitHub comment"
echo "=================================="

MAX_RETRIES=5

RETRY=1

COMMENT_SUCCESS=false

while [ $RETRY -le $MAX_RETRIES ]; do

  echo "Attempt $RETRY of $MAX_RETRIES"

  # ========================================
  # Try gh CLI first
  # ========================================

  if gh issue comment "$ISSUE_NUMBER" \
      --body "$COMMENT"; then

    COMMENT_SUCCESS=true

    echo "✅ GitHub comment posted"

    break

  fi

  echo "⚠️ Comment attempt failed"

  sleep 5

  RETRY=$((RETRY + 1))

done

# ==========================================
# Hard failure handling
# ==========================================

if [ "$COMMENT_SUCCESS" != true ]; then

  echo "=================================="
  echo "❌ GitHub comment failed"
  echo "=================================="

  exit 1

fi

# ==========================================
# Build dynamic labels
# ==========================================

LABELS=()

# ==========================================
# Base observability labels
# ==========================================

LABELS+=("observability")
LABELS+=("automated-rca")

# ==========================================
# Incident state labels
# ==========================================

if [[ "$ISSUE_ACTION" =~ closed ]]; then

  LABELS+=("resolved")

else

  LABELS+=("active-incident")

fi

# ==========================================
# Severity labels
# ==========================================

if [[ "$SEVERITY" =~ Critical|🛑 ]]; then

  LABELS+=("critical")

elif [[ "$SEVERITY" =~ Major|🚨 ]]; then

  LABELS+=("major")

else

  LABELS+=("minor")

fi

# ==========================================
# RCA classification labels
# ==========================================

LOWER_RCA=$(echo "$RCA" \
  | tr '[:upper:]' '[:lower:]')

if [[ "$LOWER_RCA" =~ dns ]]; then

  LABELS+=("dns")

fi

if [[ "$LOWER_RCA" =~ overload|backend|server ]]; then

  LABELS+=("backend")

fi

if [[ "$LOWER_RCA" =~ deployment|testing|staging ]]; then

  LABELS+=("testing")

fi

if [[ "$LOWER_RCA" =~ cloudflare|cdn|provider ]]; then

  LABELS+=("external-service")

fi

if [[ "$LOWER_RCA" =~ network|latency|timeout ]]; then

  LABELS+=("network")

fi

# ==========================================
# Remove duplicates
# ==========================================

UNIQUE_LABELS=($(printf "%s\n" "${LABELS[@]}" \
  | sort -u))

# ==========================================
# Apply labels
# ==========================================

echo "=================================="
echo "🏷 Applying labels"
echo "=================================="

for LABEL in "${UNIQUE_LABELS[@]}"; do

  echo "Adding label: $LABEL"

  gh issue edit "$ISSUE_NUMBER" \
    --add-label "$LABEL" || true

done

echo "✅ Labels applied"

echo "=================================="
echo "✅ GitHub enrichment completed"
echo "=================================="	
