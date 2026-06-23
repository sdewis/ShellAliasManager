#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
PASS=0
FAIL=0

cleanup() { rm -rf "$TMP_HOME"; }
trap cleanup EXIT

export HOME="$TMP_HOME"
export SAM_CONFIG_FILE="$TMP_HOME/.bashrc"
export SAM_USER_DIR="$TMP_HOME/.alias_manager"
export SAM_PLACEHOLDERS_FILE="$TMP_HOME/.alias_manager_placeholders.sh"
touch "$SAM_CONFIG_FILE"
cp "$ROOT/alias_manager_placeholders.sh" "$SAM_PLACEHOLDERS_FILE"

# shellcheck source=lib/init.sh
source "$ROOT/lib/init.sh"

assert() {
    local desc="$1"
    shift
    if "$@"; then
        echo "PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

assert_fails() {
    local desc="$1"
    shift
    if ! "$@"; then
        echo "PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

assert "add alias" sam_add_managed_alias testalias 'echo hello'
assert "alias in config" grep -q 'testalias' "$SAM_CONFIG_FILE"
assert "list contains alias" grep -q 'testalias' < <(sam_list_managed_aliases)
assert "edit alias" sam_edit_managed_alias testalias 'echo world'
assert "edited command present" grep -q "echo world" "$SAM_CONFIG_FILE"
assert "remove alias" sam_remove_managed_alias testalias
assert_fails "alias removed" grep -q 'testalias' "$SAM_CONFIG_FILE"

resolved="$(sam_resolve_placeholders 'branch:{git_branch}')"
assert "placeholder resolves" test "${resolved#*get_git_branch}" != "$resolved"

EXPORT="$TMP_HOME/out.json"
sam_add_managed_alias snap 'echo snap'
sam_export_to_json "$EXPORT"
assert "export creates json" test -f "$EXPORT"
assert "json has name" grep -q '"name": "snap"' "$EXPORT"

sam_remove_managed_alias snap
sam_import_from_json "$EXPORT"
assert "import restores alias" grep -q 'snap' "$SAM_CONFIG_FILE"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]