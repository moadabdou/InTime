#!/bin/bash
#
# InTime Widget - Interactive Installation Script
# Installs the widget with full configuration wizard
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Installation paths
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/intime"
SYSTEMD_DIR="$HOME/.config/systemd/user"

# Configuration variables (will be set by user)
CFG_COLOR=""
CFG_FONT_SIZE=""
CFG_OPACITY=""
CFG_STYLE=""
CFG_POSITION_MODE=""
CFG_POSITION_PRESET=""
CFG_POSITION_X=""
CFG_POSITION_Y=""
CFG_SCREEN_SAMPLING_ENABLED=""
CFG_SCREEN_SAMPLING_INTERVAL=""
CFG_SCREEN_SAMPLING_THRESHOLD=""
CFG_BACKGROUND_COLOR=""

#==========================================
# Helper Functions
#==========================================

show_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
}

ask_choice() {
    local prompt="$1"
    local default="$2"
    shift 2
    local options=("$@")

    echo -e "${CYAN}$prompt${NC}" >&2
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}" >&2
    done

    while true; do
        read -p "Choice [1-${#options[@]}, default: $default]: " choice
        choice=${choice:-$default}

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "$choice"
            return 0
        else
            echo -e "${RED}Invalid choice. Please enter a number between 1 and ${#options[@]}.${NC}" >&2
        fi
    done
}

