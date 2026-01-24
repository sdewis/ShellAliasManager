#!/bin/bash

# --- CONFIGURATION & PATHS ---
MANAGED_TAG="#@managed_alias"
PLACEHOLDERS_FILE="$HOME/.alias_manager_placeholders.sh"

# Detect shell config file
if [[ "$SHELL" == *"zsh"* ]]; then
    CONFIG_FILE="$HOME/.zshrc"
else
    CONFIG_FILE="$HOME/.bashrc"
fi

# Load Dynamic Placeholders
if [[ -f "$PLACEHOLDERS_FILE" ]]; then
    source "$PLACEHOLDERS_FILE"
fi

# --- UI COLORS ---
BOLD='\033[1m'
REVERSE='\033[7m'
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
BLUE='\033[38;5;39m'
YELLOW='\033[38;5;226m'
CYAN='\033[38;5;51m'
GRAY='\033[38;5;244m'
RESET='\033[0m'

# --- UI HELPERS ---
draw_header() {
    clear
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${CYAN}${BOLD}🚀 Alias Manager TUI${RESET} ${GRAY}(v1.0)${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

show_status() {
    local color=$1
    local msg=$2
    echo -e "  ${color}${BOLD}»${RESET} ${msg}"
}

wait_key() {
    echo -e "\n  ${GRAY}Press any key to return to menu...${RESET}"
    read -n 1 -s
}

# --- PLACEHOLDER RESOLUTION ---
resolve_placeholders() {
    local input="$1"
    
    if [[ -f "$PLACEHOLDERS_FILE" && -n "${MANAGED_PLACEHOLDERS[*]}" ]]; then
        # Loop through defined placeholders
        for entry in "${MANAGED_PLACEHOLDERS[@]}"; do
            local tag="${entry%%:*}"
            local func="${entry#*:}"
            
            if [[ "$input" == *"$tag"* ]]; then
                input="${input//"$tag"/'$('$func')'}"
            fi
        done
    else
        # Fallback if file missing (legacy support)
        if [[ "$input" == *"{localnet}"* ]]; then
             input="${input//"{localnet}"/'$(get_localnet)'}"
        fi
    fi
    
    echo "$input"
}

# --- ALIAS MANAGEMENT ---
list_managed_aliases() {
    grep "$MANAGED_TAG" "$CONFIG_FILE" | sed "s/ $MANAGED_TAG//"
}

add_managed_alias() {
    local name="$1"
    local cmd="$2"
    local resolved_cmd=$(resolve_placeholders "$cmd")
    
    # Check if exists
    if grep -q "alias $name=" "$CONFIG_FILE"; then
        show_status "$RED" "Alias '$name' already exists!"
        return 1
    fi

    echo "alias $name='$resolved_cmd' $MANAGED_TAG" >> "$CONFIG_FILE"
    show_status "$GREEN" "Alias '$name' added successfully."
    
    # Source the change for current session
    alias "$name"="$resolved_cmd"
}

remove_managed_alias() {
    local name="$1"
    if ! grep -q "alias $name=.*$MANAGED_TAG" "$CONFIG_FILE"; then
        show_status "$RED" "Alias '$name' not found in managed aliases."
        return 1
    fi
    
    # Use temporary file to filter
    local tmp_file=$(mktemp)
    grep -v "alias $name=.*$MANAGED_TAG" "$CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
    
    unalias "$name" 2>/dev/null
    show_status "$GREEN" "Alias '$name' removed."
}

# --- BACKUP & RESTORE ---
export_to_json() {
    local output_file="$1"
    python3 -c '
import json, sys, re
aliases = []
for line in sys.stdin:
    match = re.search(r"alias (.*?)=\x27(.*?)\x27", line)
    if match:
        aliases.append({"name": match.group(1), "command": match.group(2)})
print(json.dumps(aliases, indent=4))
' < <(list_managed_aliases) > "$output_file"
    show_status "$GREEN" "Exported to $output_file"
}

import_from_json() {
    local input_file="$1"
    if [[ ! -f "$input_file" ]]; then
        show_status "$RED" "File not found: $input_file"
        return 1
    fi
    
    while IFS= read -r line; do
        local name=$(echo "$line" | cut -f1)
        local cmd=$(echo "$line" | cut -f2)
        add_managed_alias "$name" "$cmd"
    done < <(python3 -c '
import json, sys
data = json.load(open(sys.argv[1]))
for a in data:
    print(f"{a["name"]}\t{a["command"]}")
' "$input_file")
    show_status "$GREEN" "Import complete."
}

# --- OTHER TOOLS ---
install_gomenu() {
    draw_header
    echo -e "  ${BOLD}Installing gomenu...${RESET}"
    
    if ! command -v git &> /dev/null; then
        show_status "$RED" "Git is required but not installed."
        wait_key
        return
    fi

    local repo_url="https://github.com/sdewis/GoCodeShellMenu.git"
    local temp_dir=$(mktemp -d)
    
    echo -e "  ${GRAY}Cloning repository...${RESET}"
    if git clone -q "$repo_url" "$temp_dir"; then
        echo -e "  ${GRAY}Repository cloned to $temp_dir${RESET}"
        
        # Try to find an installer
        if [[ -f "$temp_dir/install.sh" ]]; then
            echo -e "  ${GRAY}Running install.sh...${RESET}"
            bash "$temp_dir/install.sh"
        elif [[ -f "$temp_dir/installer.sh" ]]; then
             echo -e "  ${GRAY}Running installer.sh...${RESET}"
            bash "$temp_dir/installer.sh"
        elif [[ -f "$temp_dir/install-gocode-gomenu.sh" ]]; then
             echo -e "  ${GRAY}Running install-gocode-gomenu.sh...${RESET}"
            bash "$temp_dir/install-gocode-gomenu.sh"
        else
            show_status "$RED" "No installer script found in the repository."
            ls -F "$temp_dir" # Show files for debugging context if needed
        fi
    else
        show_status "$RED" "Failed to clone repository."
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    wait_key
}

other_tools_menu() {
    while true; do
        draw_header
        echo -e "  ${BOLD}Other Tools${RESET}\n"
        echo -e "  ${BOLD}1.${RESET} 📦 Install gomenu"
        echo -e "  ${BOLD}2.${RESET} 🔙 Back to Main Menu"
        echo -e "\n${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        read -p "  Selection [1-2]: " choice
        
        case $choice in
            1)
                install_gomenu
                ;;
            2)
                break
                ;;
            *)
                show_status "$RED" "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

# --- MAIN MENU & TUI ---
manage_aliases() {
    while true; do
        draw_header
        echo -e "  ${BOLD}1.${RESET} 📋 List Managed Aliases"
        echo -e "  ${BOLD}2.${RESET} ➕ Add New Alias"
        echo -e "  ${BOLD}3.${RESET} ➖ Remove Alias"
        echo -e "  ${BOLD}4.${RESET} 💾 Backup to JSON"
        echo -e "  ${BOLD}5.${RESET} 📥 Restore from JSON"
        echo -e "  ${BOLD}6.${RESET} 🛠  Other Tools"
        echo -e "  ${BOLD}7.${RESET} 🚪 Exit"
        echo -e "\n${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        read -p "  Selection [1-7]: " choice
        
        case $choice in
            1)
                draw_header
                echo -e "  ${BOLD}Current Managed Aliases:${RESET}\n"
                list_managed_aliases | while read -r line; do
                    echo -e "    ${GREEN}●${RESET} ${line#alias }"
                done
                wait_key
                ;;
            2)
                draw_header
                echo -e "  ${BOLD}Add New Alias${RESET}"
                read -p "  Enter alias name (e.g., ll): " name
                read -p "  Enter command (supports {localnet}): " cmd
                if [[ -n "$name" && -n "$cmd" ]]; then
                    add_managed_alias "$name" "$cmd"
                else
                    show_status "$RED" "Invalid input."
                fi
                wait_key
                ;;
            3)
                draw_header
                echo -e "  ${BOLD}Remove Alias${RESET}"
                read -p "  Enter alias name to remove: " name
                if [[ -n "$name" ]]; then
                    remove_managed_alias "$name"
                fi
                wait_key
                ;;
            4)
                draw_header
                read -p "  Enter backup filename [aliases.json]: " bfile
                bfile=${bfile:-aliases.json}
                export_to_json "$bfile"
                wait_key
                ;;
            5)
                draw_header
                read -p "  Enter JSON file to restore: " rfile
                import_from_json "$rfile"
                wait_key
                ;;
            6)
                other_tools_menu
                ;;
            7)
                echo -e "\n  ${CYAN}Happy coding!${RESET}"
                break
                ;;
            *)
                show_status "$RED" "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

# Export the function so it can be called
export -f manage_aliases
