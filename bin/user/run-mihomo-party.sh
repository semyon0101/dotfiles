#!/bin/bash
set -u

echo "Waiting until status bar will be active..."
until qdbus org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher.IsStatusNotifierHostRegistered 2>/dev/null | grep -q "true"; do
  sleep 0.5
done
echo "Waiting until status bar will be active. Done"

# ExecStartPost=/usr/bin/bash -c '/usr/bin/ip rule show pref 8999 | grep -q 8999 || /usr/bin/ip rule add to 198.18.0.0/16 lookup 2022 pref 8999'
# ExecStopPost=-/usr/bin/ip rule del pref 8999

API_PORT="9090"
API_URL="http://127.0.0.1:${API_PORT}/configs"
TOKEN_FILE="${HOME}/.config/my-mihomo-party/token.txt"

HEADER=""
if [[ -f "$TOKEN_FILE" ]]; then
  TOKEN="$(head -n 1 "$TOKEN_FILE")"
  HEADER="Authorization: Bearer $TOKEN"
fi

reset_mihomo_routes() {

  echo "Executing reset mihomo route..."
  # Wait for Mihomo API response
  echo "Waiting mihomo-party response..."
  local retries=5
  until curl -s -f -H "$HEADER" "$API_URL" >/dev/null 2>&1; do
    sleep 0.5
    ((retries--)) || break
  done
  echo "Waiting mihomo-party response. Done"

  curl -s -X PATCH "$API_URL" -H "$HEADER" -H "Content-Type: application/json" -d '{"mode": "direct"}' >/dev/null 2>&1 || true
  curl -s -X PATCH "$API_URL" -H "$HEADER" -H "Content-Type: application/json" -d '{"mode": "rule"}' >/dev/null 2>&1 || true

  if [[ "$(curl -s -H "$HEADER" "$API_URL" | jq .tun.enable)" == "true" ]]; then
    # Reset TUN and routing modes
    echo "Tunnel is running"
    curl -s -X PATCH "$API_URL" -H "$HEADER" -H "Content-Type: application/json" -d '{"tun": {"enable": false}}' >/dev/null 2>&1 || true
    curl -s -X PATCH "$API_URL" -H "$HEADER" -H "Content-Type: application/json" -d '{"tun": {"enable": true}}' >/dev/null 2>&1 || true
  else
    echo "Tunnel isn't running. Skip"
  fi
  echo "Executing reset mihomo route. Done"
}

# Start non-interactive background listener without sudo
(
  dbus-monitor --system "type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" 2>/dev/null |
    while read -r line; do
      if [[ "$line" =~ boolean\ false ]]; then
        reset_mihomo_routes
      fi
    done
) &
MONITOR_PID=$!

# Terminate background listener when main process terminates
cleanup() {
  echo "Running clean up..."
  pkill -P "$MONITOR_PID" 2>/dev/null || true
  kill "$MONITOR_PID" 2>/dev/null || true
  echo "Running clean up. Done"
}
trap 'exit 1' INT TERM HUP
trap cleanup EXIT

# Launch application in foreground to keep trap active
echo "Launch mihomo-party"
/usr/bin/mihomo-party
