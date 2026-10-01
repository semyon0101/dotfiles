#!/usr/bin/bash
SCHEDULED_TIME=0
DELAY=7200

handle_pre_sleep() {
  SCHEDULED_TIME=$(($(date +%s) + DELAY))
  rtcwake -m disable 2>/dev/null 1>&2
  rtcwake -m no -t "$SCHEDULED_TIME" 2>/dev/null
  echo "Pre-sleep: wake timer set to $SCHEDULED_TIME"
}

handle_post_sleep() {

  rtcwake -m disable 2>/dev/null 1>&2
  if [ "$SCHEDULED_TIME" -eq 0 ]; then
    echo "Unexpected: SCHEDULED_TIME = 0."
    return
  fi

  local saved_target="$SCHEDULED_TIME"
  SCHEDULED_TIME=0

  local current_time
  current_time=$(date +%s)

  if [ "$current_time" -ge "$((saved_target - 2))" ]; then
    echo "Woken by RTC timer ($current_time >= $saved_target - 2)."

    local is_sleeping
    is_sleeping=$(busctl --system get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager PreparingForSleep 2>/dev/null | awk '{print $2}')

    if [ "$is_sleeping" == "false" ]; then
      echo "System is idle after RTC wakeup, suspending again..."
      systemctl suspend
    else
      echo "Suspend already triggered externally, skipping."
    fi
  else
    echo "Woken by user iteraction."
  fi
}

while read -r line; do
  if [[ "$line" == *"PrepareForSleep (true,"* ]]; then
    echo "Running pre sleep..."
    handle_pre_sleep
    echo "Running pre sleep. Done"
  elif [[ "$line" == *"PrepareForSleep (false,"* ]]; then
    echo "Running post sleep..."
    handle_post_sleep
    echo "Running post sleep. Done"
  fi
done < <(gdbus monitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1)
