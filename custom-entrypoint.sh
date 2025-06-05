#!/bin/bash
set -e

echo "Executing custom entrypoint ..."

eval "$(dbus-launch --sh-syntax)"
echo "$WIPTER_PASSWORD" | gnome-keyring-daemon --unlock --replace
set -m

setup_wipter() {
  FLAG_FILE="/root/.config/wipter.setup_done"
  
  if [ -z "$WIPTER_EMAIL" ] || [ -z "$WIPTER_PASSWORD" ]; then
    echo "WIPTER_EMAIL or WIPTER_PASSWORD is not set or is blank."
    exit 255
  fi
  
  echo "Found necessary login details. Trying now ..."
  touch "$FLAG_FILE"

}

echo "Starting Wipter ..."
setup_wipter
/opt/Wipter/wipter-app &
