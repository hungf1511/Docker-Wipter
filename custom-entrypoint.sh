#!/bin/bash
set -m

MASKED_PASSWORD=$(printf '***%.0s' $(seq ${#WIPTER_PASSWORD})

echo " "
echo "=== === === === === === === ==="
echo "Executing custom entrypoint ..."
echo "=== === === === === === === ==="
echo " "

eval "$(dbus-launch --sh-syntax)"
echo "$WIPTER_PASSWORD" | gnome-keyring-daemon --unlock --replace

setup_wipter() {
  FLAG_FILE="/root/.config/wipter.setup_done"

  if [ -f "$FLAG_FILE" ]; then
    echo " "
    echo "=== === === === === === === === === === === === === ==="
    echo "Wipter setup is already done; skipping initialization."
    echo "=== === === === === === === === === === === === === ==="
    echo " "
    return 0
  fi

  if [ -z "$WIPTER_EMAIL" ] || [ -z "$WIPTER_PASSWORD" ]; then
    echo " "
    echo "=== === === === === === === === === === === === === ==="
    echo "WIPTER_EMAIL or WIPTER_PASSWORD is not set or is blank."
    echo "=== === === === === === === === === === === === === ==="
    echo " "
    return 0
  fi
  echo " "
  echo "=== === === === === === === === === === === ==="
  echo "Found necessary login details. Trying now ..."
  echo "=== === === === === === === === === === === ==="
  echo " "
  
  local WIPTER_WIN=""
  local attempts=0
  while [ -z "$WIPTER_WIN" ] && [ $attempts -lt 30 ]; do
    WIPTER_INFO=$(wmctrl -l | grep -i "Wipter")
    if [ -n "$WIPTER_INFO" ]; then
      WIPTER_WIN=$(echo "$WIPTER_INFO" | head -n 1 | awk '{print $1}')
      break
    fi
    sleep 2
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

  wmctrl -ia "$WIPTER_WIN"
  sleep 5
  xte "key Tab"
  sleep 3
  xte "key Tab"
  sleep 3
  xte "key Tab"
  sleep 3
  echo " "
  echo "=== === === === === === === === === === === === ==="
  echo "Typing EMAIL = $WIPTER_EMAIL"
  echo "=== === === === === === === === === === === === ==="
  echo " "
  xte "str $WIPTER_EMAIL"
  sleep 3
  xte "key Tab"
  sleep 3
  echo " "
  echo "=== === === === === === === === === === === === ==="
  echo "Typing PASSWORD = $MASKED_PASSWORD"
  echo "=== === === === === === === === === === === === ==="
  echo " "
  xte "str $WIPTER_PASSWORD"
  sleep 3
  xte "key Return"

  echo " "
  echo "=== === === === === === === === === === === === ==="
  echo "Wipter setup complete."
  echo "=== === === === === === === === === === === === ==="
  echo " "
  mkdir -p "$(dirname "$FLAG_FILE")"
  touch "$FLAG_FILE"
  return 0
}

echo " "
echo "=== === === === ==="
echo "Starting Wipter ..."
echo "=== === === === ==="
echo " "
/opt/Wipter/wipter-app &
sleep 5
setup_wipter