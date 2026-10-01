#!/bin/bash

DELAY=7200
LOCK_FILE="/run/poweroff_scheduled_rtc"

case "$1" in
pre)
  TARGET_TIME=$(($(date +%s) + DELAY))
  echo "$TARGET_TIME" >"$LOCK_FILE"
  rtcwake -m disable 2>/dev/null
  rtcwake -m no -t "$TARGET_TIME"
  echo "now is: $(date +%s), wake timer is set to $TARGET_TIME"
  ;;
post)
  rtcwake -m disable 2>/dev/null
  echo "checking existing file..."
  if [ -f "$LOCK_FILE" ]; then
    SCHEDULED_TIME=$(cat "$LOCK_FILE")
    rm -f "$LOCK_FILE"
    CURRENT_TIME=$(date +%s)
    echo "Found, now is: $CURRENT_TIME, wake timer was set to $SCHEDULED_TIME"

    # If woken by RTC timer (within margin of error)
    if [ "$CURRENT_TIME" -ge "$((SCHEDULED_TIME - 2))" ]; then
      # Now we are outside suspend transaction, poweroff will succeed cleanly
      echo "$CURRENT_TIME >= $((SCHEDULED_TIME - 2)), so running suspend again"
      systemctl suspend
    fi
  fi
  ;;
esac
