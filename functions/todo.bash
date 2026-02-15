todo() {
    local todo_file=".todo"
    if [[ -z "$1" ]]; then
        [[ -f "$todo_file" ]] && (echo -e "${CYAN}--- TODO ---${RESET}"; cat -n "$todo_file") || echo "No tasks here."
    else
        echo "[ ] $*" >> "$todo_file"
        echo -e "${GREEN}✔ Task added.${RESET}"
    fi
}
done() {
    [[ -z "$1" ]] && echo "Usage: done <line_number>" && return 1
    sed -i "${1}d" .todo && echo -e "${YELLOW}✔ Task cleared.${RESET}"
}
