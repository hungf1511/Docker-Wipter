#!/bin/bash
set -m

echo "Executing custom entrypoint ..."

eval "$(dbus-launch --sh-syntax)"
echo "$WIPTER_PASSWORD" | gnome-keyring-daemon --unlock --replace

setup_wipter() {
  FLAG_FILE="/root/.config/wipter.setup_done"

  if [ -f "$FLAG_FILE" ]; then
    echo "Wipter setup is already done; skipping initialization."
    return 0
  fi

  if [ -z "$WIPTER_EMAIL" ] || [ -z "$WIPTER_PASSWORD" ]; then
    echo "WIPTER_EMAIL or WIPTER_PASSWORD is not set or is blank."
    return 0
  fi

  echo "Found necessary login details. Trying now ..."
  
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
    echo "Wipter window was not found after waiting. Exiting."
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
  xte "str $WIPTER_EMAIL"
  sleep 3
  xte "key Tab"
  sleep 3
  xte "str $WIPTER_PASSWORD"
  sleep 3
  xte "key Return"

  echo "Wipter setup complete."

  mkdir -p "$(dirname "$FLAG_FILE")"
  touch "$FLAG_FILE"
  return 0
}


echo "Starting Wipter ..."
/opt/Wipter/wipter-app &
sleep 5
setup_wipter