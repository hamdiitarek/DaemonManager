#!/bin/bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
BACKUP_DIR="/usr/local/bin/daemon_manager_backup"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

if [[ $EUID -ne 0 ]]; then
    print_status "$RED" "Error: This script must be run as root (use sudo)"
    exit 1
fi

print_status "$YELLOW" "Daemon Manager Uninstaller"
print_status "$YELLOW" "========================="

files_to_remove=()
if [[ -f "$INSTALL_DIR/DaemonManager" ]]; then
    files_to_remove+=("$INSTALL_DIR/DaemonManager")
fi
if [[ -f "$INSTALL_DIR/signal_handler" ]]; then
    files_to_remove+=("$INSTALL_DIR/signal_handler")
fi

if [[ ${#files_to_remove[@]} -eq 0 ]]; then
    print_status "$YELLOW" "No Daemon Manager files found to remove"
    exit 0
fi

print_status "$YELLOW" "Found ${#files_to_remove[@]} file(s) to remove:"
for file in "${files_to_remove[@]}"; do
    echo "  - $file"
done

read -p "Proceed with uninstallation? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_status "$YELLOW" "Uninstallation cancelled"
    exit 0
fi

for file in "${files_to_remove[@]}"; do
    if rm "$file"; then
        print_status "$GREEN" "✓ Removed $(basename "$file")"
    else
        print_status "$RED" "✗ Failed to remove $file"
    fi
done

if [[ -d "$BACKUP_DIR" ]]; then
    read -p "Remove backup directory? (y/N): " remove_backup
    if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
        if rm -rf "$BACKUP_DIR"; then
            print_status "$GREEN" "✓ Backup directory removed"
        else
            print_status "$RED" "✗ Failed to remove backup directory"
        fi
    fi
fi

print_status "$GREEN" "✓ Uninstallation complete!"
