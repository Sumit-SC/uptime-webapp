#!/usr/bin/env bash

set -e

MESSAGE="$1"

# ==========================================
# Time metadata
# ==========================================

LOCAL_TIME=$(TZ="$SUMMARY_TIMEZONE" \
  date +"%d %b %Y | %I:%M %p")

UTC_TIME=$(date -u +"%H:%M UTC")

# ==========================================
# Footer metadata
# ==========================================

FOOTER="

━━━━━━━━━━━━━━━━━━

🤖 Sumit Observability Stack
📡 Delivered via Telegram Monitoring Bot
🕒 $LOCAL_TIME | 🌍 $UTC_TIME"

FINAL_MESSAGE="$MESSAGE$FOOTER"

echo "=================================="
echo "📨 Sending Telegram notification"
echo "=================================="

# ==========================================
# Build Telegram payload
# ==========================================

PAYLOAD=$(jq -n \
  --arg chat_id "$CHAT_ID" \
  --arg text "$FINAL_MESSAGE" \
  --argjson thread_id "$THREAD_ID" \
  '{
    chat_id: $chat_id,
    message_thread_id: $thread_id,
    text: $text,
    disable_web_page_preview: true
  }')

# ==========================================
# Send Telegram message
# ==========================================

RESPONSE=$(curl -s -X POST \
  "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# ==========================================
# Debug response
# ==========================================

echo "Telegram API Response:"
echo "$RESPONSE"

# ==========================================
# Detect Telegram failure
# ==========================================

if echo "$RESPONSE" | grep -q '"ok":true'; then

  echo "✅ Telegram alert sent successfully"

else

  echo "❌ Telegram delivery failed"

  exit 1
fi

echo "=================================="
echo "📨 Telegram pipeline completed"
echo "=================================="