ask_hex_color() {
    local prompt="$1"
    local default="$2"

    while true; do
        read -p "$prompt [default: $default]: " color
        color=${color:-$default}

        if [[ "$color" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
            echo "$color"
            return 0
        else
            echo -e "${RED}Invalid hex color. Format: #RRGGBB (e.g., #FF0000)${NC}" >&2
        fi
    done
}

ask_number() {
    local prompt="$1"
    local default="$2"
    local min="$3"
    local max="$4"

    while true; do
        read -p "$prompt [$min-$max, default: $default]: " num
        num=${num:-$default}

        if [[ "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$num >= $min && $num <= $max" | bc -l) )); then
            echo "$num"
            return 0
        else
            echo -e "${RED}Invalid number. Must be between $min and $max.${NC}" >&2
        fi
    done
}

#==========================================
# Configuration Functions
#==========================================

configure_express() {
    # Use all defaults for express mode
    CFG_COLOR="#FFFFFF"
    CFG_FONT_SIZE="78"
    CFG_OPACITY="0.5"
    CFG_STYLE="normal"
    CFG_POSITION_MODE="preset"
    CFG_POSITION_PRESET="center"
    CFG_POSITION_X="0"
    CFG_POSITION_Y="0"
    CFG_SCREEN_SAMPLING_ENABLED="false"
    CFG_SCREEN_SAMPLING_INTERVAL="0.5"
    CFG_SCREEN_SAMPLING_THRESHOLD="15"
    CFG_BACKGROUND_COLOR="#000000"

    echo -e "${GREEN}✓ Using recommended defaults${NC}"
}

configure_custom() {
    show_header "Display Configuration"

    # Q1: Visual Style
    echo -e "${BOLD}Visual Style${NC}"
    local style_choice=$(ask_choice "How should the clock look?" "1" \
        "Normal - Clean, bold text (recommended)" \
        "Bordered - Text with dark outline" \
        "Lightbulb - Glowing particle effect (higher CPU)")

    case $style_choice in
        1) CFG_STYLE="normal" ;;
        2) CFG_STYLE="bordered" ;;
        3) CFG_STYLE="lightbulb" ;;
    esac

    # Q2: Clock Color
    echo -e "\n${BOLD}Clock Color${NC}"
    local color_choice=$(ask_choice "What color should the clock be?" "1" \
        "White (#FFFFFF) - Classic" \
        "Cyan (#00FFFF) - Tech aesthetic" \
        "Gold (#FFD700) - Elegant" \
        "Red (#FF0000) - Bold" \
        "Custom - Enter your own hex color")

    case $color_choice in
        1) CFG_COLOR="#FFFFFF" ;;
        2) CFG_COLOR="#00FFFF" ;;
        3) CFG_COLOR="#FFD700" ;;
        4) CFG_COLOR="#FF0000" ;;
        5) CFG_COLOR=$(ask_hex_color "Enter hex color" "#FFFFFF") ;;
    esac

    # Q3: Font Size
    echo -e "\n${BOLD}Font Size${NC}"
    local size_choice=$(ask_choice "How large should the clock text be?" "2" \
        "Small (50px) - Subtle" \
        "Medium (78px) - Balanced (recommended)" \
        "Large (120px) - Prominent" \
        "Custom size")

    case $size_choice in
        1) CFG_FONT_SIZE="50" ;;
        2) CFG_FONT_SIZE="78" ;;
        3) CFG_FONT_SIZE="120" ;;
        4) CFG_FONT_SIZE=$(ask_number "Enter font size" "78" "20" "200") ;;
    esac

    # Q4: Opacity
    echo -e "\n${BOLD}Opacity${NC}"
    local opacity_choice=$(ask_choice "How transparent should the clock be?" "2" \
        "Very transparent (0.3) - Ghost-like" \
        "Semi-transparent (0.5) - Balanced (recommended)" \
        "Mostly visible (0.7)" \
        "Fully opaque (1.0)")

    case $opacity_choice in
        1) CFG_OPACITY="0.3" ;;
        2) CFG_OPACITY="0.5" ;;
        3) CFG_OPACITY="0.7" ;;
        4) CFG_OPACITY="1.0" ;;
    esac

    # Q5: Position
    echo -e "\n${BOLD}Position${NC}"
    local position_choice=$(ask_choice "Where should the clock appear?" "2" \
        "Top - Top of screen" \
        "Center - Center of screen (recommended)" \
        "Bottom - Bottom of screen" \
        "Custom coordinates - Enter exact X,Y position")

    case $position_choice in
        1) CFG_POSITION_MODE="preset"; CFG_POSITION_PRESET="top" ;;
        2) CFG_POSITION_MODE="preset"; CFG_POSITION_PRESET="center" ;;
        3) CFG_POSITION_MODE="preset"; CFG_POSITION_PRESET="bottom" ;;
        4)
            CFG_POSITION_MODE="custom"
            CFG_POSITION_PRESET="center"
            CFG_POSITION_X=$(ask_number "Enter X coordinate (pixels from left)" "0" "0" "4096")
            CFG_POSITION_Y=$(ask_number "Enter Y coordinate (pixels from top)" "0" "0" "4096")
            ;;
    esac

    if [ "$position_choice" -ne 4 ]; then
        CFG_POSITION_X="0"
        CFG_POSITION_Y="0"
    fi

    # Q6: Adaptive Color (Advanced)
    show_header "Advanced Settings"

    echo -e "${BOLD}Adaptive Color${NC}"
    echo -e "${YELLOW}Note: Requires 'grim' tool and uses more CPU${NC}"
    local adaptive_choice=$(ask_choice "Enable real-time adaptive color based on screen content?" "1" \
        "No - Use fixed color (recommended)" \
        "Yes - Enable adaptive color")

    if [ "$adaptive_choice" = "2" ]; then
        CFG_SCREEN_SAMPLING_ENABLED="true"
        CFG_SCREEN_SAMPLING_INTERVAL=$(ask_number "Update interval (seconds)" "0.5" "0.1" "5.0")
        CFG_SCREEN_SAMPLING_THRESHOLD=$(ask_number "Color change threshold (0-255)" "15" "0" "255")
    else
        CFG_SCREEN_SAMPLING_ENABLED="false"
        CFG_SCREEN_SAMPLING_INTERVAL="0.5"
        CFG_SCREEN_SAMPLING_THRESHOLD="15"
    fi

    # Q7: Background Color
    echo -e "\n${BOLD}Background Color${NC}"
    echo -e "${YELLOW}Used for color contrast calculations${NC}"
    local bg_choice=$(ask_choice "What is your typical desktop background?" "1" \
        "Dark (#000000) - Dark themes/wallpapers (recommended)" \
        "Light (#FFFFFF) - Light themes/wallpapers" \
        "Custom color")

    case $bg_choice in
        1) CFG_BACKGROUND_COLOR="#000000" ;;
        2) CFG_BACKGROUND_COLOR="#FFFFFF" ;;
        3) CFG_BACKGROUND_COLOR=$(ask_hex_color "Enter background hex color" "#000000") ;;
    esac
}

