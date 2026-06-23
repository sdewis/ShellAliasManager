#!/usr/bin/env bash
# Shell Alias Manager — interactive TUI

sam_draw_header() {
    clear
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${CYAN}${BOLD}Shell Alias Manager${RESET} ${GRAY}(v${SAM_VERSION})${RESET}"
    echo -e "  ${GRAY}Config: ${SAM_CONFIG_FILE}${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
"
}

sam_show_status() {
    local color="$1"
    local msg="$2"
    echo -e "  ${color}${BOLD}»${RESET} ${msg}"
}

sam_wait_key() {
    echo -e "
  ${GRAY}Press any key to return...${RESET}"
    read -r -n 1 -s
}

sam_import_menu() {
    while true; do
        sam_draw_header
        echo -e "  ${BOLD}Import Unmanaged Items${RESET}
"
        echo -e "  ${BOLD}1.${RESET} List unmanaged aliases"
        echo -e "  ${BOLD}2.${RESET} List unmanaged functions"
        echo -e "  ${BOLD}3.${RESET} Back"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        local choice
        read -r -p "  Selection [1-3]: " choice

        case "$choice" in
            1)
                sam_draw_header
                echo -e "  ${BOLD}Select alias to import:${RESET}
"
                local items=()
                while IFS= read -r line; do
                    [[ -n "$line" ]] && items+=("$line")
                done < <(sam_list_unmanaged_aliases)

                if [[ ${#items[@]} -eq 0 ]]; then
                    echo -e "  ${GRAY}(none found)${RESET}"
                    sam_wait_key
                else
                    local i
                    for i in "${!items[@]}"; do
                        echo -e "  ${BOLD}$((i + 1)).${RESET} ${items[$i]}"
                    done
                    local num
                    read -r -p "  Number (0 = back): " num
                    if [[ "$num" -gt 0 && "$num" -le ${#items[@]} ]]; then
                        sam_import_unmanaged_alias "${items[$((num - 1))]}"
                        sleep 1
                    fi
                fi
                ;;
            2)
                sam_draw_header
                echo -e "  ${BOLD}Select function to import:${RESET}
"
                local funcs=()
                while IFS= read -r line; do
                    [[ -n "$line" ]] && funcs+=("$line")
                done < <(sam_list_unmanaged_functions)

                if [[ ${#funcs[@]} -eq 0 ]]; then
                    echo -e "  ${GRAY}(none found)${RESET}"
                    sam_wait_key
                else
                    local i
                    for i in "${!funcs[@]}"; do
                        echo -e "  ${BOLD}$((i + 1)).${RESET} ${funcs[$i]}"
                    done
                    local num
                    read -r -p "  Number (0 = back): " num
                    if [[ "$num" -gt 0 && "$num" -le ${#funcs[@]} ]]; then
                        sam_import_unmanaged_function "${funcs[$((num - 1))]}"
                        sleep 1
                    fi
                fi
                ;;
            3) break ;;
        esac
    done
}

sam_manage_functions_menu() {
    while true; do
        sam_draw_header
        echo -e "  ${BOLD}Manage Functions${RESET}"
        echo -e "  ${GRAY}Directory: $SAM_FUNCTIONS_DIR${RESET}
"
        echo -e "  ${BOLD}1.${RESET} List functions"
        echo -e "  ${BOLD}2.${RESET} Add function"
        echo -e "  ${BOLD}3.${RESET} Edit function"
        echo -e "  ${BOLD}4.${RESET} Remove function"
        echo -e "  ${BOLD}5.${RESET} Back"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        local choice name
        read -r -p "  Selection [1-5]: " choice

        case "$choice" in
            1)
                sam_draw_header
                echo -e "  ${BOLD}Managed functions:${RESET}
"
                local fn
                while IFS= read -r fn; do
                    echo -e "    ${GREEN}ƒ${RESET} $fn"
                done < <(sam_list_managed_functions)
                sam_wait_key
                ;;
            2)
                sam_draw_header
                read -r -p "  Function name: " name
                [[ -n "$name" ]] && sam_add_managed_function "$name"
                sam_wait_key
                ;;
            3)
                sam_draw_header
                read -r -p "  Function name: " name
                [[ -n "$name" ]] && sam_edit_managed_function "$name"
                sam_wait_key
                ;;
            4)
                sam_draw_header
                read -r -p "  Function name: " name
                [[ -n "$name" ]] && sam_remove_managed_function "$name"
                sam_wait_key
                ;;
            5) break ;;
            *)
                sam_show_status "$RED" "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

manage_aliases() {
    while true; do
        sam_draw_header
        echo -e "  ${BOLD}1.${RESET} List managed aliases"
        echo -e "  ${BOLD}2.${RESET} Add alias"
        echo -e "  ${BOLD}3.${RESET} Edit alias"
        echo -e "  ${BOLD}4.${RESET} Remove alias"
        echo -e "  ${BOLD}5.${RESET} Import unmanaged items"
        echo -e "  ${BOLD}6.${RESET} Export to JSON"
        echo -e "  ${BOLD}7.${RESET} Import from JSON"
        echo -e "  ${BOLD}8.${RESET} Manage functions"
        echo -e "  ${BOLD}9.${RESET} Show placeholders"
        echo -e "  ${BOLD}0.${RESET} Exit"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        local choice name cmd bfile rfile
        read -r -p "  Selection [0-9]: " choice

        case "$choice" in
            1)
                sam_draw_header
                echo -e "  ${BOLD}Managed aliases:${RESET}
"
                while IFS= read -r line; do
                    echo -e "    ${GREEN}●${RESET} ${line#alias }"
                done < <(sam_list_managed_aliases)
                sam_wait_key
                ;;
            2)
                sam_draw_header
                read -r -p "  Name: " name
                read -r -p "  Command: " cmd
                if [[ -n "$name" && -n "$cmd" ]]; then
                    sam_add_managed_alias "$name" "$cmd" && sam_show_status "$GREEN" "Done."
                fi
                sam_wait_key
                ;;
            3)
                sam_draw_header
                read -r -p "  Name: " name
                read -r -p "  New command: " cmd
                if [[ -n "$name" && -n "$cmd" ]]; then
                    sam_edit_managed_alias "$name" "$cmd" && sam_show_status "$GREEN" "Done."
                fi
                sam_wait_key
                ;;
            4)
                sam_draw_header
                read -r -p "  Name to remove: " name
                [[ -n "$name" ]] && sam_remove_managed_alias "$name"
                sam_wait_key
                ;;
            5) sam_import_menu ;;
            6)
                sam_draw_header
                read -r -p "  Filename [aliases.json]: " bfile
                bfile="${bfile:-aliases.json}"
                sam_export_to_json "$bfile"
                sam_wait_key
                ;;
            7)
                sam_draw_header
                read -r -p "  JSON file: " rfile
                [[ -n "$rfile" ]] && sam_import_from_json "$rfile"
                sam_wait_key
                ;;
            8) sam_manage_functions_menu ;;
            9)
                sam_draw_header
                echo -e "  ${BOLD}Placeholders:${RESET}
"
                sam_list_placeholders
                sam_wait_key
                ;;
            0)
                echo -e "
  ${CYAN}Done.${RESET}"
                break
                ;;
            *)
                sam_show_status "$RED" "Invalid selection."
                sleep 1
                ;;
        esac
    done
}