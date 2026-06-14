#!/bin/bash

echo "----------------------------------------------------"
echo "           PeDitXOS Expand Root Utility             "
echo "----------------------------------------------------"

echo "Running as root..."
sleep 2
clear

# Package manager detection
install_pkg() {
    if command -v apk >/dev/null 2>&1; then
        apk add "$@"
    elif command -v opkg >/dev/null 2>&1; then
        opkg install "$@"
    else
        echo "No package manager found (apk or opkg). Exiting."
        exit 1
    fi
}

# Update and install required packages
if command -v apk >/dev/null 2>&1; then
    apk update
elif command -v opkg >/dev/null 2>&1; then
    opkg update
fi

sleep 2
install_pkg parted losetup resize2fs blkid
sleep 2

# Download expand-root.sh from OpenWrt wiki
wget -U "" -O expand-root.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/expand_root?codeblock=0"

if [ ! -f expand-root.sh ]; then
    echo "Failed to download expand-root.sh"
    exit 1
fi

# Source the script (creates uci-defaults scripts)
. ./expand-root.sh

# Run the first resize script
if [ -f /etc/uci-defaults/70-rootpt-resize ]; then
    sh /etc/uci-defaults/70-rootpt-resize
else
    echo "70-rootpt-resize not found. Expansion may have failed."
    exit 1
fi

echo "----------------------------------------------------"
echo "  Expand Setup Finished Successfully. Made By : PeDitX     "
echo "----------------------------------------------------"

# The script will reboot automatically as part of the resize process
# No need to add extra reboot here
