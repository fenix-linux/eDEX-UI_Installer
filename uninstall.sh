#!/bin/bash
#eDEX-UI uninstaller by androrama | fenixlinux.com

# Resolve home safely (avoid eval — injection risk)
if [ -z "${HOME:-}" ]; then
    if command -v getent &>/dev/null; then
        HOME=$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f6)
    else
        HOME="/home/$(whoami)"
    fi
fi

cd "$HOME" || exit 1

echo "Uninstalling eDEX-UI..."

# Remove AppImage from both possible locations
rm -f "$HOME/eDEX-UI-Linux-"*.AppImage 2>/dev/null
rm -f "$HOME/AppImage/eDEX-UI-Linux-"*.AppImage 2>/dev/null

# Remove icon
rm -f "$HOME/.local/share/icons/edex.png" 2>/dev/null

# Remove all desktop entries (any version)
rm -f "$HOME/.local/share/applications"/edex-ui*.desktop 2>/dev/null

# Remove config directory
rm -rf "$HOME/.config/eDEX-UI" 2>/dev/null

echo "eDEX-UI uninstalled successfully."

# Remove this script (must be last)
SELF="$(readlink -f "$0" 2>/dev/null || echo "$0")"
rm -f "$SELF" 2>/dev/null
