#!/usr/bin/env bash
# Shell Alias Manager — alias CRUD

sam_list_managed_aliases() {
    grep "$SAM_MANAGED_TAG" "$SAM_CONFIG_FILE" 2>/dev/null | sed "s/ $SAM_MANAGED_TAG//" || true
}

sam_list_unmanaged_aliases() {
    grep "^alias " "$SAM_CONFIG_FILE" 2>/dev/null | grep -v "$SAM_MANAGED_TAG" || true
}

sam_add_managed_alias() {
    local name="$1"
    local cmd="$2"
    local resolved_cmd
    resolved_cmd="$(sam_resolve_placeholders "$cmd")"

    if grep -qE "alias[[:space:]]+${name}=" "$SAM_CONFIG_FILE" 2>/dev/null; then
        echo "Alias '$name' already exists." >&2
        return 1
    fi

    sam_backup_config >/dev/null
    echo "alias $name='$resolved_cmd' $SAM_MANAGED_TAG" >> "$SAM_CONFIG_FILE"
    alias "$name"="$resolved_cmd"
    echo "Added alias '$name'."
}

sam_remove_managed_alias() {
    local name="$1"

    if ! grep -qE "alias[[:space:]]+${name}=.*${SAM_MANAGED_TAG}" "$SAM_CONFIG_FILE" 2>/dev/null; then
        echo "Managed alias '$name' not found." >&2
        return 1
    fi

    sam_backup_config >/dev/null
    local tmp_file
    tmp_file="$(mktemp)"
    grep -vE "alias[[:space:]]+${name}=.*${SAM_MANAGED_TAG}" "$SAM_CONFIG_FILE" > "$tmp_file" || true
    mv "$tmp_file" "$SAM_CONFIG_FILE"
    unalias "$name" 2>/dev/null || true
    echo "Removed alias '$name'."
}

sam_edit_managed_alias() {
    local name="$1"
    local new_cmd="$2"
    local resolved_cmd
    resolved_cmd="$(sam_resolve_placeholders "$new_cmd")"

    if ! grep -qE "alias[[:space:]]+${name}=.*${SAM_MANAGED_TAG}" "$SAM_CONFIG_FILE" 2>/dev/null; then
        echo "Managed alias '$name' not found." >&2
        return 1
    fi

    sam_backup_config >/dev/null
    local tmp_file
    tmp_file="$(mktemp)"
    sed -E "s|^alias[[:space:]]+${name}=.*|alias ${name}='${resolved_cmd}' ${SAM_MANAGED_TAG}|" \
        "$SAM_CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$SAM_CONFIG_FILE"
    alias "$name"="$resolved_cmd"
    echo "Updated alias '$name'."
}

sam_import_unmanaged_alias() {
    local alias_line="$1"
    local name
    name="$(echo "$alias_line" | sed -E 's/alias ([^= ]+)=.*/\1/')"
    sam_backup_config >/dev/null
    sed -i "s/^alias $name=.*/& $SAM_MANAGED_TAG/" "$SAM_CONFIG_FILE"
    echo "Alias '$name' is now managed."
}