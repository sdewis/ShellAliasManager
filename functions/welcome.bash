show_welcome() {
    echo -e "${PURPLE}🚀 SYSTEM ONLINE, SEAN${RESET}"
    curl -s "wttr.in?format=3" || echo "Weather offline"

    if [[ -f ".todo" ]]; then
        echo -e "${CYAN}--- LOCAL TODOs ---${RESET}"
        head -n 3 .todo | sed 's/^/  /'
    fi

    echo -e "${CYAN}--- CHEAT SHEET ---${RESET}"
    echo -e "${YELLOW}todo \"msg\"${RESET} : Add Task        ${YELLOW}gsnap${RESET}      : Git Save"
    echo -e "${YELLOW}ai_start${RESET}   : Prep Gemini     ${YELLOW}sync_backup${RESET}: Sync Config"
    echo -e "${CYAN}-------------------${RESET}"
}
