#!/bin/sh

ACTION="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"
LOG_FILE="/tmp/peditxos_log.txt"
LOCK_FILE="/tmp/peditx.lock"

# --- Lock File and Logging Setup ---
if [ -f "$LOCK_FILE" ]; then
    echo ">>> Another process is already running. Please wait for it to finish." >> "$LOG_FILE"
    exit 1
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT TERM INT
exec >> "$LOG_FILE" 2>&1

# --- Function Definitions ---
install_torplus() {
    echo "Installing TORPlus via official script..."
    cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh && chmod +x install.sh && sh install.sh
}

install_sshplus() {
    echo "Installing SSHPlus via official script..."
    cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh && sh install_sshplus.sh
}

install_aircast() {
    echo "Installing Air-Cast via official script..."
    cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh && sh aircast_install.sh
}

install_warp() {
    echo "Installing Warp+..."
    cd /tmp
    rm -f install.sh && wget https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/install.sh && chmod +X install.sh && sh install.sh
    echo "Warp+ installation script executed."
}

install_pw1() {
    echo "Installing Passwall 1..."
    cd /tmp
    rm -f passwall.sh
    wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwall.sh -O passwall.sh
    chmod +x passwall.sh
    sh passwall.sh
    echo "Passwall 1 installed successfully."
}

install_pw2() {
    echo "Installing Passwall 2..."
    cd /tmp
    rm -f passwall2.sh
    wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwall2.sh -O passwall2.sh
    chmod +x passwall2.sh
    sh passwall2.sh
    echo "Passwall 2 installed successfully."
}

install_both() {
    echo "Installing both Passwall 1 and Passwall 2..."
    cd /tmp
    rm -f passwalldue.sh
    wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwalldue.sh -O passwalldue.sh
    chmod +x passwalldue.sh
    sh passwalldue.sh
    echo "Both Passwall versions installed successfully."
}

easy_exroot() {
    echo "Running Easy Exroot script..."
    cd /tmp
    curl -ksSL https://github.com/peditx/ezexroot/raw/refs/heads/main/ezexroot.sh -o ezexroot.sh
    sh ezexroot.sh
    echo "Easy Exroot script finished."
}

uninstall_all() {
    echo "Uninstalling all PeDitXOS related packages..."
    opkg remove luci-app-passwall luci-app-passwall2 luci-app-torplus luci-app-sshplus luci-app-aircast luci-app-dns-changer
    echo "Uninstallation complete."
}

set_dns() {
    local provider="$1"
    local dns1="$2"
    local dns2="$3"
    local servers

    echo "Setting DNS to $provider..."
    case "$provider" in
        shecan)   servers="178.22.122.100 185.51.200.2" ;;
        electro)  servers="78.157.42.100 78.157.42.101" ;;
        cloudflare) servers="1.1.1.1 1.0.0.1" ;;
        google)   servers="8.8.8.8 8.8.4.4" ;;
        begzar)   servers="185.55.226.26 185.55.225.25" ;;
        radar)    servers="10.202.10.10 10.202.10.11" ;;
        custom)   servers="$dns1 $dns2" ;;
        *) echo "Error: Invalid DNS provider '$provider'."; return 1 ;;
    esac

    uci set network.wan.peerdns='0'
    uci set network.wan.dns='' 
    for server in $servers; do
        if [ -n "$server" ]; then
            uci add_list network.wan.dns="$server"
        fi
    done
    uci commit network
    /etc/init.d/network restart
    echo "DNS servers updated successfully."
}

set_wifi_config() {
    local ssid="$1"
    local key="$2"
    local band="$3"
    echo "Configuring WiFi (SSID: $ssid, Band: $band)..."
    echo "WiFi configuration is a placeholder. Implement actual UCI commands here."
}

set_lan_ip() {
    local ipaddr="$1"
    echo "Setting LAN IP to $ipaddr..."
    uci set network.lan.ipaddr="$ipaddr"
    uci commit network
    echo "LAN IP will be changed after the next network restart or system reboot."
}