show_config_summary() {
    show_header "Configuration Summary"

    echo -e "  ${BOLD}Style:${NC}              $CFG_STYLE"
    echo -e "  ${BOLD}Color:${NC}              $CFG_COLOR"
    echo -e "  ${BOLD}Font Size:${NC}          ${CFG_FONT_SIZE}px"
    echo -e "  ${BOLD}Opacity:${NC}            $CFG_OPACITY"

    if [ "$CFG_POSITION_MODE" = "preset" ]; then
        echo -e "  ${BOLD}Position:${NC}           $CFG_POSITION_PRESET"
    else
        echo -e "  ${BOLD}Position:${NC}           Custom (X:$CFG_POSITION_X, Y:$CFG_POSITION_Y)"
    fi

    if [ "$CFG_SCREEN_SAMPLING_ENABLED" = "true" ]; then
        echo -e "  ${BOLD}Adaptive Color:${NC}     Enabled"
        echo -e "    ${BOLD}Interval:${NC}         ${CFG_SCREEN_SAMPLING_INTERVAL}s"
        echo -e "    ${BOLD}Threshold:${NC}        $CFG_SCREEN_SAMPLING_THRESHOLD"
    else
        echo -e "  ${BOLD}Adaptive Color:${NC}     Disabled"
    fi

    echo -e "  ${BOLD}Background:${NC}         $CFG_BACKGROUND_COLOR"
    echo
}

generate_config() {
    local config_file="$1"

    cat > "$config_file" << EOF
{
  "_comment": "InTime Widget Configuration - Generated by installer",
  "_docs": "See README.md for detailed configuration options",

  "color": "$CFG_COLOR",
  "font_size": $CFG_FONT_SIZE,
  "opacity": $CFG_OPACITY,
  "style": "$CFG_STYLE",

  "position_mode": "$CFG_POSITION_MODE",
  "position_preset": "$CFG_POSITION_PRESET",
  "position_x": $CFG_POSITION_X,
  "position_y": $CFG_POSITION_Y,

  "screen_sampling": {
    "enabled": $CFG_SCREEN_SAMPLING_ENABLED,
    "update_interval": $CFG_SCREEN_SAMPLING_INTERVAL,
    "throttle_threshold": $CFG_SCREEN_SAMPLING_THRESHOLD
  },

  "background_color": "$CFG_BACKGROUND_COLOR"
}
EOF
}

#==========================================
# Main Installation Flow
#==========================================

show_header "InTime Widget - Interactive Installer"

echo "This wizard will guide you through configuring your clock widget."
echo "You can change these settings later by editing ~/.config/intime/config.json"
echo

# Check if running on Hyprland
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo -e "${YELLOW}Warning: Hyprland is not currently running.${NC}"
    echo -e "${YELLOW}This widget is designed for Hyprland. Installation will continue.${NC}\n"
fi

# Setup mode selection
echo -e "${BOLD}Setup Mode${NC}"
setup_choice=$(ask_choice "Choose setup mode:" "1" \
    "Express - Use recommended defaults (quick setup)" \
    "Custom - Configure all options (full control)")

if [ "$setup_choice" = "1" ]; then
    configure_express
else
    configure_custom
fi

# Show configuration summary
show_config_summary

# Confirm configuration
while true; do
    read -p "Save this configuration? [Y/n]: " confirm
    confirm=${confirm:-Y}

    case $confirm in
        [Yy]* ) break;;
        [Nn]* )
            echo -e "\n${YELLOW}Restarting configuration...${NC}\n"
            if [ "$setup_choice" = "1" ]; then
                configure_express
            else
                configure_custom
            fi
            show_config_summary
            ;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Create directories
show_header "Installing Files"

echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SYSTEMD_DIR"

# Install Python files
echo -e "${BLUE}Installing widget files...${NC}"
cp "$PROJECT_DIR/src/intime_widget.py" "$INSTALL_DIR/intime-widget"
cp "$PROJECT_DIR/src/screen_color_monitor.py" "$INSTALL_DIR/screen_color_monitor.py"

# Make executable
chmod +x "$INSTALL_DIR/intime-widget"

echo -e "${GREEN}✓ Widget installed to: $INSTALL_DIR/intime-widget${NC}"

# Install config
if [ -f "$CONFIG_DIR/config.json" ]; then
    echo -e "${YELLOW}Config file already exists. Creating backup...${NC}"
    cp "$CONFIG_DIR/config.json" "$CONFIG_DIR/config.json.backup"
    echo -e "${YELLOW}Backup: $CONFIG_DIR/config.json.backup${NC}"
