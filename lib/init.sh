#!/usr/bin/env bash
# Shell Alias Manager — load all modules (TUI / CLI)

_sam_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/config.sh
source "$_sam_lib_dir/config.sh"
# shellcheck source=lib/colors.sh
source "$_sam_lib_dir/colors.sh"
# shellcheck source=lib/placeholders.sh
source "$_sam_lib_dir/placeholders.sh"
# shellcheck source=lib/aliases.sh
source "$_sam_lib_dir/aliases.sh"
# shellcheck source=lib/shell-functions.sh
source "$_sam_lib_dir/shell-functions.sh"
# shellcheck source=lib/backup.sh
source "$_sam_lib_dir/backup.sh"
# shellcheck source=lib/ui.sh
source "$_sam_lib_dir/ui.sh"

sam_load_placeholders
sam_ensure_dirs