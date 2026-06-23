#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAM_ROOT="$SCRIPT_DIR"
SAM_USER_DIR="${SAM_USER_DIR:-$HOME/.alias_manager}"
SAM_FUNCTIONS_DIR="$SAM_USER_DIR/functions"
SAM_PLACEHOLDERS_FILE="${SAM_PLACEHOLDERS_FILE:-$HOME/.alias_manager_placeholders.sh}"
SAM_RC_MARKER="# shell-alias-manager"

detect_rc_file() {
    local shell_name
    shell_name="$(basename "${SHELL:-bash}")"
    case "$shell_name" in
        zsh) echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *) echo "$HOME/.profile" ;;
    esac
}

RC_FILE="$(detect_rc_file)"
INSTALL_PREFIX="${INSTALL_PREFIX:-$HOME/.local}"

echo -e "${CYAN}Shell Alias Manager installer${RESET}"
echo -e "  Source:  ${SAM_ROOT}"
echo -e "  Shell:   ${RC_FILE}"
echo ""

mkdir -p "$SAM_FUNCTIONS_DIR"
mkdir -p "$INSTALL_PREFIX/bin"

if [[ ! -f "$SAM_PLACEHOLDERS_FILE" ]]; then
    cp "$SAM_ROOT/alias_manager_placeholders.sh" "$SAM_PLACEHOLDERS_FILE"
    echo -e "${GREEN}✔${RESET} Installed placeholders → $SAM_PLACEHOLDERS_FILE"
fi

cp "$SAM_ROOT/functions/"*.bash "$SAM_FUNCTIONS_DIR/" 2>/dev/null || true
echo -e "${GREEN}✔${RESET} Synced functions → $SAM_FUNCTIONS_DIR"

ln -sf "$SAM_ROOT/bin/manage-aliases" "$INSTALL_PREFIX/bin/manage-aliases"
chmod +x "$SAM_ROOT/bin/manage-aliases"
echo -e "${GREEN}✔${RESET} Linked manage-aliases → $INSTALL_PREFIX/bin/manage-aliases"

RC_SNIPPET="${SAM_RC_MARKER}
export SAM_ROOT=\"${SAM_ROOT}\"
if [[ -f \"\${SAM_ROOT}/lib/shell-init.sh\" ]]; then
    source \"\${SAM_ROOT}/lib/shell-init.sh\"
fi
"

if grep -qF "$SAM_RC_MARKER" "$RC_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠${RESET} Shell config already contains shell-alias-manager block"
else
    {
        echo ""
        echo "$RC_SNIPPET"
    } >> "$RC_FILE"
    echo -e "${GREEN}✔${RESET} Added startup block to $RC_FILE"
fi

if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
    echo -e "${YELLOW}⚠${RESET} Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo -e "${GREEN}Installation complete.${RESET}"
echo -e "  Run ${CYAN}manage-aliases${RESET} for the TUI"
echo -e "  Run ${CYAN}manage-aliases help${RESET} for CLI usage"
echo -e "  Restart your shell or: ${CYAN}source ${RC_FILE}${RESET}"