fi

generate_config "$CONFIG_DIR/config.json"
echo -e "${GREEN}✓ Config saved to: $CONFIG_DIR/config.json${NC}"

# Check Python dependencies
echo -e "\n${BLUE}Checking Python dependencies...${NC}"

check_python_module() {
    python3 -c "import $1" 2>/dev/null
    return $?
}

MISSING_DEPS=()

if ! check_python_module "gi"; then
    MISSING_DEPS+=("python-gobject")
fi

if ! check_python_module "PIL"; then
    MISSING_DEPS+=("pillow")
fi

if ! check_python_module "numpy"; then
    MISSING_DEPS+=("numpy")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Missing Python dependencies:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - $dep"
    done
    echo -e "\n${YELLOW}Install with: pip install --user pillow numpy${NC}"
else
    echo -e "${GREEN}✓ All Python dependencies installed${NC}"
fi

# Check system dependencies
echo -e "\n${BLUE}Checking system dependencies...${NC}"

MISSING_SYSTEM=()

if [ "$CFG_SCREEN_SAMPLING_ENABLED" = "true" ] && ! command -v grim &> /dev/null; then
    MISSING_SYSTEM+=("grim")
fi

if ! ldconfig -p 2>/dev/null | grep -q libgtk-4-layer-shell; then
    MISSING_SYSTEM+=("gtk4-layer-shell")
fi

if [ ${#MISSING_SYSTEM[@]} -gt 0 ]; then
    echo -e "${YELLOW}Missing system dependencies:${NC}"
    for dep in "${MISSING_SYSTEM[@]}"; do
        echo "  - $dep"
    done

    echo -e "\n${YELLOW}Install commands by distro:${NC}"
    echo "  Arch:   sudo pacman -S ${MISSING_SYSTEM[@]}"
    echo "  Ubuntu: sudo apt install ${MISSING_SYSTEM[@]}"
    echo "  Fedora: sudo dnf install ${MISSING_SYSTEM[@]}"
else
    echo -e "${GREEN}✓ All system dependencies installed${NC}"
fi

# Systemd service installation
show_header "System Integration"

echo -e "${BOLD}Systemd Service${NC}"
read -p "Install systemd user service for autostart? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > "$SYSTEMD_DIR/intime-widget.service" << EOF
[Unit]
Description=InTime Widget - Transparent Clock for Hyprland
Documentation=https://github.com/yourusername/intime-widget
After=graphical-session.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/intime-widget
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload
    echo -e "${GREEN}✓ Systemd service installed${NC}"
    echo -e "\n${BLUE}To enable autostart:${NC}"
    echo "  systemctl --user enable intime-widget.service"
    echo "  systemctl --user start intime-widget.service"
fi

# Check if ~/.local/bin is in PATH
echo -e "\n${BLUE}Checking PATH...${NC}"
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Warning: $INSTALL_DIR is not in your PATH${NC}"
    echo -e "${YELLOW}Add this to your ~/.bashrc or ~/.zshrc:${NC}"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    echo -e "${GREEN}✓ $INSTALL_DIR is in PATH${NC}"
fi

# Installation complete
show_header "Installation Complete!"

echo -e "${BOLD}Quick Start:${NC}"
echo "  Run the widget:     intime-widget"
echo "  Edit config:        nano $CONFIG_DIR/config.json"
echo ""
echo -e "${BOLD}For Hyprland autostart, add to hyprland.conf:${NC}"
echo "  exec-once = intime-widget"
echo ""

# Offer to start the widget
echo -e "${BOLD}Start Widget${NC}"
read -p "Start the widget now? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if systemctl --user is-active --quiet intime-widget.service; then
        systemctl --user restart intime-widget.service
        echo -e "${GREEN}✓ Widget restarted via systemd${NC}"
    elif [ -f "$SYSTEMD_DIR/intime-widget.service" ]; then
        systemctl --user start intime-widget.service
        echo -e "${GREEN}✓ Widget started via systemd${NC}"
    else
        nohup "$INSTALL_DIR/intime-widget" > /dev/null 2>&1 &
        echo -e "${GREEN}✓ Widget started in background${NC}"
    fi
fi

echo -e "\n${GREEN}${BOLD}Enjoy InTime Widget!${NC}\n"
