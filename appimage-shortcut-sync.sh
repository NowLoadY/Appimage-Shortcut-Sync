#!/bin/bash
# AppImage Shortcut Sync Tool
# Automatically clean invalid shortcuts and create desktop shortcuts for new AppImage files
# Usage: Run this script in the AppImage directory, or specify the directory path as an argument

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREATE_SCRIPT="$SCRIPT_DIR/create-appimage-shortcut.sh"

if [ ! -f "$CREATE_SCRIPT" ]; then
    echo -e "${RED}Error: create-appimage-shortcut.sh not found${NC}"
    echo -e "${YELLOW}Tip: Ensure create-appimage-shortcut.sh is in the same directory as this script${NC}"
    exit 1
fi

# Ubuntu default paths
DESKTOP_DIR="$HOME/桌面"
# Fallback to English Desktop directory
if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="$HOME/Desktop"
fi
APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Search directory: use argument if provided, otherwise use script directory
if [ -n "$1" ]; then
    SEARCH_DIR=$(realpath "$1")
else
    SEARCH_DIR="$SCRIPT_DIR"
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AppImage Shortcut Sync Tool        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Managing Directory:${NC} $SEARCH_DIR"
echo -e "${CYAN}🖥️  Desktop Directory:${NC} $DESKTOP_DIR"
echo ""

# ==================== Step 1: Clean Invalid Shortcuts ====================
echo -e "${YELLOW}[1/3] Checking for invalid shortcuts...${NC}"
echo ""

deleted_count=0
checked_count=0

# Check desktop shortcuts (all AppImage shortcuts, no directory limitation)
if [ -d "$DESKTOP_DIR" ]; then
    while IFS= read -r -d '' desktop_file; do
        ((checked_count++))
        
        # Extract Exec path
        exec_path=$(grep "^Exec=" "$desktop_file" | head -1 | cut -d'=' -f2- | awk '{print $1}')
        
        # Check if it's AppImage and if file exists
        if [[ "$exec_path" == *.AppImage ]]; then
            if [ ! -f "$exec_path" ]; then
                app_name=$(basename "$desktop_file" .desktop)
                
                echo -e "${RED}✗ Invalid shortcut: $app_name${NC}"
                echo -e "  ${RED}→${NC} File not found: $exec_path"
                
                # Remove desktop shortcut
                rm -f "$desktop_file"
                echo -e "  ${GREEN}✓${NC} Removed desktop shortcut"
                
                # Remove application menu entry
                apps_file="$APPS_DIR/${app_name}.desktop"
                if [ -f "$apps_file" ]; then
                    rm -f "$apps_file"
                    echo -e "  ${GREEN}✓${NC} Removed application menu entry"
                fi
                
                # Remove icon
                icon_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
                deleted_icon=false
                for ext in png svg xpm ico; do
                    icon_file="$ICONS_DIR/${icon_name}.${ext}"
                    if [ -f "$icon_file" ]; then
                        rm -f "$icon_file"
                        echo -e "  ${GREEN}✓${NC} Removed icon file: ${icon_name}.${ext}"
                        deleted_icon=true
                    fi
                done
                
                ((deleted_count++))
                echo ""
            fi
        fi
    done < <(find "$DESKTOP_DIR" -maxdepth 1 -type f -name "*.desktop" -print0 2>/dev/null)
fi

if [ $deleted_count -eq 0 ]; then
    echo -e "${GREEN}✓ No invalid shortcuts found (checked $checked_count)${NC}"
else
    echo -e "${GREEN}✓ Cleaned $deleted_count invalid shortcuts${NC}"
    
    # Update cache
    echo -e "${CYAN}Updating system cache...${NC}"
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    fi
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$APPS_DIR" 2>/dev/null || true
    fi
fi

echo ""

# ==================== Step 2: Search AppImage Files ====================
echo -e "${YELLOW}[2/3] Searching for AppImage files...${NC}"
echo ""

# Find all AppImage files (in specified directory and subdirectories)
mapfile -t appimages < <(find "$SEARCH_DIR" -maxdepth 2 -type f -name "*.AppImage" 2>/dev/null)

