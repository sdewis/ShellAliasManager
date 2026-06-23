#!/usr/bin/env bash
# Backward-compatible entry point (v1.x installs source this file)

_sam_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SAM_ROOT="$_sam_script_dir"

# shellcheck source=lib/init.sh
source "$SAM_ROOT/lib/init.sh"

# Legacy function names used by older docs/packaging
list_managed_aliases() { sam_list_managed_aliases; }
add_managed_alias() { sam_add_managed_alias "$@"; }
remove_managed_alias() { sam_remove_managed_alias "$@"; }
resolve_placeholders() { sam_resolve_placeholders "$@"; }
draw_header() { sam_draw_header; }
show_status() { sam_show_status "$@"; }
wait_key() { sam_wait_key; }

export -f manage_aliases 2>/dev/null || true