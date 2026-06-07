#!/bin/bash

SETUP_SCRIPT="/usr/local/bin/wifi-setup.sh"
LOG_FILE="/var/log/wifi-setup.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

has_connection() {
    nmcli -t -f STATE general | grep -q "^connected$"
}

if has_connection; then
    exit 0
fi

sleep 5

if has_connection; then
    exit 0
fi

log "No active connection after 5 seconds, running wifi setup..."
bash "$SETUP_SCRIPT"