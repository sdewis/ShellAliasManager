#!/usr/bin/env bash

show_welcome() {
    echo -e "${PURPLE}Shell ready.${RESET} Type ${YELLOW}alias_help${RESET} for commands."
    curl -s --max-time 2 "wttr.in?format=3" 2>/dev/null || true

    if [[ -f ".todo" ]]; then
        echo -e "${CYAN}--- local TODOs ---${RESET}"
        head -n 3 .todo | sed 's/^/  /'
    fi
}