change_repo() {
    echo "Changing to PeDitX Repo..."
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

get_system_info() {
    echo "Fetching system information..."
    (
        echo "Hostname: $(hostname)"
        echo "OpenWrt Version: $(cat /etc/openwrt_release)"
        echo "Kernel Version: $(uname -a)"
        echo "CPU Info: $(cat /proc/cpuinfo | grep 'model name' | uniq)"
        echo "Memory: $(free -h | grep 'Mem:' | awk '{print $2}')"
        echo "Disk Usage: $(df -h / | awk 'NR==2 {print $2, $3, $4}')"
    )
    echo "System information fetched."
}

install_opt_packages() {
    echo "Installing selected packages..."
    local packages_to_install="$1"
    
    if [ -z "$packages_to_install" ]; then
        echo "No packages selected to install."
        return 0
    fi

    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Installing whiptail..."
        opkg update && opkg install whiptail
        if [ $? -ne 0 ]; then
            echo "Failed to install whiptail. Exiting..."
            return 1
        fi
    fi

    echo "Updating package lists..."
    opkg update

    for package_name in $packages_to_install; do
        echo "Installing $package_name..."
        opkg install "$package_name"
        if [ $? -eq 0 ]; then
            echo "$package_name installed successfully."
        else
            echo "Failed to install $package_name."
        fi
    done

    if opkg list-installed | grep -q "^sing-box "; then
        echo "Configuring SingBoX shunt..."
        uci set passwall2.MainShunt=nodes
        uci set passwall2.MainShunt.remarks='SingBoX-Shunt'
        uci set passwall2.MainShunt.type='Sing-Box'
        uci set passwall2.MainShunt.protocol='_shunt'
        uci set passwall2.MainShunt.Direct='_direct'
        uci set passwall2.MainShunt.DirectGame='_default'
        uci commit passwall2
        echo "SingBoX shunt configured successfully."
    else
        echo "SingBoX is not installed. Skipping shunt configuration."
    fi
}

apply_cpu_opts() {
    echo "Applying CPU optimizations..."
    for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$CPU" ] && echo "performance" > "$CPU"
    done
    echo "CPU optimizations applied."
}

apply_mem_opts() {
    echo "Applying Memory optimizations..."
    sysctl -w vm.swappiness=10
    sysctl -w vm.vfs_cache_pressure=50
    echo "Memory optimizations applied."
}

apply_net_opts() {
    echo "Applying Network optimizations..."
    if ! opkg list-installed | grep -q "kmod-tcp-bbr"; then
        echo "Installing kmod-tcp-bbr for congestion control..."
        opkg update
        opkg install kmod-tcp-bbr
    fi
    sysctl -w net.ipv4.tcp_fastopen=3
    sysctl -w net.ipv4.tcp_congestion_control=bbr
    echo "Network optimizations applied."
}

apply_usb_opts() {
    echo "Applying USB optimizations..."
    echo "USB optimizations placeholder."
}

enable_luci_wan() {
    echo "Enabling LuCI on WAN..."
    uci set firewall.@rule[0].dest_port=80
    uci set firewall.@rule[1].dest_port=443
    uci commit firewall
    /etc/init.d/firewall restart
    echo "LuCI is now accessible from WAN."
}

expand_root() {
    echo "---"
    echo "CRITICAL WARNING: Expanding root partition... THIS WILL WIPE ALL DATA!"
    echo "---"
    echo "Downloading and preparing the expansion script..."
    cd /tmp
    wget https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/.files/expand.sh -O expand.sh
    chmod +x expand.sh
    echo "---"
    echo "--- ACTION REQUIRED ---"
    echo "The expansion script is about to run. The system will reboot automatically."
    echo "After reboot, the process will continue. Please be patient."
    echo "-----------------------"
    sh expand.sh
    # The script will likely not reach this point as a reboot is expected.
    echo "Expansion script initiated. System should be rebooting now."
}

restore_opt_backup() {
    echo "Restoring config backup..."
    echo "Restore config backup command placeholder."
}

reboot_system() {
    echo "Rebooting system in 5 seconds..."
    sleep 5
    reboot
}

# --- Main Execution Block ---
echo ">>> Starting action: $ACTION at $(date)"
echo "--------------------------------------"

EXIT_CODE=0
case "$ACTION" in
    install_torplus) install_torplus ;;
    install_sshplus) install_sshplus ;;
    install_aircast) install_aircast ;;
    install_warp) install_warp ;;
    install_pw1) install_pw1 ;;
    install_pw2) install_pw2 ;;
    install_both) install_both ;;
    easy_exroot) easy_exroot ;;
    uninstall_all) uninstall_all ;;
    set_dns_shecan) set_dns "shecan" ;;
    set_dns_electro) set_dns "electro" ;;
    set_dns_cloudflare) set_dns "cloudflare" ;;
    set_dns_google) set_dns "google" ;;
    set_dns_begzar) set_dns "begzar" ;;
    set_dns_radar) set_dns "radar" ;;
    set_dns_custom) set_dns "custom" "$ARG1" "$ARG2" ;;
    set_wifi_config) set_wifi_config "$ARG1" "$ARG2" "$ARG3" ;;
    set_lan_ip) set_lan_ip "$ARG1" ;;
    change_repo) change_repo ;;
    install_wol) install_wol ;;
    cleanup_memory) cleanup_memory ;;
    get_system_info) get_system_info ;;
    opkg_update) opkg update ;;
    install_opt_packages | install_extra_packages) install_opt_packages "$ARG1" ;;
    apply_cpu_opts) apply_cpu_opts ;;
    apply_mem_opts) apply_mem_opts ;;
    apply_net_opts) apply_net_opts ;;
    apply_usb_opts) apply_usb_opts ;;
    enable_luci_wan) enable_luci_wan ;;
    expand_root) expand_root ;;
    restore_opt_backup) restore_opt_backup ;;
    reboot_system) reboot_system ;;
    clear_log) echo "Log cleared by user at $(date)" > "$LOG_FILE" ;;
    *) echo "ERROR: Unknown or unsupported action '$ACTION'." ;;
esac
EXIT_CODE=$?

echo "--------------------------------------"
if [ $EXIT_CODE -eq 0 ]; then
    echo "Action completed successfully at $(date)."
else
    echo "Action failed with exit code $EXIT_CODE at $(date)."
fi
echo ">>> SCRIPT FINISHED <<<"
exit 0
