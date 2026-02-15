#!/bin/bash

# --- DYNAMIC PLACEHOLDER DEFINITIONS ---
# Format: "placeholder_tag:function_name"
export MANAGED_PLACEHOLDERS=(
    "{localnet}:get_localnet"
    "{git_branch}:get_git_branch"
    "{public_ip}:get_public_ip"
    "{today}:get_date_today"
    "{timestamp}:get_timestamp"
    "{gateway}:get_default_gateway"
    "{iso_time}:get_iso_time"
    "{random_uuid}:get_random_uuid"
    "{kernel_ver}:get_kernel_version"
)

# --- HELPER FUNCTIONS ---

# Returns the current local network CIDR
get_localnet() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1
    else
        echo "127.0.0.1/24"
    fi
}

# Returns the current git branch
get_git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-branch"
}

# Returns public IP
get_public_ip() {
    curl -s ifconfig.me || echo "unknown"
}

# Returns current date YYYY-MM-DD
get_date_today() {
    date +%F
}

# Returns current timestamp
get_timestamp() {
    date +%s
}

# Returns the default gateway IP
get_default_gateway() {
    ip route 2>/dev/null | awk '/default/ {print $3}' | head -n 1 || echo "unknown"
}

# Returns current time in ISO 8601 format
get_iso_time() {
    date -Iseconds
}

# Returns a random UUID
get_random_uuid() {
    if [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    elif command -v uuidgen &>/dev/null; then
        uuidgen
    else
        echo "00000000-0000-0000-0000-000000000000"
    fi
}

# Returns the kernel version
get_kernel_version() {
    uname -r
}

export -f get_localnet
export -f get_git_branch
export -f get_public_ip
export -f get_date_today
export -f get_timestamp
export -f get_default_gateway
export -f get_iso_time
export -f get_random_uuid
export -f get_kernel_version