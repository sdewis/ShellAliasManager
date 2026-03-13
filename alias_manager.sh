#!/bin/bash

# --- CONFIGURATION & PATHS ---
MANAGED_TAG="#@managed_alias"
PLACEHOLDERS_FILE="$HOME/.alias_manager_placeholders.sh"
FUNCTIONS_DIR="$HOME/.alias_manager/functions"

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

# Load Managed Functions
if [[ -d "$FUNCTIONS_DIR" ]]; then
    for f in "$FUNCTIONS_DIR"/*.bash; do
        [[ -f "$f" ]] && source "$f"
    done
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
    echo -e "  ${CYAN}${BOLD}🚀 Alias Manager TUI${RESET} ${GRAY}(v1.1)${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
"
}

show_status() {
    local color=$1
    local msg=$2
    echo -e "  ${color}${BOLD}»${RESET} ${msg}"
}

wait_key() {
    echo -e "
  ${GRAY}Press any key to return to menu...${RESET}"
    read -n 1 -s
}

# --- PLACEHOLDER RESOLUTION ---
resolve_placeholders() {
    local input="$1"
    
    if [[ -f "$PLACEHOLDERS_FILE" && -n "${MANAGED_PLACEHOLDERS[*]}" ]]; then
        for entry in "${MANAGED_PLACEHOLDERS[@]}"; do
            local tag="${entry%%:*}"
            local func="${entry#*:}"
            
            if [[ "$input" == *"$tag"* ]]; then
                input="${input//"$tag"/'$('$func')'}"
            fi
        done
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
    
    if grep -q "alias $name=" "$CONFIG_FILE"; then
        show_status "$RED" "Alias '$name' already exists!"
        return 1
    fi

    echo "alias $name='$resolved_cmd' $MANAGED_TAG" >> "$CONFIG_FILE"
    show_status "$GREEN" "Alias '$name' added successfully."
    alias "$name"="$resolved_cmd"
}

remove_managed_alias() {
    local name="$1"
    if ! grep -q "alias $name=.*$MANAGED_TAG" "$CONFIG_FILE"; then
        show_status "$RED" "Alias '$name' not found in managed aliases."
        return 1
    fi
    
    local tmp_file=$(mktemp)
    grep -v "alias $name=.*$MANAGED_TAG" "$CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
    
    unalias "$name" 2>/dev/null
    show_status "$GREEN" "Alias '$name' removed."
}

# --- IMPORT UNMANAGED ---
list_unmanaged_aliases() {
    grep "^alias " "$CONFIG_FILE" | grep -v "$MANAGED_TAG"
}

list_unmanaged_functions() {
    # Looks for functions in config file
    grep -E "^[a-zA-Z0-9_]+\(\) *\{|^function [a-zA-Z0-9_]+" "$CONFIG_FILE"
}

import_unmanaged_alias() {
    local alias_line="$1"
    local name=$(echo "$alias_line" | sed -E 's/alias ([^= ]+)=.*/\1/')
    sed -i "s/^alias $name=.*/& $MANAGED_TAG/" "$CONFIG_FILE"
    show_status "$GREEN" "Alias '$name' is now managed."
}

import_unmanaged_function() {
    local func_sig="$1"
    local name=$(echo "$func_sig" | sed -E 's/^function ([^ (]+).*/\1/; s/^([^ (]+)\(\).*/\1/')
    
    local target_file="$FUNCTIONS_DIR/$name.bash"
    if [[ -f "$target_file" ]]; then
        show_status "$RED" "Function file already exists at $target_file"
        return
    fi

    # Extract function block from config file
    # heuristic: from signature to first line starting with }
    mkdir -p "$FUNCTIONS_DIR"
    echo "#!/bin/bash" > "$target_file"
    echo "" >> "$target_file"
    sed -n "/^$name/,/^}/p" "$CONFIG_FILE" >> "$target_file"
    
    show_status "$GREEN" "Function '$name' imported to $target_file"
}

