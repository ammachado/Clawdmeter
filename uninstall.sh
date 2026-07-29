#!/bin/bash
# Remove the Linux systemd user service and Clawdmeter-managed local state.
set -u

SERVICE_NAME="claude-usage-daemon"
USER_SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_PATH="$USER_SERVICE_DIR/$SERVICE_NAME.service"
CONFIG_DIR="$HOME/.config/claude-usage-monitor"

echo "=== Clawdmeter Linux uninstall ==="

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop "$SERVICE_NAME" 2>/dev/null || true
    systemctl --user disable "$SERVICE_NAME" 2>/dev/null || true
else
    echo "  systemctl not found; removing the generated unit file only."
fi

if [ -f "$SERVICE_PATH" ]; then
    rm -f "$SERVICE_PATH"
    echo "  Removed: $SERVICE_PATH"
else
    echo "  Already absent: $SERVICE_PATH"
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
fi

if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "  Removed: $CONFIG_DIR"
else
    echo "  Already absent: $CONFIG_DIR"
fi

echo ""
echo "=== Uninstall complete ==="
echo "Bluetooth pairing, Claude credentials, and this repository were preserved."
