#!/usr/bin/env bash
set -u

# Порт и токен REST API Mihomo
API_PORT="9090"
API_URL="http://127.0.0.1:${API_PORT}/configs"
TOKEN_FILE="/home/semyon/.config/my-mihomo-party/token.txt"

TOKEN=""
if [[ -f "$TOKEN_FILE" ]]; then
  TOKEN="$(head -n 1 "$TOKEN_FILE" | tr -d '\r\n')"
fi

HEADER="Authorization: Bearer $TOKEN"

until curl -s -H "$HEADER" "$API_URL" >/dev/null 2>&1; do
  if ! pgrep -x "mihomo-party" >/dev/null 2>&1; then
    exit 1
  fi
  sleep 0.5
done

for _i in {1..10}; do
  if [[ "$(cat /sys/class/net/wlan0/operstate 2>/dev/null)" == "up" ]]; then
    break
  fi
  sleep 0.5
done

enabled_tun="$(curl -s "$API_URL" \
  -H "$HEADER" \
  -H "Content-Type: application/json" \
  2>/dev/null | jq .tun.enable)"

if [[ "$enabled_tun" != "true" ]]; then
  exit 0
fi

curl -s -X PATCH "$API_URL" \
  -H "$HEADER" \
  -H "Content-Type: application/json" \
  -d '{"tun": { "enable": false }}' >/dev/null 2>&1 || true

# Включаем TUN обратно
curl -s -X PATCH "$API_URL" \
  -H "$HEADER" \
  -H "Content-Type: application/json" \
  -d '{"tun": { "enable": true }}' >/dev/null 2>&1 || true

curl -s -X PATCH "$API_URL" \
  -H "$HEADER" \
  -H "Content-Type: application/json" \
  -d '{"mode": "direct"}' >/dev/null 2>&1 || true

# Включаем TUN обратно
curl -s -X PATCH "$API_URL" \
  -H "$HEADER" \
  -H "Content-Type: application/json" \
  -d '{"mode": "rule"}' >/dev/null 2>&1 || true


touch /tmp/test2.txt
