#!/bin/bash

# --- CONFIGURATION ---
REPO_RAW_URL="https://raw.githubusercontent.com/sdewis/ShellAliasManager/main/alias_manager.sh"
REPO_PLACEHOLDERS_URL="https://raw.githubusercontent.com/sdewis/ShellAliasManager/main/alias_manager_placeholders.sh"
INSTALL_PATH="$HOME/.alias_manager.sh"
PLACEHOLDERS_PATH="$HOME/.alias_manager_placeholders.sh"
TARGET_RC="$HOME/.bashrc"

# --- UI COLORS ---
BOLD='\033[1m'
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
BLUE='\033[38;5;39m'
YELLOW='\033[38;5;226m'
RESET='\033[0m'

# --- HELPERS ---
print_step() { echo -e "${BLUE}${BOLD}==>${RESET} ${BOLD}$1${RESET}"; }
print_success() { echo -e "${GREEN}${BOLD}✔${RESET} $1"; }
print_error() { echo -e "${RED}${BOLD}✘${RESET} $1"; exit 1; }

clear
echo -e "${BOLD}${BLUE}"
echo "    🧪 Alias Manager TUI Installer"
echo -e "    ------------------------------${RESET}\n"

# 1. Check Dependencies
print_step "Checking dependencies..."
for cmd in python3 curl grep sed; do
    if ! command -v $cmd &> /dev/null; then
        print_error "$cmd is required but not installed."
    fi
done
print_success "All dependencies met."

# 2. Detect Shell
print_step "Detecting shell environment..."
if [[ "$SHELL" == *"zsh"* ]]; then
    TARGET_RC="$HOME/.zshrc"
    print_success "Zsh detected. Target: $TARGET_RC"
else
    print_success "Bash detected. Target: $TARGET_RC"
fi

# 3. Download / Copy the script
print_step "Installing manager script..."
# Note: If running locally from repo, use 'cp'. If remote, use 'curl'.
if [ -f "alias_manager.sh" ]; then
    cp alias_manager.sh "$INSTALL_PATH"
    [[ -f "alias_manager_placeholders.sh" ]] && cp alias_manager_placeholders.sh "$PLACEHOLDERS_PATH"
else
    curl -sSL "$REPO_RAW_URL" -o "$INSTALL_PATH" || print_error "Failed to download main script."
    curl -sSL "$REPO_PLACEHOLDERS_URL" -o "$PLACEHOLDERS_PATH" || print_error "Failed to download placeholders."
fi
chmod +x "$INSTALL_PATH"
[[ -f "$PLACEHOLDERS_PATH" ]] && chmod +x "$PLACEHOLDERS_PATH"
print_success "Script installed to $INSTALL_PATH"

# 4. Update RC File
print_step "Updating $TARGET_RC..."
BACKUP_RC="$TARGET_RC.backup.$(date +%F_%T)"
cp "$TARGET_RC" "$BACKUP_RC"
echo -e "${GRAY}Backup created at $BACKUP_RC${RESET}"

# Prevent duplicate sourcing
if grep -q "source $INSTALL_PATH" "$TARGET_RC"; then
    print_success "Source entry already exists in $TARGET_RC"
else
    echo -e "\n# Alias Manager TUI\n[[ -f $INSTALL_PATH ]] && source $INSTALL_PATH" >> "$TARGET_RC"
    print_success "Added source entry to $TARGET_RC"
fi

# 5. Finalize
echo -e "\n${GREEN}${BOLD}Installation Complete!${RESET}"
echo -e "----------------------------------------"
echo -e "To start using the manager immediately:"
echo -e "${YELLOW}source $TARGET_RC${RESET}"
echo -e "Then simply type: ${BOLD}${CYAN}manage_aliases${RESET}"
echo -e "----------------------------------------"
