#!/usr/bin/env bash

send_tg() {

  local MESSAGE="$1"

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

  curl -s -X POST \
    "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD"
}
