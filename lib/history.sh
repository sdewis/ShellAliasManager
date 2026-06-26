#!/usr/bin/env bash
# Shell Alias Manager — history settings (ported from ~/.config/nushell/config.nu)

# nu: $env.config.history.max_size = 2000
# nu: $env.config.history.ignore_space_prefixed = true  →  HISTCONTROL=ignoreboth (ignorespace)
HISTSIZE=2000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth
shopt -s histappend

# Sync history across concurrent shell sessions (nu persists every command automatically)
_sam_history_sync() {
    history -a
    history -n
}

_sam_append_prompt_command() {
    local hook="$1"
    case "${PROMPT_COMMAND:-}" in
        *"$hook"*) return 0 ;;
    esac
    if [[ -z "${PROMPT_COMMAND:-}" ]]; then
        PROMPT_COMMAND="$hook"
    else
        PROMPT_COMMAND="$hook; $PROMPT_COMMAND"
    fi
}

_sam_append_prompt_command "_sam_history_sync"

# One-time / on-demand merge of nushell plain-text history into bash
sam_merge_nu_history() {
    local nu_hist="${NU_HISTORY_FILE:-$HOME/.config/nushell/history.txt}"
    local bash_hist="${HISTFILE:-$HOME/.bash_history}"

    if [[ ! -f "$nu_hist" ]]; then
        echo "No nushell history at $nu_hist" >&2
        return 1
    fi

    local merged=0 skipped=0
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue

        # Skip nu-only meta commands and exploration noise
        case "$line" in
            \$env.*|config\ *|explore\ *|history\ import*|history\ help*|help\ *|cat\ ~/.bash_history)
                ((skipped++)) || true
                continue
                ;;
        esac

        if ! grep -Fxq "$line" "$bash_hist" 2>/dev/null; then
            printf '%s\n' "$line" >> "$bash_hist"
            ((merged++)) || true
        else
            ((skipped++)) || true
        fi
    done < "$nu_hist"

    history -r 2>/dev/null || true
    echo "Merged $merged command(s) from nushell history ($skipped skipped/duplicate)."
}