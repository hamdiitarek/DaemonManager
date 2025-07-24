#!/bin/bash
set -euo pipefail

BASH_SCRIPT="DaemonManager"
C_SOURCE="signal_handler.c"
INSTALL_DIR="/usr/local/bin"
BACKUP_DIR="/usr/local/bin/daemon_manager_backup"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

check_prerequisites() {
    print_status "$BLUE" "Checking prerequisites..."
    
    local missing_commands=()
    
    if ! command -v gcc &> /dev/null; then
        missing_commands+=("gcc")
    fi
    
    if ! command -v make &> /dev/null; then
        print_status "$YELLOW" "Warning: 'make' command not found (optional)"
    fi
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        print_status "$RED" "Error: Missing required commands: ${missing_commands[*]}"
        print_status "$YELLOW" "Please install the missing commands and try again."
        exit 1
    fi
    
    print_status "$GREEN" "✓ Prerequisites check passed"
}

create_backup() {
    if [[ -f "$INSTALL_DIR/$BASH_SCRIPT" ]] || [[ -f "$INSTALL_DIR/signal_handler" ]]; then
        print_status "$YELLOW" "Existing installation found. Creating backup..."
        
        mkdir -p "$BACKUP_DIR"
        local backup_timestamp=$(date +%Y%m%d_%H%M%S)
        
        if [[ -f "$INSTALL_DIR/$BASH_SCRIPT" ]]; then
            cp "$INSTALL_DIR/$BASH_SCRIPT" "$BACKUP_DIR/${BASH_SCRIPT}_${backup_timestamp}"
            print_status "$GREEN" "✓ Backed up existing $BASH_SCRIPT"
        fi
        
        if [[ -f "$INSTALL_DIR/signal_handler" ]]; then
            cp "$INSTALL_DIR/signal_handler" "$BACKUP_DIR/signal_handler_${backup_timestamp}"
            print_status "$GREEN" "✓ Backed up existing signal_handler"
        fi
    fi
}

validate_files() {
    print_status "$BLUE" "Validating source files..."
    
    if [[ ! -f "$BASH_SCRIPT" ]]; then
        print_status "$RED" "Error: Bash script $BASH_SCRIPT not found in current directory."
        print_status "$YELLOW" "Please ensure you're running this script from the correct directory."
        exit 1
    fi
    
    if [[ ! -f "$C_SOURCE" ]]; then
        print_status "$RED" "Error: C source file $C_SOURCE not found in current directory."
        exit 1
    fi
    
    if [[ ! -x "$BASH_SCRIPT" ]]; then
        print_status "$YELLOW" "Making $BASH_SCRIPT executable..."
        chmod +x "$BASH_SCRIPT"
    fi
    
    if ! bash -n "$BASH_SCRIPT"; then
        print_status "$RED" "Error: Bash script has syntax errors."
        exit 1
    fi
    
    print_status "$GREEN" "✓ Source files validation passed"
}

compile_c_program() {
    local C_BINARY="${C_SOURCE%.c}"
    
    print_status "$BLUE" "Compiling $C_SOURCE..."
    
    if gcc -Wall -Wextra -std=c99 -O2 -o "$C_BINARY" "$C_SOURCE"; then
        print_status "$GREEN" "✓ Successfully compiled $C_SOURCE to $C_BINARY"
    else
        print_status "$RED" "Error: Compilation of $C_SOURCE failed."
        print_status "$YELLOW" "Please check the source code for errors."
        exit 1
    fi
    
    if [[ -x "$C_BINARY" ]]; then
        print_status "$GREEN" "✓ Binary is executable"
    else
        print_status "$RED" "Error: Compiled binary is not executable"
        exit 1
    fi
}

install_files() {
    local C_BINARY="${C_SOURCE%.c}"
    
    print_status "$BLUE" "Installing files to $INSTALL_DIR..."
    
    if cp "$BASH_SCRIPT" "$INSTALL_DIR/"; then
        chmod +x "$INSTALL_DIR/$BASH_SCRIPT"
        print_status "$GREEN" "✓ Installed $BASH_SCRIPT"
    else
        print_status "$RED" "Error: Failed to install $BASH_SCRIPT"
        exit 1
    fi
    
    if cp "$C_BINARY" "$INSTALL_DIR/"; then
        chmod +x "$INSTALL_DIR/$C_BINARY"
        print_status "$GREEN" "✓ Installed $C_BINARY"
    else
        print_status "$RED" "Error: Failed to install $C_BINARY"
        exit 1
    fi
}

