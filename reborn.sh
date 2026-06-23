#!/bin/bash

# --- CONFIGURATION ---
PROJECT_DIR="$HOME/CodeFolder/ShellAliasManager"
INSTALL_PATH="$HOME/.alias_manager.sh"
FUNCTIONS_DIR="$HOME/.alias_manager/functions"
TARGET_RC="$HOME/.bashrc"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[0;226m'
RESET='\033[0m'

clear
echo -e "${PURPLE}🛠️  PHOENIX ULTIMATE v5.5 - EVERGREEN EDITION${RESET}\n"

mkdir -p "$FUNCTIONS_DIR"
cd "$PROJECT_DIR" || exit

# --- Function: self_update (Pull & Refresh) ---
cat << 'EOF' > "$PROJECT_DIR/functions/self_update.bash"
self_update() {
    echo -e "${CYAN}Checking GitHub for updates...${RESET}"
    cd "$HOME/CodeFolder/ShellAliasManager" || return 1

    # Fetch and pull
    git fetch origin main &>/dev/null
    local status=$(git status -uno)

    if [[ $status == *"behind"* ]]; then
        echo -e "${YELLOW}Updates found. Pulling new version...${RESET}"
        git pull origin main
        # Re-copy functions to the live directory
        cp functions/*.bash ~/.alias_manager/functions/
        echo -e "${GREEN}✔ System updated. Restarting shell...${RESET}"
        source ~/.bashrc
    else
        echo -e "${GREEN}✔ You are already running the latest version.${RESET}"
    fi
}
EOF

# --- Update alias_help to include self_update and snap_clean ---
cat << 'EOF' > "$PROJECT_DIR/functions/alias_help.bash"
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
EOF

# --- INSTALL & SYNC ---
cp "$PROJECT_DIR/functions/"*.bash "$FUNCTIONS_DIR/"
cp "$PROJECT_DIR/alias_manager.sh" "$INSTALL_PATH"

# --- GIT REFRESH ---
git add .
git commit -m "V5.5: Added self_update for multi-machine synchronization"
git push origin main

echo -e "${GREEN}✨ REBORN V5.5 COMPLETE!${RESET}"
echo -e "Your system is now evergreen. Type ${YELLOW}self_update${RESET} to stay current."
