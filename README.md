# AppImage Desktop Shortcut Manager

> One-click management of AppImage desktop shortcuts - Auto-extract icons, create shortcuts, and clean invalid entries

[![License](https://img.shields.io/badge/license-MIT-green.svg)](#)
[![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)](#)
[![Shell](https://img.shields.io/badge/shell-Bash-green.svg)](#)

## 📖 Table of Contents

- [Introduction](#introduction)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
- [How It Works](#how-it-works)
- [FAQ](#faq)
- [Advanced Usage](#advanced-usage)
- [System Requirements](#system-requirements)
- [Technical Details](#technical-details)

---

## Introduction

A desktop shortcut management tool designed for Linux (Ubuntu/GNOME) users, solving the pain point of AppImage lacking desktop integration.

### Why Do You Need This Tool?

While AppImage provides "out-of-the-box" portability, it lacks system integration:
- ❌ No automatic desktop shortcut creation
- ❌ Not shown in application menus
- ❌ Must find and double-click the file in file manager each time
- ❌ Shortcuts become "zombies" after deleting AppImage files

### What Does This Tool Do?

✅ **One-Click Creation** - Auto-extract icons, create desktop and menu shortcuts  
✅ **Smart Sync** - Automatically clean invalid shortcuts, detect new AppImage files  
✅ **Perfect Integration** - Use AppImage like installed packages, launch from desktop and app menu  
✅ **Simple & Efficient** - Place script in AppImage directory, one command does everything  

---

## Key Features

### 🎯 Main Features

| Feature | Description |
|---------|-------------|
| 🖼️ **Auto Extract Icons** | Extract high-resolution icons from AppImage (priority 256x256px) |
| 🖥️ **Create Desktop Shortcuts** | Create double-click launchable icons on Ubuntu desktop |
| 📱 **Integrate App Menu** | Show in application launcher like native apps |
| 🔐 **Auto Set Permissions** | Set executable permissions and trust marks, solve GNOME security warnings |
| 🧹 **Smart Clean Invalid Entries** | Automatically detect and remove shortcuts pointing to non-existent files |
| 🔄 **Batch Processing** | Process multiple AppImage files at once |
| 🎨 **Icon Cache Update** | Automatically refresh system icon and application database |

### 🔄 Sync & Management Features

- **Script Auto-Locating** - Place script in AppImage directory, run directly without specifying path
- **Global Shortcut Cleanup** - Check all AppImage shortcuts system-wide, not limited to specific directory
- **Smart Path Matching** - Use absolute paths for comparison, avoid duplicate shortcut creation
- **Beautiful UI** - Unicode box lines and Emoji, clear progress indicators
- **Detailed Statistics** - Show cleanup and creation counts after operation

---

## Quick Start

### 1️⃣ Download Scripts

Place `appimage-shortcut-sync.sh` and `create-appimage-shortcut.sh` in your AppImage directory:

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

### 📦 Batch Sync Tool (Recommended)

**Script Name**: `appimage-shortcut-sync.sh`

**Function**: Automatically sync desktop shortcuts with AppImage files

#### Basic Usage

```bash
# Method 1: Script in AppImage directory (Recommended)
cd ~/appinstall
./appimage-shortcut-sync.sh
```

```bash
# Method 2: Specify directory from anywhere
./appimage-shortcut-sync.sh ~/appinstall
```

#### Workflow

The sync tool executes in three steps:

```
[1/3] Clean Invalid Shortcuts
      ↓
      Check all AppImage shortcuts on desktop
      Remove shortcuts, icons, and menu entries for non-existent files
      
[2/3] Search AppImage Files
      ↓
      Scan .AppImage files in specified directory
      Filter files that already have shortcuts
      
[3/3] Create New Shortcuts
      ↓
      Display list of files needing shortcuts
      User selects all or some to create
```

### 🎯 Single File Processing Tool

**Script Name**: `create-appimage-shortcut.sh`

**Function**: Create desktop shortcut for a single AppImage

#### Basic Usage

```bash
./create-appimage-shortcut.sh <AppImage_path> [app_name] [category]
```

#### Parameter Description

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `AppImage_path` | ✅ | Full path to AppImage file | `~/Downloads/App.AppImage` |
| `app_name` | ❌ | Shortcut display name, defaults to extracted from filename | `MyApp` |
| `category` | ❌ | Application category, defaults to `Application` | `AudioVideo` |

#### Application Categories

| Category | Description | Example Apps |
|----------|-------------|--------------|
| `AudioVideo` | Audio/Video apps | YesPlayMusic, VLC |
| `Development` | Development tools | VSCode, Arduino IDE |
| `Graphics` | Graphics/Image | GIMP, Inkscape |
| `Network` | Network tools | qBittorrent, Browser |
| `Office` | Office software | LibreOffice, WPS |
| `Utility` | Utilities | File managers, System tools |
| `Game` | Games | osu!, Steam games |

#### Usage Examples

```bash
# Simplest: Auto-detect name and category
./create-appimage-shortcut.sh ~/Downloads/YesPlayMusic-0.4.10.AppImage

# Specify app name
./create-appimage-shortcut.sh ~/Downloads/YesPlayMusic-0.4.10.AppImage "YesPlayMusic"

# Full parameters
./create-appimage-shortcut.sh ~/Downloads/YesPlayMusic-0.4.10.AppImage "YesPlayMusic" "AudioVideo"
```

---

## How It Works

### 🔄 Sync Tool Detailed Flow

#### Step 1: Clean Invalid Shortcuts

```bash
1. Scan ~/桌面/*.desktop and ~/Desktop/*.desktop
2. Extract Exec path from each shortcut
3. Check if Exec path file exists
4. If file doesn't exist:
   ├─ Remove desktop shortcut
   ├─ Remove application menu entry (~/.local/share/applications)
   ├─ Remove icon file (~/.local/share/icons/hicolor/256x256/apps)
   └─ Update system cache
```

**Key Features**:
- ✅ **No directory limitation** - Check all AppImage shortcuts regardless of original directory
- ✅ **Complete cleanup** - Remove from desktop, menu, and icons simultaneously
- ✅ **Absolute path matching** - Use `realpath` to ensure accurate path comparison

#### Step 2: Search AppImage Files

```bash
1. Search for *.AppImage files in specified directory (up to 2 levels deep)
2. For each AppImage file:
   ├─ Convert to absolute path
   └─ Check if desktop already has corresponding shortcut
3. List files needing shortcut creation
```

**Smart Filtering**:
- ✅ Use absolute paths for comparison, avoid duplicates
- ✅ Even if shortcut names differ, same path is considered existing

#### Step 3: Create New Shortcuts

```bash
1. Display list of AppImage files to process
2. User selects: [a]all / [number]specific / [s]skip
3. For each selected AppImage:
   ├─ Extract AppImage content to temp directory
   ├─ Find and copy icon file
   ├─ Extract info from built-in .desktop file
   ├─ Create desktop shortcut
   ├─ Create application menu entry
   ├─ Set permissions and trust mark
   ├─ Update icon cache
   └─ Clean up temp files
```

### 🎨 Single File Processing Detailed Flow

```
Start
  ↓
Verify AppImage file
  ↓
Set executable permission
  ↓
Extract AppImage content
  ↓
Find icon file
  ↓
Found icon? → Yes → Copy icon to system directory
      ↓ No
  Use default icon
      ↓
Find built-in .desktop file
  ↓
Extract application info
  ↓
Create desktop shortcut
  ↓
Create application menu entry
  ↓
Set permissions and trust mark
  ↓
Update system cache
  ↓
Clean up temp files
  ↓
Complete
```

### 📂 File Storage Locations

| Type | Path | Description |
|------|------|-------------|
| Desktop Shortcut | `~/桌面/[app_name].desktop` | Desktop icon, double-click to launch |
| Application Menu | `~/.local/share/applications/[app_name].desktop` | Shown in app launcher |
| Icon File | `~/.local/share/icons/hicolor/256x256/apps/[app_name].png` | 256x256 high-res icon |

---

## FAQ

### ❓ Double-clicking shortcut shows "Untrusted Desktop File"

**Cause**: GNOME desktop security mechanism refuses to execute `.desktop` files when desktop directory permissions are too loose (777).

**Solution**:

```bash
# 1. Fix desktop directory permissions
chmod 755 ~/桌面

# 2. Restart DING extension
gnome-extensions disable ding@rastersoft.com
gnome-extensions enable ding@rastersoft.com
```

**Technical Explanation**:
- DING extension disables all `.desktop` files when detecting desktop directory is writable by others for security
- Correct permissions should be `755` (owner writable, others read-only)

### ❓ Icon not displayed or showing incorrectly

**Cause**: Icon cache not updated.

**Solution**:

```bash
# Manually update icon cache
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor

# If still not showing, try restarting session
gnome-shell --replace &
```

### ❓ Cannot extract AppImage content

**Error Message**: `Error: Cannot extract AppImage content`

**Cause**: Missing FUSE library, AppImage requires libfuse2 to run.

**Solution**:

```bash
# Ubuntu/Debian
sudo apt install libfuse2

# Or install fuse3 (for some newer AppImages)
sudo apt install fuse3
```

### ❓ How to remove shortcuts?

**Method 1: Use sync tool for auto cleanup**

After deleting AppImage file, run sync tool to automatically clean corresponding shortcuts:

```bash
rm ~/appinstall/SomeApp.AppImage
./appimage-shortcut-sync.sh
```

**Method 2: Manual removal**

```bash
# 1. Remove desktop shortcut
rm ~/桌面/[app_name].desktop

# 2. Remove application menu entry
rm ~/.local/share/applications/[app_name].desktop

# 3. Remove icon
rm ~/.local/share/icons/hicolor/256x256/apps/[app_name].png

# 4. Update cache
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
update-desktop-database ~/.local/share/applications
```

### ❓ Shortcut fails after AppImage update

**Cause**: AppImage filename includes version number, filename changed after update.

**Solution**:

```bash
# 1. Delete old version
rm ~/appinstall/App-1.0.0.AppImage

# 2. Download new version to same directory
mv ~/Downloads/App-2.0.0.AppImage ~/appinstall/

# 3. Run sync tool
cd ~/appinstall
./appimage-shortcut-sync.sh

# Tool will automatically:
# - Clean invalid shortcuts for old version
# - Create shortcuts for new version
```

### ❓ How to specify custom icon for specific AppImage?

Edit the shortcut file:

```bash
# Edit desktop shortcut
nano ~/桌面/[app_name].desktop

# Modify Icon line to point to custom icon path
Icon=/path/to/custom/icon.png

# Update cache after saving
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
```

---

## Advanced Usage

### 🔗 Setup Global Commands

#### Method 1: Create Symlinks

```bash
# Link scripts to system path
sudo ln -s ~/appinstall/appimage-shortcut-sync.sh /usr/local/bin/appimage-sync
sudo ln -s ~/appinstall/create-appimage-shortcut.sh /usr/local/bin/appimage-add

# Then use from anywhere
appimage-sync ~/Downloads
appimage-add ~/Downloads/NewApp.AppImage
```

#### Method 2: Add Bash Aliases

Edit `~/.bashrc` or `~/.zshrc`:

```bash
# Add these lines
alias appimage-sync='~/appinstall/appimage-shortcut-sync.sh'
alias appimage-add='~/appinstall/create-appimage-shortcut.sh'

# Reload config
source ~/.bashrc
```

Usage:

```bash
appimage-sync
appimage-add ~/Downloads/App.AppImage
```

### 🤖 Scheduled Auto Sync

Use cron to run sync tool periodically:

```bash
# Edit crontab
crontab -e

# Add this line (auto sync daily at 8 AM)
0 8 * * * cd ~/appinstall && echo "a" | ./appimage-shortcut-sync.sh >/dev/null 2>&1
```

### 📦 Batch Process Multiple Directories

Create a script to batch process multiple AppImage directories:

```bash
#!/bin/bash
# batch-sync-all.sh

SYNC_SCRIPT=~/appinstall/appimage-shortcut-sync.sh

# Define directory list to sync
DIRECTORIES=(
    ~/appinstall
    ~/Downloads
    ~/Applications
)

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        echo "Syncing: $dir"
        echo "a" | "$SYNC_SCRIPT" "$dir"
        echo ""
    fi
done
```

### 🎨 Customize Application Categories

Edit the created `.desktop` file to modify categories:

```bash
nano ~/.local/share/applications/[app_name].desktop

# Modify Categories line
Categories=Development;IDE;

# Update database
update-desktop-database ~/.local/share/applications
```

Common category combinations:

```ini
# Development tools
Categories=Development;IDE;

# Music player
Categories=AudioVideo;Audio;Player;

# Video editing
Categories=AudioVideo;Video;VideoEditing;

# Image editing
Categories=Graphics;2DGraphics;RasterGraphics;

# Network tools
Categories=Network;P2P;FileTransfer;

# Games
Categories=Game;ActionGame;
```

---

## System Requirements

### Required

- **Operating System**: Linux (tested on Ubuntu 22.04+)
- **Desktop Environment**: GNOME 40+ with DING extension
- **Shell**: Bash 4.0+
- **Dependencies**:
  - `libfuse2` or `fuse3` - Required for AppImage execution
  - `gio` - Set file metadata (included with GNOME)
  - `gtk-update-icon-cache` - Update icon cache (included with GNOME)

### Optional

- `update-desktop-database` - Update application database
- `realpath` - Path normalization (included in coreutils)

### Install Dependencies

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install libfuse2 coreutils

# If using newer AppImages
sudo apt install fuse3
```

---

## Technical Details

### 🔐 Security Mechanism

#### GNOME Desktop File Trust Mark

The script uses `gio set ... metadata::trusted true` to set trust marks, which is GNOME's security mechanism:

```bash
# Set trust mark
gio set ~/桌面/app.desktop metadata::trusted true

# View trust status
gio info ~/桌面/app.desktop | grep trusted
```

**Why is this needed?**
- GNOME 3.38+ introduced desktop file trust mechanism
- `.desktop` files not marked as trusted cannot be directly double-clicked to run
- Manually checking "Allow Launching" essentially sets this mark

#### Desktop Directory Permission Check

DING extension checks desktop directory permissions, refusing to execute all `.desktop` files if permissions are `777` (writable by all):

```bash
# Check logs
journalctl --user -b | grep "DING"

# Will see similar message:
# DING: desktop-icons: Desktop is writable by others - will not allow launching any desktop files
```

### 🔍 Path Matching Logic

Script uses absolute paths to ensure accurate matching:

```bash
# Convert all paths to absolute
appimage_abs=$(realpath "$appimage")
exec_path_abs=$(realpath "$exec_path")

# Compare absolute paths
if [ "$exec_path_abs" = "$appimage_abs" ]; then
    # Shortcut already exists
fi
```

### 📁 `.desktop` File Format

Created shortcut files comply with [FreeDesktop.org Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/):

```ini
[Desktop Entry]
Name=Application Name
Comment=Application Description
Exec=/path/to/app.AppImage
Icon=icon-name
Terminal=false
Type=Application
Categories=Category;SubCategory;
StartupWMClass=AppWindowClass
```

### 🎨 Icon Search Priority

Script searches for icons with following priority:

1. **High-resolution icons**: 256x256, 512x512, 128x128
2. **Standard locations**:
   - `usr/share/icons/hicolor/[size]/apps/`
   - `usr/share/pixmaps/`
   - `usr/share/icons/`
3. **File formats**: PNG > SVG > XPM > ICO
4. **Root directory icon**: `.DirIcon` file

### 🗑️ Temporary File Management

AppImage content extracted to system temp directory:

```bash
TEMP_DIR=$(mktemp -d)  # Creates: /tmp/tmp.XXXXXXXXXX
# ... process files ...
rm -rf "$TEMP_DIR"     # Cleanup
```

---

## Project Structure

```
appinstall/
├── appimage-shortcut-sync.sh        # Batch sync tool (main script)
├── create-appimage-shortcut.sh      # Single file processing tool
├── README.md                         # Complete documentation (this file)
├── QUICKSTART.md                     # Quick start guide
├── CHANGELOG.md                      # Version update log
├── LICENSE                           # MIT License
└── *.AppImage                        # Your AppImage files
```

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed update history.

### Recent Update (2025-10-26)

- ✨ Script auto-locating feature
- ✨ Global shortcut cleanup
- ✨ Ubuntu default path auto-detection
- ✨ Optimized user interface
- 🐛 Fixed path matching issues
- 🐛 Fixed duplicate shortcut creation

---

## Contributing & Feedback

### Report Issues

If you encounter problems, please provide:

1. OS version: `lsb_release -a`
2. GNOME version: `gnome-shell --version`
3. Desktop environment: `echo $XDG_SESSION_TYPE`
4. Error messages or logs

### Feature Suggestions

Welcome new feature suggestions and improvement ideas!

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
