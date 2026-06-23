#!/usr/bin/env bash

self_update() {
    local repo="${SAM_ROOT:-$HOME/CodeFolder/ShellAliasManager}"

    if [[ ! -d "$repo/.git" ]]; then
        echo "SAM_ROOT is not a git repository: $repo" >&2
        echo "Set SAM_ROOT to your ShellAliasManager clone, or re-run install.sh." >&2
        return 1
    fi

    echo -e "${CYAN}Checking for updates...${RESET}"
    cd "$repo" || return 1

    git fetch origin main &>/dev/null || git fetch origin &>/dev/null || true
    local status
    status="$(git status -uno 2>/dev/null || true)"

    if [[ "$status" == *"behind"* ]]; then
        echo -e "${YELLOW}Updates found. Pulling...${RESET}"
        git pull --ff-only origin main 2>/dev/null || git pull --ff-only
        cp "$repo/functions/"*.bash "${SAM_FUNCTIONS_DIR:-$HOME/.alias_manager/functions}/" 2>/dev/null || true
        echo -e "${GREEN}Updated. Restart your shell or run: source ~/.bashrc${RESET}"
    else
        echo -e "${GREEN}Already up to date.${RESET}"
    fi
}