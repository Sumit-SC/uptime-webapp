#!/usr/bin/env bash

set -e

MESSAGE="$1"

echo "=================================="
echo "📨 Sending Telegram notification"
echo "=================================="

PAYLOAD=$(jq -n \
  --arg chat_id "$CHAT_ID" \
  --arg text "$MESSAGE" \
  --argjson thread_id "$THREAD_ID" \
  '{
    chat_id: $chat_id,
    message_thread_id: $thread_id,
    text: $text,
    disable_web_page_preview: true
  }')

RESPONSE=$(curl -s -X POST \
  "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

echo "Telegram API Response:"
echo "$RESPONSE"

echo "=================================="
echo "✅ Telegram script completed"
echo "=================================="

