#!/usr/bin/env bash
# Shell Alias Manager — JSON export/import

sam_export_to_json() {
    local output_file="$1"
    python3 -c '
import json, sys, re
aliases = []
for line in sys.stdin:
    match = re.search(r"alias (.*?)=\x27(.*?)\x27", line)
    if match:
        aliases.append({"name": match.group(1), "command": match.group(2)})
print(json.dumps(aliases, indent=2))
' < <(sam_list_managed_aliases) > "$output_file"
    echo "Exported to $output_file"
}

sam_import_from_json() {
    local input_file="$1"

    if [[ ! -f "$input_file" ]]; then
        echo "File not found: $input_file" >&2
        return 1
    fi

    local name cmd
    while IFS=$'\t' read -r name cmd; do
        [[ -n "$name" && -n "$cmd" ]] && sam_add_managed_alias "$name" "$cmd" || true
    done < <(python3 -c '
import json, sys
data = json.load(open(sys.argv[1]))
for a in data:
    print("{}\t{}".format(a["name"], a["command"]))
' "$input_file")

    echo "Import complete."
}