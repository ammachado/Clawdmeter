#!/bin/bash
# Remove the macOS LaunchAgent and Clawdmeter-managed local state.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_LABEL="com.user.claude-usage-daemon"
PLIST_DST="$HOME/Library/LaunchAgents/$SERVICE_LABEL.plist"
LOG_OUT="$HOME/Library/Logs/claude-usage-daemon.out.log"
LOG_ERR="$HOME/Library/Logs/claude-usage-daemon.err.log"
CONFIG_DIR="$HOME/.config/claude-usage-monitor"
VENV_DIR="$SCRIPT_DIR/.venv"

echo "=== Clawdmeter macOS uninstall ==="

if command -v launchctl >/dev/null 2>&1; then
    launchctl unload "$PLIST_DST" 2>/dev/null || true
fi

for path in "$PLIST_DST" "$LOG_OUT" "$LOG_ERR"; do
    if [ -e "$path" ]; then
        rm -f "$path"
        echo "  Removed: $path"
    else
        echo "  Already absent: $path"
    fi
done

for path in "$VENV_DIR" "$CONFIG_DIR"; do
    if [ -d "$path" ]; then
        rm -rf "$path"
        echo "  Removed: $path"
    else
        echo "  Already absent: $path"
    fi
done

echo ""
echo "=== Uninstall complete ==="
echo "Bluetooth pairing, Claude credentials, uv, blueutil, and this repository were preserved."
