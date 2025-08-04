#!/bin/bash
set -m

MASKED_PASSWORD=$(printf '***%.0s' $(seq ${#WIPTER_PASSWORD}))

echo " "
echo "=== === === === === === === ==="
echo "Executing custom entrypoint ..."
echo "=== === === === === === === ==="
echo " "

# --- Khởi tạo Xvfb (headless) ---
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 3

# --- Unlock keyring ---
eval "$(dbus-launch --sh-syntax)"
echo "$WIPTER_PASSWORD" | gnome-keyring-daemon --unlock --replace

setup_wipter() {
  sleep 10
  FLAG_FILE="/root/.config/wipter.setup_done"

  # Nếu đã login trước đó thì bỏ qua
  if [ -f "$FLAG_FILE" ]; then
    echo " "
    echo "=== === === === === === === === === === === === === ==="
    echo "Wipter setup is already done; skipping initialization."
    echo "=== === === === === === === === === === === === === ==="
    echo " "
    return 0
  fi

  # Kiểm tra biến môi trường
  if [ -z "$WIPTER_EMAIL" ] || [ -z "$WIPTER_PASSWORD" ]; then
    echo " "
    echo "=== === === === === === === === === === === === === ==="
    echo "WIPTER_EMAIL or WIPTER_PASSWORD is not set or is blank."
    echo "=== === === === === === === === === === === === === ==="
    echo " "
    return 0
  fi

  echo " "
  echo "=== === === === === === === === === === ==="
  echo "Found necessary login details. Trying now ..."
  echo "=== === === === === === === === === === ==="
  echo " "

  # Tìm cửa sổ Wipter
  local WIPTER_WIN=""
  local attempts=0
  while [ -z "$WIPTER_WIN" ] && [ $attempts -lt 30 ]; do
    WIPTER_INFO=$(wmctrl -l | grep -i "Wipter")
    if [ -n "$WIPTER_INFO" ]; then
      WIPTER_WIN=$(echo "$WIPTER_INFO" | head -n 1 | awk '{print $1}')
      break
    fi
    wmctrl -l || echo "[DEBUG] No windows detected..."
    sleep 10
    attempts=$((attempts+1))
  done

  if [ -z "$WIPTER_WIN" ]; then
    echo " "
    echo "=== === === === === === === === === === === === ==="
    echo "Wipter window was not found after waiting. Exiting."
    echo "=== === === === === === === === === === === === ==="
    echo " "
    return 0
  fi

  # Đưa cửa sổ Wipter ra foreground
  wmctrl -ia "$WIPTER_WIN"
  sleep 10

  # Điều hướng tab đến ô nhập email
  xte "key Tab"; sleep 3
  xte "key Tab"; sleep 3
  xte "key Tab"; sleep 3

  # Gõ email
  echo "=== Typing EMAIL: $WIPTER_EMAIL ==="
  xte "str $WIPTER_EMAIL"; sleep 3
  xte "key Tab"; sleep 3

  # Gõ password
  echo "=== Typing PASSWORD: $MASKED_PASSWORD ==="
  xte "str $WIPTER_PASSWORD"; sleep 3
  xte "key Return"; sleep 20

  # 📸 Chụp màn hình và gửi về Discord
  if [[ -n "$DISCORD_WEBHOOK_URL" && "$DISCORD_WEBHOOK_URL" =~ ^https://discord\.com/api/webhooks/[0-9]+/[A-Za-z0-9_-]+$ ]]; then
    SCREENSHOT_PATH="/tmp/wipter_login.png"
    HOSTNAME="$(hostname)"
    command -v scrot >/dev/null && scrot -o -D "$DISPLAY" "$SCREENSHOT_PATH"
    curl -s -o /dev/null -X POST "$DISCORD_WEBHOOK_URL" \
      -F "file=@$SCREENSHOT_PATH" \
      -F "payload_json={\"embeds\": [{\"title\": \"Wipter login on host: $HOSTNAME\", \"color\": 5814783}]}"
  else
    echo "[INFO] Discord webhook is not configured correctly; skipping screenshot."
  fi

  # Đóng cửa sổ Wipter
  wmctrl -ic "$WIPTER_WIN"

  echo "=== Wipter setup complete. ==="
  mkdir -p "$(dirname "$FLAG_FILE")"
  touch "$FLAG_FILE"  # Đánh dấu login thành công
  return 0
}

echo "=== Starting Wipter... ==="
/opt/Wipter/wipter-app &
setup_wipter

mkdir -p "/root/.config"
touch "/root/.config/wipter.setup_done"
