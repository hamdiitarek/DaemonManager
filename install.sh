BASH_SCRIPT="DaemonManager"
C_SOURCE="signal_handler.c"
INSTALL_DIR="/usr/local/bin"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo ./install.sh)"
  exit 1
fi

if [ ! -f "$BASH_SCRIPT" ]; then
  echo -e "\nError: Bash script $BASH_SCRIPT not found."
  exit 1
fi

if [ ! -f "$C_SOURCE" ]; then
  echo -e "Error: source file $C_SOURCE not found."
  exit 1
fi

C_BINARY="${C_SOURCE%.c}"
echo "Compiling $C_SOURCE to $C_BINARY..."
if ! gcc -o "$C_BINARY" "$C_SOURCE"; then
  echo "Error: Compilation of $C_SOURCE failed."
  exit 1
fi

echo -e "\nInstalling $BASH_SCRIPT to $INSTALL_DIR..."

if ! cp "$BASH_SCRIPT" "$INSTALL_DIR/"; then
  echo "Error: Failed to copy $BASH_SCRIPT to $INSTALL_DIR."
  exit 1
fi
chmod +x "$INSTALL_DIR/$BASH_SCRIPT"

echo -e "\nInstalling $C_BINARY to $INSTALL_DIR..."

if ! cp "$C_BINARY" "$INSTALL_DIR/"; then
  echo -e "\nError: Failed to copy $C_BINARY to $INSTALL_DIR."
  exit 1
fi

chmod +x "$INSTALL_DIR/$C_BINARY"

echo -e "\nInstallation complete!"
echo -e "\nThe bash script has been installed as $INSTALL_DIR/$BASH_SCRIPT"
echo -e "\nTo Run Program type "DaemonManager""
