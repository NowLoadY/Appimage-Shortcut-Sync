# AppImage Desktop Shortcut Manager


> One-click management of AppImage desktop shortcuts - Auto-extract icons, create shortcuts, and clean invalid entries

[![License](https://img.shields.io/badge/license-MIT-green.svg)](#)
[![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)](#)
[![Shell](https://img.shields.io/badge/shell-Bash-green.svg)](#)

## TO DO LIST

Desktop Shortcut Manager with GUI

---

## Quick Start

### 1️⃣ Download Scripts

Place `appimage-shortcut-sync.sh` in your AppImage directory:

```bash
# Example: ~/appinstall/ directory
cd ~/appinstall
# Ensure scripts are executable
chmod +x *.sh
```

### 2️⃣ Run Sync Tool

```bash
./appimage-shortcut-sync.sh
```

### 3️⃣ Select Operation

```
AppImage files needing shortcuts (5):
   [0] App1.AppImage
   [1] App2.AppImage
   ...

Select an operation:
   [a] Create all
   [number] Create specific items (space-separated, e.g.: 0 2 4)
   [s] Skip, don't create any shortcuts

👉 Your choice: a
```

### 4️⃣ Done!

Now you can launch your AppImage applications from desktop or application menu.

---

## Usage Guide

```bash
# Method 1: Script in AppImage directory (Recommended)
cd ~/appinstall
./appimage-shortcut-sync.sh
```

```bash
# Method 2: Specify directory from anywhere
./appimage-shortcut-sync.sh ~/appinstall
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Thanks to [AppImage Project](https://appimage.org/) for providing portable application solutions
- Thanks to [GNOME Project](https://www.gnome.org/) and [DING Extension](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)
- Thanks to all contributors and users for their feedback

---

<p align="center">
  Made with ❤️ for Linux AppImage users
</p>
