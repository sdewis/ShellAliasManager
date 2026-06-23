#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-2.0-1}"
PKG="shell-alias-manager_${VERSION}_all"
BUILD="/tmp/${PKG}"

rm -rf "$BUILD"
mkdir -p "$BUILD/DEBIAN"
mkdir -p "$BUILD/usr/bin"
mkdir -p "$BUILD/usr/share/shell-alias-manager/lib"
mkdir -p "$BUILD/usr/share/shell-alias-manager/functions"
mkdir -p "$BUILD/usr/share/shell-alias-manager/bin"

cat > "$BUILD/DEBIAN/control" << EOF
Package: shell-alias-manager
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: all
Maintainer: Sean <sean@example.com>
Depends: bash, python3, curl, coreutils, sed, gawk, grep, iproute2
Description: TUI and CLI for managing Bash and Zsh aliases.
 Modular v2 with backup, placeholders, and shell function toolkit.
EOF

cp "$ROOT/bin/manage-aliases" "$BUILD/usr/share/shell-alias-manager/bin/"
cp -r "$ROOT/lib/"* "$BUILD/usr/share/shell-alias-manager/lib/"
cp "$ROOT/alias_manager.sh" "$ROOT/alias_manager_placeholders.sh" "$ROOT/README.md" \
    "$BUILD/usr/share/shell-alias-manager/"
cp "$ROOT/functions/"*.bash "$BUILD/usr/share/shell-alias-manager/functions/"

cat > "$BUILD/usr/bin/manage-aliases" << 'WRAPPER'
#!/usr/bin/env bash
SHARE_DIR="/usr/share/shell-alias-manager"
USER_DIR="$HOME/.alias_manager"
USER_FUNC_DIR="$USER_DIR/functions"
USER_PLACEHOLDERS="$HOME/.alias_manager_placeholders.sh"

mkdir -p "$USER_FUNC_DIR"

if [[ ! -f "$USER_PLACEHOLDERS" ]]; then
    cp "$SHARE_DIR/alias_manager_placeholders.sh" "$USER_PLACEHOLDERS"
fi

if [[ -z "$(ls -A "$USER_FUNC_DIR" 2>/dev/null)" ]]; then
    cp "$SHARE_DIR/functions/"*.bash "$USER_FUNC_DIR/"
fi

export SAM_ROOT="$SHARE_DIR"
exec "$SHARE_DIR/bin/manage-aliases" "$@"
WRAPPER
chmod +x "$BUILD/usr/bin/manage-aliases" "$BUILD/usr/share/shell-alias-manager/bin/manage-aliases"

cat > "$BUILD/DEBIAN/postinst" << 'POSTINST'
#!/bin/sh
set -e
MARKER="# shell-alias-manager"
RC_FILE="$HOME/.bashrc"
[ -n "$SHELL" ] && case "$SHELL" in */zsh) RC_FILE="$HOME/.zshrc" ;; esac

if ! grep -qF "$MARKER" "$RC_FILE" 2>/dev/null; then
    cat >> "$RC_FILE" << 'EOF'

# shell-alias-manager
export SAM_ROOT="/usr/share/shell-alias-manager"
if [ -f "${SAM_ROOT}/lib/shell-init.sh" ]; then
    . "${SAM_ROOT}/lib/shell-init.sh"
fi
EOF
fi
POSTINST
chmod +x "$BUILD/DEBIAN/postinst"

dpkg-deb --build "$BUILD" "$ROOT/${PKG}.deb"
echo "Built $ROOT/${PKG}.deb"