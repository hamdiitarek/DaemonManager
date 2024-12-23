# Daemon Manager

## Overview
`DaemonManager` is a project that combines a Bash script and a C program to manage daemons and signals. The project includes:

1. A Bash script (`DaemonManager`) to manage daemonized tasks.
2. A C program (`signal_handler.c`) to handle signals for the daemons.

## Features
- Install the script and binary to `/usr/local/bin` for system-wide usage.
- Provide an intuitive way to manage background processes.

## Prerequisites
- A Linux environment with:
  - `bash`
  - `gcc`
- Root (sudo) privileges for installation.

## Installation
To install `DaemonManager` and the associated C program:

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/daemon-manager.git
   cd daemon-manager
   chmod +x install.sh
   ```

2. Run the `install.sh` script as root:
   ```bash
   sudo ./install.sh
   ```

### Script Details
The `install.sh` script:
- Checks for root privileges.
- Validates the existence of `DaemonManager` and `signal_handler.c`.
- Compiles `signal_handler.c` into an executable binary.
- Installs both the Bash script and the compiled binary to `/usr/local/bin`.

## Usage
After installation, you can use `DaemonManager` by simply typing:

```bash
DaemonManager
```

Ensure that the installed script and binary have execute permissions. The installation script takes care of this automatically.

## Files
- **DaemonManager**: The main Bash script for daemon management.
- **signal_handler.c**: A C program that handles signals.

## Uninstallation
To uninstall `DaemonManager` and its components:

1. Remove the installed files:
   ```bash
   sudo rm /usr/local/bin/DaemonManager /usr/local/bin/signal_handler
   ```

## Contributing
Contributions are welcome! Feel free to fork this repository and submit a pull request.

## License
This project is licensed under the [MIT License](LICENSE).

