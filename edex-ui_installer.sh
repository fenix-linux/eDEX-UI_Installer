#!/bin/bash
#This script is made for Fenix OS Neon and Fenix OS *Gamer, but it should work fine on most distros.
#eDEX-UI installer V3 by androrama | fenixlinux.com
#Updated to use the security-patched fork (theelderemo/eDEX-UI-security-patched)

#------- Dependency check -------
missing_deps=()
for cmd in wget curl zenity xdg-open; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_deps+=("$cmd")
    fi
done
if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Error: The following required tools are not installed: ${missing_deps[*]}"
    echo "Please install them and try again."
    exit 1
fi

#------- Resolve user and HOME -------
# logname returns the real logged-in user (even under sudo)
# whoami / $USER returns the effective user (root under sudo)
real_user=""
if real_user=$(logname 2>/dev/null) && [ -n "$real_user" ]; then
    :
else
    real_user="${SUDO_USER:-${USER:-$(whoami)}}"
fi

effective_user="$(whoami)"

# Resolve HOME safely via getent (avoids eval injection risk)
resolve_home() {
    local u="$1"
    local result=""
    if command -v getent &>/dev/null; then
        result=$(getent passwd "$u" 2>/dev/null | cut -d: -f6)
    fi
    # Fallback if getent not available or user not in passwd
    echo "${result:-/home/$u}"
}

HOME=$(resolve_home "$real_user")

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)        BIN="x86_64"  ;;
    i386|i686)     BIN="i386"    ;;
    armv7l)        BIN="armv7l"  ;;
    arm64|aarch64) BIN="arm64"   ;;
    *)
        zenity --error --title="Error" --text="Unsupported architecture: ${ARCH}" --no-wrap
        exit 1
        ;;
esac

APPIMAGE_DIR="$HOME/AppImage"
ICONS_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
CONFIG_DIR="$HOME/.config/eDEX-UI"
APPIMAGE_NAME="eDEX-UI-Linux-${BIN}.AppImage"
DESKTOP_FILE="$DESKTOP_DIR/edex-ui.desktop"
ICON_FILE="$ICONS_DIR/edex.png"

REPO_PRIMARY="theelderemo/eDEX-UI-security-patched"
REPO_FALLBACK="GitSquared/edex-ui"

#------- Root / sudo detection -------
# Detect if running as root or via sudo (real user != effective user)
if [ "$real_user" != "$effective_user" ] || [ "$(id -u)" -eq 0 ]; then
    zenity --warning --title="Running as root" --text="You appear to be running this script as root or via sudo.\nThe application will be installed for user: $real_user ($HOME)" --no-wrap
    if [ ! -d "$HOME" ]; then
        homeAnswer=$(zenity --entry --text "Home directory $HOME does not exist.\nPlease enter the correct username. Example: pi" --entry-text "$real_user") || true
        if [ -z "${homeAnswer:-}" ]; then
            echo "No username provided. Aborting."
            exit 1
        fi
        HOME=$(resolve_home "$homeAnswer")
        if [ ! -d "$HOME" ]; then
            zenity --error --title="Error" --text="Directory $HOME does not exist. Aborting." --no-wrap
            exit 1
        fi
        real_user="$homeAnswer"
        # Update paths after HOME change
        APPIMAGE_DIR="$HOME/AppImage"
        ICONS_DIR="$HOME/.local/share/icons"
        DESKTOP_DIR="$HOME/.local/share/applications"
        CONFIG_DIR="$HOME/.config/eDEX-UI"
        DESKTOP_FILE="$DESKTOP_DIR/edex-ui.desktop"
        ICON_FILE="$ICONS_DIR/edex.png"
    fi
fi

#------- Helper functions -------
create_desktop_entry() {
    mkdir -p "$DESKTOP_DIR"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=eDEX-UI
Comment=eDEX-UI terminal sci-fi interface
Exec="$APPIMAGE_DIR/$APPIMAGE_NAME" --no-sandbox %U
Terminal=false
Type=Application
Icon=$ICON_FILE
StartupWMClass=eDEX-UI
X-AppImage-Version=2.2.8-patched
Categories=System;
EOF
}

get_download_url() {
    local repo="$1"
    # grep returns exit 1 when no match — use "|| true" to prevent pipefail from killing the script
    local url
    url=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" \
        | { grep "browser_download_url" || true; } \
        | { grep "$APPIMAGE_NAME" || true; } \
        | cut -d '"' -f 4 \
        | tail -1)
    echo "$url"
}

