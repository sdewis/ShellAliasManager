#!/bin/bash

# --- CONFIGURATION (Calibrated to /home/sean) ---
PROJECT_DIR="$HOME/CodeFolder/ShellAliasManager"
INSTALL_PATH="$HOME/.alias_manager.sh"
FUNCTIONS_DIR="$HOME/.alias_manager/functions"
TARGET_RC="$HOME/.bashrc"
SSH_KEY="$HOME/.ssh/id_ed25519"

# --- UI COLORS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;226m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

print_status() { echo -e "${BLUE}==>${RESET} $1"; }

clear
echo -e "${PURPLE}🛠️  PHOENIX ULTIMATE v3.5 - GOD-MODE CALIBRATED${RESET}"
echo -e "${CYAN}--------------------------------------------------${RESET}\n"

# 1. SETUP REPO CONTEXT
if [ ! -d "$PROJECT_DIR" ]; then
    print_status "Project not found at $PROJECT_DIR. Creating it..."
    mkdir -p "$PROJECT_DIR/functions"
fi
cd "$PROJECT_DIR" || exit

# 2. SSH & IDENTITY
if [[ -z "$(git config --global user.email)" ]]; then
    read -p "  Enter Git Email: " git_email
    git config --global user.email "$git_email"
    git config --global user.name "Sean"
fi

# 3. INJECT REFINED FUNCTIONS
print_status "Forging function vault..."

# --- Function: todo & done (Local Context Tasking) ---
cat << 'EOF' > "$PROJECT_DIR/functions/todo.bash"
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
EOF

# --- Function: ai_start (The Gemini Scraper) ---
cat << 'EOF' > "$PROJECT_DIR/functions/ai_start.bash"
ai_start() {
    local p_name=$(basename "$(pwd)")
    cat << PROMPT > AI_SESSION.md
# SYSTEM ROLE: Elite Architect
# CONTEXT: Working in $(pwd)

# LOCAL TODOs (Handed off to AI)
$( [[ -f .todo ]] && cat .todo || echo "No manual tasks." )

# PROJECT STRUCTURE
$(ls -F | head -n 15)

# INSTRUCTIONS:
Analyze the TODOs and current files. Propose a plan for the next step.
PROMPT
    echo -e "${PURPLE}✔ AI_SESSION.md created with local context.${RESET}"
}
EOF

# --- Function: sync_backup (Private Repo Sync) ---
cat << 'EOF' > "$PROJECT_DIR/functions/sync_backup.bash"
sync_backup() {
    print_status "Checking backup health..."
    local last_push=$(git log -1 --format=%ct 2>/dev/null || echo 0)
    local diff=$(( ($(date +%s) - last_push) / 86400 ))

    [[ "$diff" -ge 3 ]] && echo -e "${YELLOW}⚠️  Backup is $diff days old!${RESET}"

    git add . && git commit -m "Auto-sync: $(date)" && git push origin main
    echo -e "${GREEN}✔ Private backup synced successfully.${RESET}"
}
EOF

# --- Function: welcome (The Custom Dashboard) ---
cat << 'EOF' > "$PROJECT_DIR/functions/welcome.bash"
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
EOF

# --- [gsnap.bash, pscan.bash, hgrep.bash, etc. follow here] ---

# 4. INSTALL & CONFIGURE BASHRC
print_status "Installing to $HOME..."
mkdir -p "$FUNCTIONS_DIR"
cp "$PROJECT_DIR/alias_manager.sh" "$INSTALL_PATH" 2>/dev/null
cp "$PROJECT_DIR/functions/"*.bash "$FUNCTIONS_DIR/"

if ! grep -q "show_welcome" "$TARGET_RC"; then
    cat << 'EOF' >> "$TARGET_RC"
# --- GOD-MODE SUITE ---
shopt -s autocd cdspell
alias ..="cd .."
alias ll="ls -lah --color=auto"
[[ -f ~/.alias_manager.sh ]] && source ~/.alias_manager.sh
show_welcome
EOF
fi

# 5. PUSH TO GITHUB
print_status "Backing up to GitHub..."
git add .
git commit -m "V3.5 Calibrated: /home/sean structure integrated"
git push origin main

echo -e "\n${GREEN}✨ REBORN V3.5 COMPLETE!${RESET}"
echo -e "Your functions are now safely stored in ${YELLOW}$PROJECT_DIR${RESET}"