verify_installation() {
    print_status "$BLUE" "Verifying installation..."
    
    if [[ -x "$INSTALL_DIR/$BASH_SCRIPT" ]]; then
        print_status "$GREEN" "✓ $BASH_SCRIPT is installed and executable"
    else
        print_status "$RED" "✗ $BASH_SCRIPT installation failed"
        return 1
    fi
    
    if [[ -x "$INSTALL_DIR/signal_handler" ]]; then
        print_status "$GREEN" "✓ signal_handler is installed and executable"
    else
        print_status "$RED" "✗ signal_handler installation failed"
        return 1
    fi
    
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_status "$GREEN" "✓ $INSTALL_DIR is in PATH"
    else
        print_status "$YELLOW" "Warning: $INSTALL_DIR is not in PATH"
        print_status "$YELLOW" "You may need to add it to your PATH or use full path to run the program"
    fi
}

show_usage() {
    cat << EOF
Daemon Manager Installation Script

Usage: sudo ./install.sh [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -f, --force     Force installation (skip confirmations)
    -b, --backup    Create backup only (don't install)
    -u, --uninstall Uninstall Daemon Manager

Examples:
    sudo ./install.sh              # Normal installation
    sudo ./install.sh --force      # Force installation
    sudo ./install.sh --uninstall  # Uninstall

EOF
}

uninstall() {
    print_status "$YELLOW" "Uninstalling Daemon Manager..."
    
    local removed=0
    
    if [[ -f "$INSTALL_DIR/$BASH_SCRIPT" ]]; then
        rm "$INSTALL_DIR/$BASH_SCRIPT"
        print_status "$GREEN" "✓ Removed $BASH_SCRIPT"
        ((removed++))
    fi
    
    if [[ -f "$INSTALL_DIR/signal_handler" ]]; then
        rm "$INSTALL_DIR/signal_handler"
        print_status "$GREEN" "✓ Removed signal_handler"
        ((removed++))
    fi
    
    if [[ $removed -eq 0 ]]; then
        print_status "$YELLOW" "No Daemon Manager files found to remove"
    else
        print_status "$GREEN" "✓ Uninstallation complete ($removed files removed)"
    fi
    
    if [[ -d "$BACKUP_DIR" ]]; then
        read -p "Remove backup directory? (y/N): " remove_backup
        if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
            rm -rf "$BACKUP_DIR"
            print_status "$GREEN" "✓ Backup directory removed"
        fi
    fi
}

show_summary() {
    cat << EOF

${GREEN}=== Installation Summary ===${NC}
✓ Daemon Manager successfully installed
✓ Files installed to: $INSTALL_DIR
✓ Backup created in: $BACKUP_DIR (if applicable)

${BLUE}Usage:${NC}
  Run: ${YELLOW}DaemonManager${NC}
  
${BLUE}Features:${NC}
  • Enhanced process management
  • Real-time monitoring
  • Signal handling
  • Process statistics
  • Configuration management
  • Data export capabilities

${BLUE}For help:${NC}
  Run the program and use the built-in menu system

EOF
}

main() {
    local force_install=false
    local uninstall_mode=false
    local backup_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -f|--force)
                force_install=true
                shift
                ;;
            -u|--uninstall)
                uninstall_mode=true
                shift
                ;;
            -b|--backup)
                backup_only=true
                shift
                ;;
            *)
                print_status "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    if [[ $EUID -ne 0 ]]; then
        print_status "$RED" "Error: This script must be run as root (use sudo)"
        print_status "$YELLOW" "Usage: sudo ./install.sh"
        exit 1
    fi
    
    print_status "$BLUE" "Daemon Manager Installation Script"
    print_status "$BLUE" "=================================="
    
    if [[ "$uninstall_mode" == true ]]; then
        uninstall
        exit 0
    fi
    
    if [[ "$backup_only" == true ]]; then
        create_backup
        print_status "$GREEN" "✓ Backup completed"
        exit 0
    fi
    
    if [[ "$force_install" == false ]]; then
        read -p "Proceed with installation? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_status "$YELLOW" "Installation cancelled"
            exit 0
        fi
    fi
    
    check_prerequisites
    validate_files
    create_backup
    compile_c_program
    install_files
    verify_installation
    
    print_status "$GREEN" "✓ Installation completed successfully!"
    show_summary
}

main "$@"
