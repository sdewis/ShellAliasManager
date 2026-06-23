#!/usr/bin/env bash

alias_help() {
    local func_dir="${SAM_FUNCTIONS_DIR:-$HOME/.alias_manager/functions}"
    local last_sync="never"

    if [[ -n "${SAM_ROOT:-}" && -d "$SAM_ROOT/.git" ]]; then
        last_sync="$(git -C "$SAM_ROOT" log -1 --format=%cr 2>/dev/null || echo "never")"
    fi

    echo -e "${PURPLE}Shell Alias Manager — command reference${RESET}"
    echo -e "${BLUE}Last repo sync:${RESET} ${GREEN}${last_sync}${RESET}"
    echo -e "${CYAN}==================================================${RESET}"
    echo -e "${YELLOW}Alias manager:${RESET}"
    echo -e "  manage-aliases     Interactive TUI"
    echo -e "  manage-aliases help  CLI commands (add, list, export, ...)"
    echo ""
    echo -e "${YELLOW}Maintenance:${RESET}"
    echo -e "  self_update        Pull latest from git"
    echo -e "  sync_backup        Commit and push local changes"
    echo -e "  gsnap [msg]        Git snapshot branch"
    echo -e "  snap_clean         Remove gsnap/* branches"
    echo ""
    echo -e "${YELLOW}Productivity:${RESET}"
    echo -e "  todo [task]        Folder TODO list"
    echo -e "  fin <line>         Mark TODO done"
    echo -e "  ai_start           Generate AI_SESSION.md context"
    echo -e "  mkcd <dir>         mkdir -p and cd"
    echo -e "  extract <archive>  Extract common archive formats"
    echo -e "  wttr [city]        Weather forecast"
    echo -e "${CYAN}==================================================${RESET}"

    if [[ -d "$func_dir" ]]; then
        local count
        count="$(find "$func_dir" -maxdepth 1 -name '*.bash' 2>/dev/null | wc -l)"
        echo -e "${GRAY}${count} shell functions loaded from ${func_dir}${RESET}"
    fi
}