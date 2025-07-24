CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
TARGET = signal_handler
SOURCE = signal_handler.c
INSTALL_DIR = /usr/local/bin
BASH_SCRIPT = DaemonManager

.PHONY: all clean install uninstall test

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)
	rm -f *.o

install: all
	@echo "Installing Daemon Manager..."
	sudo cp $(TARGET) $(INSTALL_DIR)/
	sudo cp $(BASH_SCRIPT) $(INSTALL_DIR)/
	sudo chmod +x $(INSTALL_DIR)/$(TARGET)
	sudo chmod +x $(INSTALL_DIR)/$(BASH_SCRIPT)
	@echo "Installation complete!"

uninstall:
	@echo "Uninstalling Daemon Manager..."
	sudo rm -f $(INSTALL_DIR)/$(TARGET)
	sudo rm -f $(INSTALL_DIR)/$(BASH_SCRIPT)
	@echo "Uninstallation complete!"

test: $(TARGET)
	@echo "Running basic tests..."
	./$(TARGET) --help || true
	@echo "Tests complete!"

debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)

help:
	@echo "Available targets:"
	@echo "  all       - Build the signal handler (default)"
	@echo "  clean     - Remove built files"
	@echo "  install   - Install Daemon Manager system-wide"
	@echo "  uninstall - Remove Daemon Manager from system"
	@echo "  test      - Run basic tests"
	@echo "  debug     - Build with debug symbols"
	@echo "  help      - Show this help message"
