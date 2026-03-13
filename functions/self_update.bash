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
