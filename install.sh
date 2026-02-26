#!/bin/bash
#This script is made for Fenix OS Neon, but it should work fine on most distros.
#eDEX-UI 64 bits installer by androrama | fenixlinux.com
#Updated to use v2.2.8 security-patched fork

DOWNLOAD_URL="https://github.com/theelderemo/eDEX-UI-security-patched/releases/download/security-patch/eDEX-UI-Linux-x86_64.AppImage"
FALLBACK_URL="https://github.com/GitSquared/edex-ui/releases/download/v2.2.8/eDEX-UI-Linux-x86_64.AppImage"
APPIMAGE_NAME="eDEX-UI-Linux-x86_64.AppImage"

# Verify git is available
if ! command -v git &>/dev/null; then
    echo "Error: 'git' is required but not installed."
    exit 1
fi
if ! command -v wget &>/dev/null; then
    echo "Error: 'wget' is required but not installed."
    exit 1
fi

cd "$HOME" || { echo "Error: Could not cd to $HOME"; exit 1; }

# Clean previous installation
rm -Rf eDEX-UI_Installer &>/dev/null || true

# Clone installer repo for icon
if ! git clone https://github.com/fenix-linux/eDEX-UI_Installer; then
    echo "ERROR: Failed to clone installer repository. Check your internet connection."
    exit 1
fi
cd eDEX-UI_Installer || { echo "Error: Could not enter eDEX-UI_Installer directory"; exit 1; }

# Install icon
mkdir -p "$HOME/.local/share/icons"
if [ -f edex.png ]; then
    rm -f "$HOME/.local/share/icons/edex.png" 2>/dev/null || true
    cp edex.png "$HOME/.local/share/icons/"
else
    echo "Warning: edex.png not found in repo. Icon will be missing."
fi

# Clean old installations
rm -f "$HOME/$APPIMAGE_NAME" 2>/dev/null || true
rm -f "$HOME/.local/share/applications"/edex-ui*.desktop 2>/dev/null || true

# Download AppImage (try patched fork first, then original)
echo "Downloading eDEX-UI from security-patched fork..."
if ! wget -q "$DOWNLOAD_URL" -O "$APPIMAGE_NAME"; then
    echo "Security-patched fork download failed, trying original repo..."
    if ! wget -q "$FALLBACK_URL" -O "$APPIMAGE_NAME"; then
        echo "ERROR: Failed to download eDEX-UI from both sources."
        cd "$HOME"
        rm -Rf eDEX-UI_Installer &>/dev/null || true
        exit 1
    fi
fi

# Verify download is a real file (not an HTML error page)
file_size=$(stat --printf="%s" "$APPIMAGE_NAME" 2>/dev/null || stat -f%z "$APPIMAGE_NAME" 2>/dev/null || echo "0")
file_size=${file_size:-0}
if [ "$file_size" -lt 1000000 ]; then
    echo "ERROR: Downloaded file is too small (${file_size} bytes). Download may have failed."
    cd "$HOME"
    rm -Rf eDEX-UI_Installer &>/dev/null || true
    exit 1
fi

chmod +x "./$APPIMAGE_NAME" || { echo 'Failed to mark as executable!'; cd "$HOME"; rm -Rf eDEX-UI_Installer &>/dev/null || true; exit 1; }
mv "$APPIMAGE_NAME" "$HOME/"

# Create Desktop Entry
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/edex-ui.desktop" <<EOF
[Desktop Entry]
Name=eDEX-UI 2.2.8
Comment=eDEX-UI terminal sci-fi interface
Exec="$HOME/$APPIMAGE_NAME" %U
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/edex.png
StartupWMClass=eDEX-UI
X-AppImage-Version=2.2.8
Categories=System;
EOF

# Cleanup installer directory
cd "$HOME"
rm -Rf eDEX-UI_Installer &>/dev/null || true
echo "eDEX-UI installed successfully!"
exit 0
