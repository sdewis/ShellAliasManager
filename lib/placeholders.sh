#!/usr/bin/env bash
# Shell Alias Manager — dynamic placeholder resolution

sam_load_placeholders() {
    if [[ -f "$SAM_PLACEHOLDERS_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$SAM_PLACEHOLDERS_FILE"
    elif [[ -f "$SAM_ROOT/alias_manager_placeholders.sh" ]]; then
        # shellcheck source=/dev/null
        source "$SAM_ROOT/alias_manager_placeholders.sh"
    fi
}

sam_resolve_placeholders() {
    local input="$1"

    if [[ -f "$SAM_PLACEHOLDERS_FILE" && -n "${MANAGED_PLACEHOLDERS[*]:-}" ]]; then
        local entry tag func
        for entry in "${MANAGED_PLACEHOLDERS[@]}"; do
            tag="${entry%%:*}"
            func="${entry#*:}"
            if [[ "$input" == *"$tag"* ]]; then
                input="${input//"$tag"/'$('"'"$func"'"')'}"
            fi
        done
    fi

    echo "$input"
}

sam_list_placeholders() {
    if [[ -z "${MANAGED_PLACEHOLDERS[*]:-}" ]]; then
        echo "No placeholders configured."
        return 0
    fi
    local entry
    for entry in "${MANAGED_PLACEHOLDERS[@]}"; do
        printf '  %s → %s()\n' "${entry%%:*}" "${entry#*:}"
    done
}