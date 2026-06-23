#!/usr/bin/env bash

gsnap() {
    local msg="${1:-snapshot $(date +%Y-%m-%d_%H:%M)}"
    local branch="gsnap/$(date +%Y%m%d-%H%M%S)"

    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Not inside a git repository." >&2
        return 1
    fi

    local previous
    previous="$(git branch --show-current 2>/dev/null || true)"

    git checkout -b "$branch"
    git add -A
    if git diff --cached --quiet; then
        echo "Nothing to snapshot."
        [[ -n "$previous" ]] && git checkout "$previous" 2>/dev/null || true
        git branch -D "$branch" &>/dev/null || true
        return 0
    fi

    git commit -m "$msg"
    [[ -n "$previous" ]] && git checkout "$previous" 2>/dev/null || git checkout - 2>/dev/null || true
    echo -e "${GREEN}Snapshot saved on branch:${RESET} $branch"
}