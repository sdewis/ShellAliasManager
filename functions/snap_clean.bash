#!/usr/bin/env bash

snap_clean() {
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Not inside a git repository." >&2
        return 1
    fi

    local count=0 branch
    while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue
        if git branch -D "$branch" &>/dev/null; then
            echo "Removed $branch"
            count=$((count + 1))
        fi
    done < <(git branch --list 'gsnap/*' | sed 's/^[* ] //')

    echo -e "${GREEN}Cleaned ${count} gsnap branch(es).${RESET}"
}