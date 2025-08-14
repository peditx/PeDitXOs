#!/bin/sh

# PeDitXOS Service Runner v1
# This script contains the installation logic for Store applications.

ACTION="$1"

# --- URLs (to keep logs clean) ---
URL_TORPLUS="https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh"
URL_SSHPLUS="https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh"
URL_AIRCAST="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh"
URL_WARP="https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/install.sh"

# --- Function Definitions ---

install_torplus() {
    echo "Downloading TORPlus components..."
    cd /tmp && rm -f *.sh && wget -q "$URL_TORPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_sshplus() {
    echo "Downloading SSHPlus components..."
    cd /tmp && rm -f *.sh && wget -q "$URL_SSHPLUS" -O install_sshplus.sh && sh install_sshplus.sh
}

install_aircast() {
    echo "Downloading Air-Cast components..."
    cd /tmp && rm -f *.sh && wget -q "$URL_AIRCAST" -O aircast_install.sh && sh aircast_install.sh
}

install_warp() {
    echo "Downloading Warp+ components..."
    cd /tmp && rm -f install.sh && wget -q "$URL_WARP" -O install.sh && chmod +X install.sh && sh install.sh
}

change_repo() {
    echo "Changing to PeDitX Repo..."
    # Add actual commands here in the future
    echo "Repository change function is a placeholder."
}

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

# --- Main Execution Block ---
case "$ACTION" in
    install_torplus) install_torplus ;;
    install_sshplus) install_sshplus ;;
    install_aircast) install_aircast ;;
    install_warp) install_warp ;;
    change_repo) change_repo ;;
    install_wol) install_wol ;;
    cleanup_memory) cleanup_memory ;;
    *) exit 1 ;; # Exit if action is not found
esac

exit 0
