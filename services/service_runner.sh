#!/bin/sh

# PeDitXOS Service Runner v4 - Hybrid (Local Commands + Remote Manifest)

ACTION="$1"

# --- 1. Define Local Functions ---
# These are commands that run directly on the system and don't have an install URL.

install_wol() {
    echo "Installing Wake On Lan..."
    opkg update
    opkg install luci-app-wol
    echo "Wake On Lan installed successfully."
}

cleanup_memory() {
    echo "Cleaning up memory..."
    sync && echo 3 > /proc/sys/vm/drop_caches
    echo "Memory cleanup complete."
}

# --- 2. Check if the action is a local command FIRST ---
case "$ACTION" in
    install_wol)
        install_wol
        exit 0
        ;;
    cleanup_memory)
        cleanup_memory
        exit 0
        ;;
    *)
        # If it's not a known local command, proceed to remote installation
        echo "Action '$ACTION' is not a local command. Checking remote manifest..."
        ;;
esac

# --- 3. Remote Installation via Manifest ---
# This part handles all installs that have a URL in the manifest.

MANIFEST_URL="https://raw.githubusercontent.com/peditx/releases/main/services/install_manifest.json"
TEMP_MANIFEST="/tmp/install_manifest.json"

# Check for required tools
if ! command -v wget >/dev/null || ! command -v jq >/dev/null; then
    echo "Error: 'wget' and 'jq' are required. Please install them. (opkg update && opkg install wget jq)"
    exit 1
fi

# Fetch the latest manifest file
echo "Fetching latest installation manifest..."
wget -q "$MANIFEST_URL" -O "$TEMP_MANIFEST"
if [ $? -ne 0 ] || [ ! -s "$TEMP_MANIFEST" ]; then
    echo "Error: Could not download the installation manifest. Check internet connection."
    rm -f "$TEMP_MANIFEST"
    exit 1
fi

# Find the URL for the requested action using jq
INSTALL_URL=$(jq -r --arg action "$ACTION" '.scripts[] | select(.id == $action) | .url' "$TEMP_MANIFEST")

# Clean up the manifest file immediately
rm -f "$TEMP_MANIFEST"

# Check if a URL was found
if [ -z "$INSTALL_URL" ] || [ "$INSTALL_URL" = "null" ]; then
    echo "Error: Action '$ACTION' not found in the manifest."
    exit 1
fi

# Download and execute the script
echo "Action '$ACTION' found. Downloading from: $INSTALL_URL"
INSTALL_SCRIPT="/tmp/${ACTION}_install.sh"
wget -q "$INSTALL_URL" -O "$INSTALL_SCRIPT"

if [ $? -ne 0 ] || [ ! -s "$INSTALL_SCRIPT" ]; then
    echo "Error: Failed to download the installation script."
    rm -f "$INSTALL_SCRIPT"
    exit 1
fi

echo "Executing installation script..."
chmod +x "$INSTALL_SCRIPT"
sh "$INSTALL_SCRIPT"

# Final cleanup
rm -f "$INSTALL_SCRIPT"

exit 0

