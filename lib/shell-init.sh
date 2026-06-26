#!/usr/bin/env bash
# Shell Alias Manager — lightweight shell startup (colors, placeholders, functions)

if [[ -n "${_SAM_SHELL_INIT_DONE:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
_SAM_SHELL_INIT_DONE=1

_sam_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/config.sh
source "$_sam_lib_dir/config.sh"
# shellcheck source=lib/colors.sh
source "$_sam_lib_dir/colors.sh"
# shellcheck source=lib/placeholders.sh
source "$_sam_lib_dir/placeholders.sh"
# shellcheck source=lib/shell-functions.sh
source "$_sam_lib_dir/shell-functions.sh"
# shellcheck source=lib/history.sh
source "$_sam_lib_dir/history.sh"
# shellcheck source=lib/prompt.sh
source "$_sam_lib_dir/prompt.sh"

sam_load_placeholders
sam_load_user_functions