#!/usr/bin/env bash
# Shell Alias Manager — managed shell function files

sam_list_unmanaged_functions() {
    grep -E "^[a-zA-Z0-9_]+\(\) *\{|^function [a-zA-Z0-9_]+" "$SAM_CONFIG_FILE" 2>/dev/null || true
}

sam_list_managed_functions() {
    if [[ ! -d "$SAM_FUNCTIONS_DIR" || -z "$(ls -A "$SAM_FUNCTIONS_DIR" 2>/dev/null)" ]]; then
        return 0
    fi
    local f fname
    for f in "$SAM_FUNCTIONS_DIR"/*.bash; do
        [[ -f "$f" ]] || continue
        fname="$(basename "$f" .bash)"
        echo "$fname"
    done
}

sam_add_managed_function() {
    local name="$1"

    if [[ ! "$name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid function name." >&2
        return 1
    fi

    local file_path="$SAM_FUNCTIONS_DIR/$name.bash"
    if [[ -f "$file_path" ]]; then
        echo "Function '$name' already exists." >&2
        return 1
    fi

    sam_ensure_dirs
    cat << EOF > "$file_path"
#!/usr/bin/env bash

$name() {
    echo "Hello from $name!"
}
EOF

    local editor="${EDITOR:-nano}"
    if command -v "$editor" &>/dev/null; then
        "$editor" "$file_path"
        # shellcheck source=/dev/null
        source "$file_path"
        echo "Function '$name' saved and loaded."
    else
        echo "Created at $file_path (set EDITOR to edit)."
    fi
}

sam_edit_managed_function() {
    local name="$1"
    local file_path="$SAM_FUNCTIONS_DIR/$name.bash"

    if [[ ! -f "$file_path" ]]; then
        echo "Function file not found." >&2
        return 1
    fi

    local editor="${EDITOR:-nano}"
    if command -v "$editor" &>/dev/null; then
        "$editor" "$file_path"
        # shellcheck source=/dev/null
        source "$file_path"
        echo "Function '$name' updated."
    else
        echo "No suitable editor found." >&2
        return 1
    fi
}

sam_remove_managed_function() {
    local name="$1"
    local file_path="$SAM_FUNCTIONS_DIR/$name.bash"

    if [[ -f "$file_path" ]]; then
        rm "$file_path"
        unset -f "$name" 2>/dev/null || true
        echo "Function '$name' deleted."
    else
        echo "Function not found." >&2
        return 1
    fi
}

sam_import_unmanaged_function() {
    local func_sig="$1"
    local name
    name="$(echo "$func_sig" | sed -E 's/^function ([^ (]+).*/\1/; s/^([^ (]+)\(\).*/\1/')"

    local target_file="$SAM_FUNCTIONS_DIR/$name.bash"
    if [[ -f "$target_file" ]]; then
        echo "Function file already exists at $target_file" >&2
        return 1
    fi

    sam_ensure_dirs
    {
        echo "#!/usr/bin/env bash"
        echo ""
        sed -n "/^$name/,/^}/p" "$SAM_CONFIG_FILE"
    } > "$target_file"

    echo "Function '$name' imported to $target_file"
}

sam_load_user_functions() {
    if [[ ! -d "$SAM_FUNCTIONS_DIR" ]]; then
        return 0
    fi
    local f
    for f in "$SAM_FUNCTIONS_DIR"/*.bash; do
        [[ -f "$f" ]] && source "$f"
    done
}