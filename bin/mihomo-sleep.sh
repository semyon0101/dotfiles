#!/usr/bin/env bash
set -u

# Порт и токен REST API Mihomo
API_PORT="9090"
API_URL="http://127.0.0.1:${API_PORT}/configs"
TOKEN_FILE="/home/semyon/.config/my-mihomo-party/token.txt"
STATE_FILE="/run/mihomo-pre-sleep-tun-state"

TOKEN=""
if [[ -f "$TOKEN_FILE" ]]; then
  TOKEN="$(head -n 1 "$TOKEN_FILE" | tr -d '\r\n')"
fi

HEADER="Authorization: Bearer $TOKEN"

case "${1:-}" in
stop)
  # Получаем конфиг с таймаутом, чтобы скрипт не завис
  CONFIG_JSON=$(curl -s -m 2 -H "$HEADER" "$API_URL" 2>/dev/null || true)

  # Проверяем флаг tun.enable
  IS_TUN=$(echo "$CONFIG_JSON" | grep -o '"tun":{[^}]*}' | grep -o '"enable":[a-z]*' | cut -d':' -f2 || true)

  if [[ "$IS_TUN" == "true" ]]; then
    touch "$STATE_FILE"
    # Выключаем TUN
    curl -s -m 2 -X PATCH "$API_URL" \
      -H "$HEADER" \
      -H "Content-Type: application/json" \
      -d '{"tun": {"enable": false}}' >/dev/null 2>&1 || true
  else
    rm -f "$STATE_FILE"
  fi
  ;;

start)
  if [[ -f "$STATE_FILE" ]]; then
    # Ожидаем готовность сокета REST API (до 5 секунд)
    for _ in {1..10}; do
      if curl -s -m 1 -H "$HEADER" "$API_URL" >/dev/null 2>&1; then
        break
      fi
      sleep 0.5
    done

    # Включаем TUN обратно
    curl -s -m 3 -X PATCH "$API_URL" \
      -H "$HEADER" \
      -H "Content-Type: application/json" \
      -d '{"tun": {"enable": true}}' >/dev/null 2>&1 || true

    rm -f "$STATE_FILE"
  fi
  ;;
esac