import_menu() {
    while true; do
        draw_header
        echo -e "  ${BOLD}Import Unmanaged Items${RESET}
"
        echo -e "  ${BOLD}1.${RESET} 📋 List Unmanaged Aliases"
        echo -e "  ${BOLD}2.${RESET} 𝑓  List Unmanaged Functions"
        echo -e "  ${BOLD}3.${RESET} 🔙 Back"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        read -p "  Selection [1-3]: " choice
        
        case $choice in
            1)
                draw_header
                echo -e "  ${BOLD}Select Alias to Import:${RESET}
"
                local items=()
                while IFS= read -r line; do
                    [[ -n "$line" ]] && items+=("$line")
                done < <(list_unmanaged_aliases)
                
                if [[ ${#items[@]} -eq 0 ]]; then
                    echo -e "  ${GRAY}(None found)${RESET}"
                    wait_key
                else
                    for i in "${!items[@]}"; do
                        echo -e "  ${BOLD}$((i+1)).${RESET} ${items[$i]}"
                    done
                    read -p "  Number (or 0 for back): " num
                    if [[ "$num" -gt 0 && "$num" -le ${#items[@]} ]]; then
                        import_unmanaged_alias "${items[$((num-1))]}"
                        sleep 1
                    fi
                fi
                ;;
            2)
                draw_header
                echo -e "  ${BOLD}Select Function to Import:${RESET}
"
                local funcs=()
                while IFS= read -r line; do
                    [[ -n "$line" ]] && funcs+=("$line")
                done < <(list_unmanaged_functions)
                
                if [[ ${#funcs[@]} -eq 0 ]]; then
                    echo -e "  ${GRAY}(None found)${RESET}"
                    wait_key
                else
                    for i in "${!funcs[@]}"; do
                        echo -e "  ${BOLD}$((i+1)).${RESET} ${funcs[$i]}"
                    done
                    read -p "  Number (or 0 for back): " num
                    if [[ "$num" -gt 0 && "$num" -le ${#funcs[@]} ]]; then
                        import_unmanaged_function "${funcs[$((num-1))]}"
                        sleep 1
                    fi
                fi
                ;;
            3)
                break
                ;;
        esac
    done
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
    print(f"{a["name"]}	{a["command"]}")
' "$input_file")
    show_status "$GREEN" "Import complete."
}

# --- FUNCTION MANAGEMENT ---
list_managed_functions() {
    if [[ ! -d "$FUNCTIONS_DIR" || -z "$(ls -A "$FUNCTIONS_DIR" 2>/dev/null)" ]]; then
        echo -e "    ${GRAY}(No functions found)${RESET}"
        return
    fi
    for f in "$FUNCTIONS_DIR"/*.bash; do
        local fname=$(basename "$f" .bash)
        echo -e "    ${GREEN}ƒ${RESET} ${fname}"
    done
}

add_managed_function() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        show_status "$RED" "Invalid name."
        return
    fi
    
    local file_path="$FUNCTIONS_DIR/$name.bash"
    if [[ -f "$file_path" ]]; then
        show_status "$RED" "Function '$name' already exists."
        return
    fi
    
    mkdir -p "$FUNCTIONS_DIR"
    cat << EOF > "$file_path"
#!/bin/bash

$name() {
    echo "Hello from $name!"
}
EOF
    
    local editor=${EDITOR:-nano}
    if command -v "$editor" &>/dev/null; then
        $editor "$file_path"
        source "$file_path"
        show_status "$GREEN" "Function '$name' saved and loaded."
    else
        show_status "$YELLOW" "Created at $file_path."
    fi
}

edit_managed_function() {
    local name="$1"
    local file_path="$FUNCTIONS_DIR/$name.bash"
    
    if [[ ! -f "$file_path" ]]; then
        show_status "$RED" "Function file not found."
        return
    fi
    
    local editor=${EDITOR:-nano}
    if command -v "$editor" &>/dev/null; then
        $editor "$file_path"
        source "$file_path"
        show_status "$GREEN" "Function '$name' updated."
    else
        show_status "$RED" "No suitable editor found."
    fi
}

remove_managed_function() {
    local name="$1"
    local file_path="$FUNCTIONS_DIR/$name.bash"
    
    if [[ -f "$file_path" ]]; then
        rm "$file_path"
        unset -f "$name" 2>/dev/null
        show_status "$GREEN" "Function '$name' deleted."
    else
        show_status "$RED" "Function not found."
    fi
}

manage_functions_menu() {
    while true; do
        draw_header
        echo -e "  ${BOLD}Manage Functions${RESET}"
        echo -e "  ${GRAY}Stored in: $FUNCTIONS_DIR${RESET}
"
        
        echo -e "  ${BOLD}1.${RESET} 📋 List Functions"
        echo -e "  ${BOLD}2.${RESET} ➕ Add New Function"
        echo -e "  ${BOLD}3.${RESET} ✏️  Edit Function"
        echo -e "  ${BOLD}4.${RESET} ➖ Remove Function"
        echo -e "  ${BOLD}5.${RESET} 🔙 Back"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        read -p "  Selection [1-5]: " choice
        
        case $choice in
            1)
                draw_header
                echo -e "  ${BOLD}Managed Functions:${RESET}
"
                list_managed_functions
                wait_key
                ;;
            2)
                draw_header
                echo -e "  ${BOLD}Add Function${RESET}"
                read -p "  Enter function name: " name
                [[ -n "$name" ]] && add_managed_function "$name"
                wait_key
                ;;
            3)
                draw_header
                echo -e "  ${BOLD}Edit Function${RESET}"
                read -p "  Enter function name: " name
                [[ -n "$name" ]] && edit_managed_function "$name"
                wait_key
                ;;
            4)
                draw_header
                echo -e "  ${BOLD}Remove Function${RESET}"
                read -p "  Enter function name: " name
                [[ -n "$name" ]] && remove_managed_function "$name"
                wait_key
                ;;
            5)
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
        echo -e "  ${BOLD}4.${RESET} 📥 Import Unmanaged Items"
        echo -e "  ${BOLD}5.${RESET} 💾 Backup to JSON"
        echo -e "  ${BOLD}6.${RESET} 📥 Restore from JSON"
        echo -e "  ${BOLD}7.${RESET} 𝑓  Manage Functions"
        echo -e "  ${BOLD}8.${RESET} 🚪 Exit"
        echo -e "
${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        read -p "  Selection [1-8]: " choice
        
        case $choice in
            1)
                draw_header
                echo -e "  ${BOLD}Current Managed Aliases:${RESET}
"
                list_managed_aliases | while read -r line; do
                    echo -e "    ${GREEN}●${RESET} ${line#alias }"
                done
                wait_key
                ;;
            2)
                draw_header
                echo -e "  ${BOLD}Add New Alias${RESET}"
                read -p "  Enter name: " name
                read -p "  Enter command: " cmd
                [[ -n "$name" && -n "$cmd" ]] && add_managed_alias "$name" "$cmd"
                wait_key
                ;;
            3)
                draw_header
                read -p "  Enter name to remove: " name
                [[ -n "$name" ]] && remove_managed_alias "$name"
                wait_key
                ;;
            4)
                import_menu
                ;;
            5)
                draw_header
                read -p "  Filename [aliases.json]: " bfile
                bfile=${bfile:-aliases.json}
                export_to_json "$bfile"
                wait_key
                ;;
            6)
                draw_header
                read -p "  JSON file to restore: " rfile
                import_from_json "$rfile"
                wait_key
                ;;
            7)
                manage_functions_menu
                ;;
            8)
                echo -e "
  ${CYAN}Happy coding!${RESET}"
                break
                ;;
            *)
                show_status "$RED" "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

# Export all functions
export -f draw_header
export -f show_status
export -f wait_key
export -f manage_aliases
