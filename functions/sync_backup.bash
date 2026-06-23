#!/usr/bin/env bash

sync_backup() {
    local repo="${SAM_ROOT:-$HOME/CodeFolder/ShellAliasManager}"

    if [[ ! -d "$repo/.git" ]]; then
        echo "SAM_ROOT is not a git repository: $repo" >&2
        return 1
    fi

    echo -e "${CYAN}Checking backup health...${RESET}"
    cd "$repo" || return 1

    local last_push
    last_push="$(git log -1 --format=%ct 2>/dev/null || echo 0)"
    local diff=$(( ($(date +%s) - last_push) / 86400 ))

    if [[ "$diff" -ge 3 ]]; then
        echo -e "${YELLOW}Backup is ${diff} days old.${RESET}"
    fi

    if git diff --quiet && git diff --cached --quiet; then
        echo -e "${GREEN}Nothing to sync.${RESET}"
        return 0
    fi

    git add -A
    git commit -m "Auto-sync: $(date +%Y-%m-%d_%H:%M)"
    git push origin main
    echo -e "${GREEN}Backup synced.${RESET}"
}