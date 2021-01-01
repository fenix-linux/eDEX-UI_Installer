#!/bin/bash

cd
rm -R eDEX-UI_Installer
git clone https://github.com/fenixlinuxos/eDEX-UI_Installer
cd eDEX-UI_Installer
mv edex.png ../.local/share/icons
rm -rf eDEX-UI-Linux-x86_64.AppImage &>/dev/null
rm -rf ~/.local/share/applications/appimagekit-edex-ui-3.desktop &>/dev/null
wget https://github.com/GitSquared/edex-ui/releases/download/v2.2.5/eDEX-UI-Linux-x86_64.AppImage || error 'Failed to download'
chmod +x ./'eDEX-UI-Linux-x86_64.AppImage' || error 'Failed to mark as executable!'
mv eDEX-UI-Linux-x86_64.AppImage ../.

echo "[Desktop Entry]
Name=eDEX-UI 3.0.0
Comment=eDEX-UI sci-fi interface
Exec="\""$HOME/eDEX-UI-Linux-x86_64.AppImage"\"" %U
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/edex.png
StartupWMClass=eDEX-UI
X-AppImage-Version=3.0.0
Categories=System;" > ~/.local/share/applications/appimagekit-edex-ui-3.desktop

rm -R ../eDEX-UI_Installer