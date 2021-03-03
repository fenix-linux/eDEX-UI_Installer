#!/bin/bash
#This script is made for Fenix OS Neon, but it should work fine on most distros.
#eDEX-UI 64 bits installer by androrama | fenixlinux.com
cd
rm -Rf eDEX-UI_Installer &>/dev/null
git clone https://github.com/fenixlinuxos/eDEX-UI_Installer
cd eDEX-UI_Installer
rm ../.local/share/icons/edex.png &>/dev/null
mv edex.png ../.local/share/icons &>/dev/null
rm -rf ../eDEX-UI-Linux-x86_64.AppImage &>/dev/null
rm -rf ~/.local/share/applications/edex-ui-2.2.5.desktop &>/dev/null
wget https://github.com/GitSquared/edex-ui/releases/download/v2.2.5/eDEX-UI-Linux-x86_64.AppImage || error 'Failed to download'
chmod +x ./'eDEX-UI-Linux-x86_64.AppImage' || error 'Failed to mark as executable!'
mv eDEX-UI-Linux-x86_64.AppImage ../.

echo "[Desktop Entry]
Name=eDEX-UI 2.2.5
Comment=eDEX-UI terminal sci-fi interface
Exec="\""$HOME/eDEX-UI-Linux-x86_64.AppImage"\"" %U
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/edex.png
StartupWMClass=eDEX-UI
X-AppImage-Version=2.2.5
Categories=System;" > ~/.local/share/applications/edex-ui-2.2.5.desktop

rm -Rf ../eDEX-UI_Installer &>/dev/null
exit 0
