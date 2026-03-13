alias_help() {
    local last_sync=$(git log -1 --format=%cr 2>/dev/null || echo "Never")
    echo -e "${PURPLE}📖 SHELL INNOVATION MANUAL${RESET}"
    echo -e "${BLUE}Cloud Sync Status: ${GREEN}${last_sync}${RESET}"
    echo -e "${CYAN}==================================================${RESET}"
    echo -e "${YELLOW}MAINTENANCE & SYNC:${RESET}"
    echo -e "  self_update : Pull latest tools/configs from GitHub."
    echo -e "  sync_backup : Push local changes to GitHub."
    echo -e "  snap_clean  : Purge old gsnap branches safely."
    echo -e ""
    echo -e "${YELLOW}AI & CODING:${RESET}"
    echo -e "  ai_start    : Prep Gemini with local TODOs & file context."
    echo -e "  gsnap       : Fearless Git branch snapshot."
    echo -e "  todo / fin  : Manage folder-specific tasks."
    echo -e "${CYAN}==================================================${RESET}"
}
