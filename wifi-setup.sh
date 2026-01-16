#!/bin/bash

# Configuration file path
CONFIG_FILE="/boot/firmware/wifi_config.txt"

# Log file
LOG_FILE="/var/log/wifi-setup.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_message "Please run as root"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_message "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Read and process each line from the config file
while IFS=',' read -r ssid password priority identity ca_cert altsubject; do
    # Skip empty lines or comments
    [[ -z "$ssid" || "$ssid" =~ ^# ]] && continue
    
    # Remove any leading/trailing whitespace
    ssid=$(echo "$ssid" | xargs)
    password=$(echo "$password" | xargs)
    priority=$(echo "$priority" | xargs)
    identity=$(echo "$identity" | xargs)
    ca_cert=$(echo "$ca_cert" | xargs)
    altsubject=$(echo "$altsubject" | xargs)
    
    # Prepare nmcli arguments
    common_args=(
        connection.autoconnect yes
        connection.autoconnect-priority "$priority"
    )
    
    auth_args=()
    if [ -n "$identity" ]; then
        # WPA-EAP (eduroam)
        auth_args+=(
            wifi-sec.key-mgmt wpa-eap
            802-1x.eap peap
            802-1x.phase2-auth mschapv2
            802-1x.identity "$identity"
            802-1x.password "$password"
        )
        [ -n "$ca_cert" ] && auth_args+=(802-1x.ca-cert "$ca_cert")
        [ -n "$altsubject" ] && auth_args+=(802-1x.altsubject-matches "$altsubject")
    else
        # WPA-PSK
        auth_args+=(
            wifi-sec.key-mgmt wpa-psk
            wifi-sec.psk "$password"
        )
    fi
    
    # Check if connection already exists
    if nmcli connection show "$ssid" >/dev/null 2>&1; then
        log_message "Connection '$ssid' already exists, updating..."
        # Update existing connection
        nmcli connection modify "$ssid" "${common_args[@]}" "${auth_args[@]}"
    else
        log_message "Creating new connection for '$ssid'..."
        # Create new connection
        nmcli connection add \
            type wifi \
            con-name "$ssid" \
            ifname wlan0 \
            ssid "$ssid" \
            "${common_args[@]}" \
            "${auth_args[@]}"
    fi
done < "$CONFIG_FILE"

# Try to connect to the highest priority network
highest_priority_ssid=$(nmcli -t -f NAME,autoconnect-priority connection show | sort -t: -k2 -nr | head -n1 | cut -d: -f1)
if [ ! -z "$highest_priority_ssid" ]; then
    log_message "Attempting to connect to highest priority network: $highest_priority_ssid"
    nmcli connection up "$highest_priority_ssid"
fi

log_message "WiFi setup completed" 