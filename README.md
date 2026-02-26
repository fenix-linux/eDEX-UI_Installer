# eDEX-UI Installer

![eDEX-UI](https://fenixlinux.com/images/2021/edexbpytop.jpeg)

**eDEX-UI** is a fullscreen, cross-platform terminal emulator and system monitor that looks and feels like a sci-fi computer interface.

Heavily inspired by the TRON Legacy movie effects (especially the Board Room sequence), the eDEX-UI project was originally meant to be *"DEX-UI with less «art» and more «distributable software»"*. While keeping a futuristic look and feel, it strives to maintain a certain level of functionality and to be usable in real-life scenarios, with the larger goal of bringing science-fiction UXs to the mainstream.

> **Note:** The original eDEX-UI project was [archived in October 2021](https://github.com/GitSquared/edex-ui). This installer uses the [security-patched fork](https://github.com/theelderemo/eDEX-UI-security-patched) which fixes a critical remote command execution vulnerability, with automatic fallback to the original release if needed.

## Supported Architectures

| Architecture | Binary |
|---|---|
| x86_64 (64-bit) | ✅ |
| i386 / i686 (32-bit) | ✅ |
| arm64 / aarch64 | ✅ |
| armv7l | ✅ |

## Install

### Option 1: One-line installer (recommended)

Type or paste this command in your terminal:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/fenix-linux/eDEX-UI_Installer/main/edex-ui_installer.sh)
```

This will open a graphical installer (zenity) that lets you install or uninstall eDEX-UI.

### Option 2: Direct install (x86_64 only)

```bash
git clone https://github.com/fenix-linux/eDEX-UI_Installer
cd eDEX-UI_Installer
bash install.sh
```

## Uninstall

You can uninstall eDEX-UI by running the installer script again — it will detect the existing installation and offer to remove it.

Alternatively, run the standalone uninstaller:

```bash
bash uninstall.sh
```

## Requirements

- `wget` and `curl` — for downloading files
- `zenity` — for the graphical installer dialogs (Option 1 only)
- `git` — for cloning the repo (Option 2 only)
- `xdg-open` — for opening links after installation

## How It Works

1. Detects your system architecture automatically
2. Downloads the AppImage from the [security-patched fork](https://github.com/theelderemo/eDEX-UI-security-patched/releases) (falls back to the [original repo](https://github.com/GitSquared/edex-ui/releases) if unavailable)
3. Places the AppImage in `~/AppImage/` (graphical installer) or `~/` (direct installer)
4. Creates a `.desktop` entry so eDEX-UI appears in your application menu
5. Downloads the application icon

## Links

- 🔒 [eDEX-UI Security Patched Fork](https://github.com/theelderemo/eDEX-UI-security-patched) — actively maintained
- 📦 [eDEX-UI Original Project](https://github.com/GitSquared/edex-ui) — archived (Oct 2021)
- 🐧 [Fenix Linux](https://fenixlinux.com) — by androrama
- 📥 [AppImage Hub](https://appimage.github.io/apps/) — more AppImage applications

## License

See [LICENSE](LICENSE) for details.
