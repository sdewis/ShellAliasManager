#!/usr/bin/env bash
# Shell Alias Manager — prompt enhancer (ported from nushell + SAM palette)

_sam_git_branch_prompt() {
    local branch
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 0
    [[ -z "$branch" || "$branch" == "HEAD" ]] && return 0
    printf '%s(%s)%s ' "${PURPLE}" "$branch" "${RESET}"
}

_sam_build_ps1() {
    local exit_code="$1"
    local branch_part status_color prompt_char

    branch_part="$(_sam_git_branch_prompt)"
    if (( exit_code == 0 )); then
        status_color="${GREEN}"
        prompt_char='$'
    else
        status_color="${RED}"
        prompt_char='✘'
    fi

    PS1="${branch_part}${BLUE}\u@\h${RESET}:${CYAN}\w${RESET} ${status_color}${prompt_char}${RESET} "
}

_sam_set_title() {
    case "${TERM:-}" in
        xterm*|rxvt*|screen*|tmux*)
            printf '\e]0;%s@%s: %s\a' "${USER:-user}" "${HOSTNAME:-host}" "${PWD}"
            ;;
    esac
}

_sam_precmd() {
    local exit_code=$?
    _sam_build_ps1 "$exit_code"
    _sam_set_title

    if [[ -z "${_SAM_WELCOME_SHOWN:-}" ]] && declare -F show_welcome >/dev/null; then
        _SAM_WELCOME_SHOWN=1
        show_welcome
    fi
}

_sam_append_prompt_command "_sam_precmd"

# Set immediately so the first prompt is enhanced (PROMPT_COMMAND updates after each command)
_sam_build_ps1 "${PIPESTATUS[0]:-0}"