#!/usr/bin/env bash
# Legacy dev bootstrap — use install.sh instead
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" "$@"