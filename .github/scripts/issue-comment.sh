#!/usr/bin/env bash

set -e

COMMENT="$1"

export GH_TOKEN="$GH_TOKEN"

echo "=================================="
echo "💬 Posting GitHub issue comment"
echo "=================================="

# ==========================================
# Add comment
# ==========================================

gh issue comment "$ISSUE_NUMBER" \
  --body "$COMMENT"

# ==========================================
# Auto labels
# ==========================================

LABELS=()

# Severity labels

if [[ "$SEVERITY" =~ Critical ]]; then
  LABELS+=("critical")
elif [[ "$SEVERITY" =~ Major ]]; then
  LABELS+=("major")
else
  LABELS+=("minor")
fi

# RCA labels

LOWER=$(echo "$RCA" | tr '[:upper:]' '[:lower:]')

if [[ "$LOWER" =~ dns ]]; then
  LABELS+=("dns")
fi

if [[ "$LOWER" =~ overload|backend ]]; then
  LABELS+=("backend")
fi

if [[ "$LOWER" =~ deployment|testing ]]; then
  LABELS+=("testing")
fi

# ==========================================
# Apply labels
# ==========================================

for LABEL in "${LABELS[@]}"; do

  gh issue edit "$ISSUE_NUMBER" \
    --add-label "$LABEL" || true

done

echo "=================================="
echo "✅ GitHub enrichment completed"
echo "=================================="
