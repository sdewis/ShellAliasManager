#!/usr/bin/env bash
# Shell Alias Manager — paths and shell detection

# Safe to source multiple times (e.g. re-running `source ~/.bashrc`)
if [[ -n "${_SAM_CONFIG_LOADED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
_SAM_CONFIG_LOADED=1

readonly SAM_VERSION="2.0.0"
readonly SAM_MANAGED_TAG="#@managed_alias"
readonly SAM_RC_MARKER="# shell-alias-manager"

_sam_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAM_ROOT="$(cd "$_sam_lib_dir/.." && pwd)"

SAM_USER_DIR="${SAM_USER_DIR:-$HOME/.alias_manager}"
SAM_FUNCTIONS_DIR="$SAM_USER_DIR/functions"
SAM_PLACEHOLDERS_FILE="${SAM_PLACEHOLDERS_FILE:-$HOME/.alias_manager_placeholders.sh}"

sam_detect_config_file() {
    if [[ -n "${SAM_CONFIG_FILE:-}" ]]; then
        echo "$SAM_CONFIG_FILE"
        return 0
    fi
    local shell_name
    shell_name="$(basename "${SHELL:-bash}")"
    case "$shell_name" in
        zsh) echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *) echo "$HOME/.profile" ;;
    esac
}

SAM_CONFIG_FILE="$(sam_detect_config_file)"

sam_ensure_dirs() {
    mkdir -p "$SAM_FUNCTIONS_DIR"
}

sam_backup_config() {
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    cp "$SAM_CONFIG_FILE" "${SAM_CONFIG_FILE}.bak.${ts}"
    echo "${SAM_CONFIG_FILE}.bak.${ts}"
}