#!/bin/bash
# AppImage Desktop Shortcut Creator
# Usage: ./create-appimage-shortcut.sh <AppImage_path> [app_name] [category]

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <AppImage_path> [app_name] [category]"
    echo "Example: $0 ~/appinstall/YesPlayMusic-0.4.10.AppImage YesPlayMusic AudioVideo"
    exit 1
fi

APPIMAGE_PATH="$1"
APPIMAGE_FULLPATH=$(realpath "$APPIMAGE_PATH")

# Check if file exists
if [ ! -f "$APPIMAGE_FULLPATH" ]; then
    echo -e "${RED}Error: File not found: $APPIMAGE_FULLPATH${NC}"
    exit 1
fi

# Check if it's an AppImage
if ! file "$APPIMAGE_FULLPATH" | grep -q "executable"; then
    echo -e "${YELLOW}Warning: File may not be an executable AppImage${NC}"
fi

# Set executable permission
chmod +x "$APPIMAGE_FULLPATH"
echo -e "${GREEN}✓${NC} Set executable permission"

# Get application name (from filename or argument)
if [ -n "$2" ]; then
    APP_NAME="$2"
else
    # Extract from filename, remove version and extension
    APP_NAME=$(basename "$APPIMAGE_FULLPATH" .AppImage | sed 's/-[0-9].*//')
fi

# Get category (from argument or use default)
CATEGORIES="${3:-Application}"

echo -e "${YELLOW}Application name:${NC} $APP_NAME"
echo -e "${YELLOW}Category:${NC} $CATEGORIES"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}Temporary directory:${NC} $TEMP_DIR"

# Extract AppImage content
echo "Extracting AppImage content..."
cd "$TEMP_DIR"
"$APPIMAGE_FULLPATH" --appimage-extract >/dev/null 2>&1 || {
    echo -e "${YELLOW}Warning: Cannot use --appimage-extract, trying manual mount...${NC}"
    "$APPIMAGE_FULLPATH" --appimage-mount &
    MOUNT_PID=$!
    sleep 2
}

EXTRACT_DIR="$TEMP_DIR/squashfs-root"

if [ ! -d "$EXTRACT_DIR" ]; then
    echo -e "${RED}Error: Cannot extract AppImage content${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} AppImage content extracted"

# Find icon file
ICON_FILE=""
ICON_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

# Search possible icon locations
for ext in png svg xpm ico; do
    # Prioritize high-resolution icons
    for size in 256 128 512 64 48; do
        if [ -f "$EXTRACT_DIR/usr/share/icons/hicolor/${size}x${size}/apps/"*."$ext" ]; then
            ICON_FILE=$(ls "$EXTRACT_DIR/usr/share/icons/hicolor/${size}x${size}/apps/"*."$ext" 2>/dev/null | head -1)
            break 2
        fi
    done
    
    # Search other common locations
    if [ -z "$ICON_FILE" ]; then
        for path in \
            "$EXTRACT_DIR/usr/share/pixmaps" \
            "$EXTRACT_DIR/usr/share/icons" \
            "$EXTRACT_DIR" \
            "$EXTRACT_DIR/.DirIcon"; do
            if [ -f "$path/"*"$ext" ]; then
                ICON_FILE=$(ls "$path/"*."$ext" 2>/dev/null | head -1)
                break 2
            fi
        done
    fi
done

# If not found, try to find any image file
if [ -z "$ICON_FILE" ]; then
    ICON_FILE=$(find "$EXTRACT_DIR" -type f \( -name "*.png" -o -name "*.svg" \) | head -1)
fi

# Process icon
if [ -n "$ICON_FILE" ]; then
    ICON_EXT="${ICON_FILE##*.}"
    ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
    mkdir -p "$ICON_DIR"
    
    ICON_DEST="$ICON_DIR/${ICON_NAME}.${ICON_EXT}"
    cp "$ICON_FILE" "$ICON_DEST"
    echo -e "${GREEN}✓${NC} Icon copied to: $ICON_DEST"
    
    ICON_VALUE="$ICON_NAME"
else
    echo -e "${YELLOW}Warning: Icon file not found, using default icon${NC}"
    ICON_VALUE="application-x-executable"
fi

# Find existing .desktop file as reference
DESKTOP_REF=""
if [ -f "$EXTRACT_DIR/"*.desktop ]; then
    DESKTOP_REF=$(ls "$EXTRACT_DIR/"*.desktop | head -1)
    echo -e "${GREEN}✓${NC} Found existing .desktop file: $(basename "$DESKTOP_REF")"
fi

# Extract information from existing .desktop file
COMMENT=""
GENERIC_NAME=""
STARTUP_WM_CLASS=""

if [ -n "$DESKTOP_REF" ]; then
    COMMENT=$(grep "^Comment=" "$DESKTOP_REF" | head -1 | cut -d'=' -f2- || echo "")
    GENERIC_NAME=$(grep "^GenericName=" "$DESKTOP_REF" | head -1 | cut -d'=' -f2- || echo "")
    STARTUP_WM_CLASS=$(grep "^StartupWMClass=" "$DESKTOP_REF" | head -1 | cut -d'=' -f2- || echo "$APP_NAME")
    
    # If found better icon name
    DESKTOP_ICON=$(grep "^Icon=" "$DESKTOP_REF" | head -1 | cut -d'=' -f2- || echo "")
    if [ -n "$DESKTOP_ICON" ] && [ -z "$ICON_FILE" ]; then
        ICON_VALUE="$DESKTOP_ICON"
    fi
fi

# Set default values
COMMENT="${COMMENT:-$APP_NAME Application}"
STARTUP_WM_CLASS="${STARTUP_WM_CLASS:-$APP_NAME}"

# Detect desktop directory
DESKTOP_DIR="$HOME/桌面"
if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="$HOME/Desktop"
fi

# Create desktop shortcut
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$COMMENT
Exec=$APPIMAGE_FULLPATH
Icon=$ICON_VALUE
Terminal=false
Type=Application
Categories=$CATEGORIES;
StartupWMClass=$STARTUP_WM_CLASS
EOF

if [ -n "$GENERIC_NAME" ]; then
    echo "GenericName=$GENERIC_NAME" >> "$DESKTOP_FILE"
fi

echo -e "${GREEN}✓${NC} Desktop shortcut created: $DESKTOP_FILE"

# Set permissions and trust mark
chmod +x "$DESKTOP_FILE"
gio set "$DESKTOP_FILE" metadata::trusted true

echo -e "${GREEN}✓${NC} Set executable permission and trust mark"

# Also create application menu shortcut
APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"
cp "$DESKTOP_FILE" "$APPS_DIR/${APP_NAME}.desktop"
echo -e "${GREEN}✓${NC} Application menu shortcut created"

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$APPS_DIR" 2>/dev/null || true
fi

# Clean up temporary files
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Temporary files cleaned up"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Done!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Desktop shortcut: $DESKTOP_FILE"
echo -e "Application menu: $APPS_DIR/${APP_NAME}.desktop"
if [ -n "$ICON_FILE" ]; then
    echo -e "Icon location: $ICON_DEST"
fi
echo ""
echo -e "You can now launch ${APP_NAME} from desktop icon or application menu!"