show_support_message() {
    if zenity --info --width=400 \
        --text="eDEX-UI installed successfully!\nYou can find it in your application menu.\n\nIf you enjoy this app, consider supporting the developers:\n- Star the project on GitHub\n- Leave a thank-you message\n- Buy them a coffee\n\nFree software lives thanks to people like you."
    then
        xdg-open "https://github.com/${REPO_PRIMARY}/releases" &>/dev/null || true
        xdg-open 'https://fenixlinux.com/pdownload' &>/dev/null || true
    fi
}

cleanup_partial() {
    rm -f "/tmp/$APPIMAGE_NAME" 2>/dev/null
}

#------- Check if already installed -------
# Use ls to check for globs safely (avoids "too many arguments" with -f and multiple matches)
is_installed=false
if [ -f "$DESKTOP_FILE" ]; then
    is_installed=true
elif ls "$APPIMAGE_DIR"/eDEX-UI-Linux-*.AppImage &>/dev/null 2>&1; then
    is_installed=true
fi

if [ "$is_installed" = true ]; then
    if zenity --question --width=400 --title="Uninstall eDEX-UI" --text="eDEX-UI is already installed.\nDo you want to uninstall it?"; then
        # Uninstall
        rm -f "$APPIMAGE_DIR"/eDEX-UI-Linux-*.AppImage 2>/dev/null || true
        rm -f "$ICON_FILE" 2>/dev/null || true
        rm -f "$DESKTOP_DIR"/edex-ui*.desktop 2>/dev/null || true
        rm -rf "$CONFIG_DIR" 2>/dev/null || true
        zenity --info --title="eDEX-UI" --text="eDEX-UI has been uninstalled successfully." --no-wrap
    fi
    exit 0
fi

#------- Install -------
if ! zenity --question --width=400 --title="Install eDEX-UI" --text="eDEX-UI is a fullscreen, cross-platform terminal emulator and system monitor that looks and feels like a sci-fi computer interface.\n\nThis installer uses the security-patched fork.\n\nDo you want to install eDEX-UI?\n(You can uninstall it by executing this script again)."; then
    exit 0
fi

mkdir -p "$APPIMAGE_DIR"
mkdir -p "$ICONS_DIR"

# Download icon (non-critical — warn but continue)
if ! wget -q "https://raw.githubusercontent.com/fenix-linux/eDEX-UI_Installer/main/edex.png" -O "$ICON_FILE"; then
    zenity --warning --title="Warning" --text="Could not download the desktop icon.\nThe application will still work, but may not show an icon." --no-wrap
fi

# Get download URL (try security-patched fork first, then original)
LATEST=$(get_download_url "$REPO_PRIMARY")
if [ -z "$LATEST" ]; then
    zenity --warning --title="Warning" --text="Could not find download URL from security-patched fork for ${BIN}.\nFalling back to original repo..." --no-wrap
    LATEST=$(get_download_url "$REPO_FALLBACK")
fi

if [ -z "$LATEST" ]; then
    zenity --error --title="Error" --text="Error: Could not find a download URL for eDEX-UI (${BIN}).\nPlease check your internet connection and try again." --no-wrap
    exit 1
fi

# Download AppImage to /tmp with cleanup trap for partial downloads
trap cleanup_partial EXIT
cd /tmp/
rm -f "$APPIMAGE_NAME" 2>/dev/null || true

if ! curl -fL -o "$APPIMAGE_NAME" "$LATEST"; then
    zenity --error --title="Error" --text="Error downloading eDEX-UI.\nPlease check your internet connection." --no-wrap
    exit 1
fi

# Verify download is not empty / not an HTML error page
file_size=$(stat --printf="%s" "$APPIMAGE_NAME" 2>/dev/null || stat -f%z "$APPIMAGE_NAME" 2>/dev/null || echo "0")
file_size=${file_size:-0}
if [ "$file_size" -lt 1000000 ]; then
    zenity --error --title="Error" --text="Downloaded file is too small (${file_size} bytes).\nThe download may have failed or returned an error page." --no-wrap
    exit 1
fi

# Move to final location and make executable
mv "$APPIMAGE_NAME" "$APPIMAGE_DIR/"
trap - EXIT  # Clear cleanup trap — file is now in place
chmod +x "$APPIMAGE_DIR/$APPIMAGE_NAME" || {
    zenity --error --title="Error" --text="Failed to mark as executable!"
    exit 1
}

# Create Desktop Entry
create_desktop_entry

# Support message
show_support_message

exit 0
