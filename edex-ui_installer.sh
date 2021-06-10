#!/bin/bash
#This script is made for Fenix OS Neon and Fenix OS *Gamer, but it should work fine on most distros.
#eDEX-UI installer V2 by androrama | fenixlinux.com
#Variables
EDEXCHECKF=$HOME/AppImage/eDEX-UI-Linux-*.AppImage
EDEXCHECKD=$HOME/.local/share/applications/edex-ui.desktop
user=$(logname)
HOME=/home/$user
OLD_HOME="$(echo -n $(bash -c "cd ~${USER} && pwd"))"
if [ `uname -m` = "x86_64" ]; then
    BIN="x86_64"
    elif [ `uname -m` = "i386" ]; then
    BIN="i386"
    elif [ `uname -m` = "armv7l" ]; then
    BIN="armv7l"
    elif [ `uname -m` = "arm64" ]; then
    BIN="arm64"
fi
if [ "$HOME" != "$OLD_HOME" ]; then
    zenity --error --title="Error HOME" --text="You are running this script as root or your home directory doesn't have the same name as your user." --no-wrap
    homeAnswer=$(zenity --entry --text "Please enter the name of your home. Example: pi" --entry-text "$user"); echo New home name = $homeAnswer
    HOME=/home/$homeAnswer
fi
if  [ -f "$EDEXCHECKD" ] || [ -f "$EDEXCHECKF" ]  ; then
  if zenity --question --width=400 --title="Uninstall eDEX-UI" --text="Do you want to uninstall eDEX-UI?"
  then
#Uninstall
    rm -rf $HOME/AppImage/eDEX-UI-Linux-*.AppImage &>/dev/null
	rm -rf $HOME/.local/share/icons/edex.png &>/dev/null &>/dev/null
	rm -rf $HOME/.local/share/applications/edex-ui*.desktop &>/dev/null
	rm -rf $HOME/.config/eDEX-UI &>/dev/null
    echo "eDEX-UI uninstalled."
    exit 1
  fi
    elif zenity --question --width=400 --title="Install eDEX-UI" --text="eDEX-UI is a fullscreen, cross-platform terminal emulator and system monitor that looks and feels like a sci-fi computer interface.\nDo you want to install the eDEX-UI?\n(You can uninstall it executing this script again)."
    then
#Install
    mkdir $HOME/AppImage 
	wget -c https://sourceforge.net/projects/fenixlinux/files/apps/pc/scripts/generic/edex-ui/edex.png   -P ~/.local/share/icons 	|| zenity --error --title="Error" --text="Error, unable to download the desktop icon."
    cd /tmp/
    LATEST=$(curl https://api.github.com/repos/GitSquared/edex-ui/releases/latest | grep "eDEX-UI-Linux-${BIN}.AppImage" | cut -d '"' -f 4 | tail -1) 
    curl -s -LJO $LATEST || zenity --error --title="Error" --text="Error downloading eDEX-UI, check that the file does't exist." --no-wrap
    mv eDEX-UI-Linux* $HOME/AppImage
    chmod +x $HOME/AppImage/eDEX-UI-Linux-${BIN}.AppImage 																			|| zenity --error --title="Error" --text="Failed to mark as executable!"
    fi
#Create Desktop Entry
echo "[Desktop Entry]
Name=eDEX-UI
Comment=eDEX-UI terminal sci-fi interface
Exec="\""$HOME/AppImage/eDEX-UI-Linux-${BIN}.AppImage"\"" %U
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/edex.png
StartupWMClass=eDEX-UI
X-AppImage-Version=2.2.7
Categories=System;" > ~/.local/share/applications/edex-ui.desktop
#Support
    if zenity --info  --width=400 \
    --text="That's all, don't forget to support the developers of these amazing applications if you like them.\nMany developers abandon their projects because they can't have a hobby while taking care of their families, especially now.\nIt is also important that developers feel like their work is meaningful with messages of support.\nIf there were more people thanking in any way the developers who make free software a lot of proprietary software would have its days counted."
        then
    xdg-open 'https://github.com/GitSquared/edex-ui/releases' &>/dev/null
    xdg-open 'https://fenixlinux.com/pdownload'               &>/dev/null
    fi
exit 0
