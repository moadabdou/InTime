#!/bin/bash
#
# InTime Widget Uninstallation Script
# Removes the widget from the system
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation paths
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/intime"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo -e "${BLUE}=== InTime Widget Uninstaller ===${NC}\n"

# Stop and disable service if running
if systemctl --user is-active --quiet intime-widget.service; then
    echo -e "${BLUE}Stopping widget service...${NC}"
    systemctl --user stop intime-widget.service
    echo -e "${GREEN}✓ Service stopped${NC}"
fi

if systemctl --user is-enabled --quiet intime-widget.service 2>/dev/null; then
    echo -e "${BLUE}Disabling autostart...${NC}"
    systemctl --user disable intime-widget.service
    echo -e "${GREEN}✓ Autostart disabled${NC}"
fi

# Remove systemd service
if [ -f "$SYSTEMD_DIR/intime-widget.service" ]; then
    rm "$SYSTEMD_DIR/intime-widget.service"
    systemctl --user daemon-reload
    echo -e "${GREEN}✓ Systemd service removed${NC}"
fi

# Remove widget files
if [ -f "$INSTALL_DIR/intime-widget" ]; then
    rm "$INSTALL_DIR/intime-widget"
    echo -e "${GREEN}✓ Widget binary removed${NC}"
fi

if [ -f "$INSTALL_DIR/screen_color_monitor.py" ]; then
    rm "$INSTALL_DIR/screen_color_monitor.py"
    echo -e "${GREEN}✓ Screen monitor module removed${NC}"
fi

# Ask about config directory
if [ -d "$CONFIG_DIR" ]; then
    echo -e "\n${YELLOW}Config directory found: $CONFIG_DIR${NC}"
    read -p "Remove config directory? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        echo -e "${GREEN}✓ Config directory removed${NC}"
    else
        echo -e "${YELLOW}Config directory preserved${NC}"
    fi
fi

echo -e "\n${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Uninstallation Complete!             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}InTime Widget has been removed from your system.${NC}"
echo -e "${BLUE}Thank you for using InTime Widget!${NC}\n"