if [ ${#appimages[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ No AppImage files found${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Sync Complete!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📊 Statistics:${NC}"
    echo -e "   Cleaned invalid shortcuts: $deleted_count"
    echo -e "   Created new shortcuts: 0"
    exit 0
fi

echo -e "${GREEN}✓ Found ${#appimages[@]} AppImage files${NC}"

# Display found files (show first 5 only)
if [ ${#appimages[@]} -le 5 ]; then
    for appimage in "${appimages[@]}"; do
        echo -e "  ${CYAN}→${NC} $(basename "$appimage")"
    done
else
    for i in {0..4}; do
        echo -e "  ${CYAN}→${NC} $(basename "${appimages[$i]}")"
    done
    echo -e "  ${CYAN}...${NC} and $((${#appimages[@]} - 5)) more files"
fi
echo ""

# Check which ones need shortcuts
declare -a needs_shortcut
for appimage in "${appimages[@]}"; do
    # Ensure using absolute path
    appimage_abs=$(realpath "$appimage")
    
    # Check if desktop shortcut exists
    shortcut_exists=false
    for desktop_file in "$DESKTOP_DIR"/*.desktop; do
        if [ -f "$desktop_file" ]; then
            exec_path=$(grep "^Exec=" "$desktop_file" 2>/dev/null | head -1 | cut -d'=' -f2- | awk '{print $1}')
            # Convert exec_path to absolute path for comparison
            if [ -n "$exec_path" ] && [ -f "$exec_path" ]; then
                exec_path_abs=$(realpath "$exec_path")
                if [ "$exec_path_abs" = "$appimage_abs" ]; then
                    shortcut_exists=true
                    break
                fi
            fi
        fi
    done
    
    if [ "$shortcut_exists" = false ]; then
        needs_shortcut+=("$appimage_abs")
    fi
done

if [ ${#needs_shortcut[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All AppImage files already have shortcuts${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Sync Complete!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📊 Statistics:${NC}"
    echo -e "   Cleaned invalid shortcuts: $deleted_count"
    echo -e "   Existing shortcuts: ${#appimages[@]}"
    echo -e "   Created new shortcuts: 0"
    exit 0
fi

# ==================== Step 3: Create New Shortcuts ====================
echo -e "${YELLOW}[3/3] Creating new shortcuts...${NC}"
echo ""
echo -e "${CYAN}📝 AppImage files needing shortcuts (${#needs_shortcut[@]}):${NC}"
for i in "${!needs_shortcut[@]}"; do
    echo -e "   ${BLUE}[$i]${NC} $(basename "${needs_shortcut[$i]}")"
done
echo ""

echo -e "${CYAN}Select an operation:${NC}"
echo -e "   ${GREEN}[a]${NC} Create all"
echo -e "   ${YELLOW}[number]${NC} Create specific items (space-separated, e.g.: 0 2 4)"
echo -e "   ${RED}[s]${NC} Skip, don't create any shortcuts"
echo ""
read -p "👉 Your choice: " choice

if [ "$choice" = "s" ]; then
    echo ""
    echo -e "${YELLOW}⚠ Skipped creating shortcuts${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Sync Complete!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📊 Statistics:${NC}"
    echo -e "   Cleaned invalid shortcuts: $deleted_count"
    echo -e "   Created new shortcuts: 0"
    exit 0
fi

# Process selection
if [ "$choice" = "a" ]; then
    selected_indices=("${!needs_shortcut[@]}")
else
    read -ra selected_indices <<< "$choice"
fi

echo ""
echo -e "${CYAN}Creating shortcuts...${NC}"
echo ""

created=0
failed=0

for idx in "${selected_indices[@]}"; do
    if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#needs_shortcut[@]} ]; then
        appimage="${needs_shortcut[$idx]}"
        app_name=$(basename "$appimage" .AppImage | sed 's/-[0-9].*//')
        
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}📦 Processing:${NC} $(basename "$appimage")"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        if "$CREATE_SCRIPT" "$appimage" 2>&1 | grep -E "✓|✗|icon|desktop|application"; then
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                ((created++))
                echo -e "${GREEN}✓ Successfully created shortcut${NC}"
            else
                ((failed++))
                echo -e "${RED}✗ Failed to create${NC}"
            fi
        else
            ((failed++))
            echo -e "${RED}✗ Failed to create${NC}"
        fi
        echo ""
    fi
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      🎉 Sync Complete!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📊 Statistics:${NC}"
echo -e "   ${YELLOW}●${NC} Cleaned invalid shortcuts: ${deleted_count}"
echo -e "   ${GREEN}●${NC} Created new shortcuts: ${created}"
if [ $failed -gt 0 ]; then
    echo -e "   ${RED}●${NC} Failed to create: ${failed}"
fi
echo ""
echo -e "${CYAN}💡 Tip:${NC} You can now launch applications from desktop or application menu!"
