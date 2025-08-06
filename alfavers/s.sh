#!/bin/sh

# PeDitXOS Tools - Simplified Installer Script v59 (Patched)
# This version fixes the Start/Stop race condition and improves logging.

# --- Banner and Profile Configuration ---
cat > /etc/banner << "EOF"
 ______     _____   _     _   _    _____      
(_____ \   (____ \ (_)_   \ \ / /   / ___ \     
 _____) )___ _   \ \ _| |_  \ \/ /   | |   | | ___ 
|  ____/ _  ) |   | | |  _)  )  (    | |   | |/___)
| |   ( (/ /| |__/ /| | |__ / /\ \   | |___| |___ |
|_|    \____)_____/ |_|\___)_/  \_\   \_____/(___/ 
                                                  
HTTPS://PEDITX.IR   
telegram : @PeDitX
EOF

echo ">>> Configuring system profile and bash settings..."
mkdir -p /etc/profile.d
wget -q https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/.files/profile -O /etc/
wget -q https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/.files/30-sysinfo.sh -O /etc/profile.d/30-sysinfo.sh
wget -q https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/.files/sys_bashrc.sh -O /etc/profile.d/sys_bashrc.sh
chmod +x /etc/profile.d/30-sysinfo.sh
chmod +x /etc/profile.d/sys_bashrc.sh
echo "Profile configuration complete."
# --- End of Configuration ---

echo ">>> Step 1: Initial system configuration..."
# Basic system setup
uci set system.@system[0].zonename='Asia/Tehran'
uci set system.@system[0].hostname='PeDitXOS'
uci commit system
sed -i 's/DISTRIB_ID=.*/DISTRIB_ID="PeDitXOS"/' /etc/openwrt_release
sed -i 's/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION="PeDitX OS telegram:@peditx"/' /etc/openwrt_release
opkg update
opkg install curl luci-compat screen sshpass procps-ng-pkill luci-app-ttyd coreutils coreutils-base64 coreutils-nohup
echo "System configuration complete."

# --- Theme Installation ---
echo "Starting theme installation..."

# Function to install a theme from a repository
install_theme() {
    local REPO_NAME=$1
    local THEME_NAME=$2
    local LATEST_RELEASE_URL="https://api.github.com/repos/peditx/$REPO_NAME/releases/latest"

    echo "Processing $THEME_NAME..."
    
    # Get the .ipk download URL
    IPK_URL=$(curl -s "$LATEST_RELEASE_URL" | grep "browser_download_url.*ipk" | cut -d '"' -f 4)

    if [ -z "$IPK_URL" ]; then
        echo "Error: Download link for the .ipk file of $THEME_NAME not found."
        return 1
    fi

    local filename="/tmp/$THEME_NAME.ipk"
    
    # Download the .ipk package
    echo "Downloading the latest version of $THEME_NAME..."
    if ! wget -q "$IPK_URL" -O "$filename"; then
        echo "Error: Failed to download $THEME_NAME."
        return 1
    fi

    # Install the .ipk package
    echo "Installing $THEME_NAME..."
    if ! opkg install "$filename"; then
        echo "Error: Failed to install $THEME_NAME."
        return 1
    fi

    # Clean up the downloaded file
    rm -f "$filename"
    echo "$THEME_NAME installed successfully."
    return 0
}

# 1. Prepare /var/lock directory
if [ ! -d "/var/lock" ]; then
    echo "Creating /var/lock directory..."
    mkdir -p /var/lock
fi

# 2. Install themes
install_theme "luci-theme-peditx" "luci-theme-peditx"
install_theme "luci-theme-carbonpx" "luci-theme-carbonpx"

# 3. Remove old theme
echo "Removing default luci-theme-bootstrap..."
opkg remove luci-theme-bootstrap --force-depends

# 4. Install themeswitch
themeswitch_version=$(curl -s https://api.github.com/repos/peditx/luci-app-themeswitch/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$themeswitch_version" ]; then
    echo "Error: Failed to fetch the latest themeswitch version!"
    exit 1
fi

pkg_arch=$(opkg print-architecture | awk '{print $2}')
themeswitch_url=""

for arch in $pkg_arch; do
    case "$arch" in
        aarch64_cortex-a53|aarch64_cortex-a72|aarch64_generic|\
        arm_cortex-a15_neon-vfpv4|arm_cortex-a5_vfpv4|arm_cortex-a7|\
        arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|\
        arm_cortex-a9_neon|arm_cortex-a9_vfpv3-d16|mipsel_24kc|\
        mipsel_74kc|mipsel_mips32|mips_24kc|mips_4kec|mips_mips32|x86_64)
            themeswitch_url="https://github.com/peditx/luci-app-themeswitch/releases/download/${themeswitch_version}/luci-app-themeswitch_${themeswitch_version}_${arch}.ipk"
            break
            ;;
    esac
done

if [ -z "$themeswitch_url" ]; then
    echo "Error: Unsupported CPU architecture detected for themeswitch."
    exit 1
fi

pkg_name="luci-app-themeswitch"
filename="/tmp/luci-app-themeswitch.ipk"
echo "Downloading $pkg_name..."
if ! wget -q "${themeswitch_url}" -O "${filename}"; then
    echo "Error: Failed to download $pkg_name."
    exit 1
fi

echo "Installing $pkg_name..."
if ! opkg install "${filename}"; then
    echo "Error: Failed to install $pkg_name."
    exit 1
fi
rm -f "$filename"
echo "$pkg_name installed successfully."

# 5. Restart the web service
echo "Restarting uhttpd service to apply changes..."
/etc/init.d/uhttpd restart

echo "Installation completed successfully. 🎉"
# --- End of Theme Installation ---

echo ">>> Step 2: Creating/Updating the LuCI application..."
mkdir -p /usr/lib/lua/luci/controller /usr/lib/lua/luci/model/cbi /usr/lib/lua/luci/view/peditxos
echo "Application directories created."

# Create the Runner Script (v59 - Synchronous execution)
cat > /usr/bin/peditx_runner.sh << 'EOF'
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
EOF
chmod +x /usr/bin/peditx_runner.sh
echo "Runner script created/updated."

# Create the Controller file (v59 - Reworked backgrounding)
cat > /usr/lib/lua/luci/controller/peditxos.lua << 'EOF'
module("luci.controller.peditxos", package.seeall)
function index()
    entry({"admin", "peditxos"}, firstchild(), "PeDitXOS Tools", 40).dependent = false
    entry({"admin", "peditxos", "dashboard"}, template("peditxos/main"), "Dashboard", 1)
    entry({"admin", "peditxos", "status"}, call("get_status")).json = true
    entry({"admin", "peditxos", "run"}, call("run_script")).json = true
end

function get_status()
    local nixio = require "nixio"
    local log_file = "/tmp/peditxos_log.txt"
    local lock_file = "/tmp/peditx.lock"
    
    local content = ""
    local f = io.open(log_file, "r")
    if f then content = f:read("*a"); f:close() end
    
    local is_running = nixio.fs.access(lock_file)
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({ running = is_running, log = content })
end

function run_script()
    local action = luci.http.formvalue("action")
    if not action or not action:match("^[a-zA-Z0-9_.-]+$") then
        luci.http.prepare_content("application/json")
        luci.http.write_json({success = false, error = "Invalid action"})
        return
    end

    if action == "stop_process" then
        luci.sys.exec("pkill -f '/usr/bin/peditx_runner.sh' >/dev/null 2>&1")
        luci.sys.exec("rm -f /tmp/peditx.lock")
        luci.sys.exec("echo '\n>>> Process stopped by user at $(date) <<<' >> /tmp/peditxos_log.txt")
        luci.http.prepare_content("application/json")
        luci.http.write_json({success = true})
        return
    elseif action == "clear_log" then
        luci.sys.exec("echo 'Log cleared by user at $(date)' > /tmp/peditxos_log.txt")
        luci.http.prepare_content("application/json")
        luci.http.write_json({success = true})
        return
    end
    
    local cmd = "/usr/bin/peditx_runner.sh " .. action
    
    if action == "set_dns_custom" then
        cmd = cmd .. " '" .. (luci.http.formvalue("dns1") or "") .. "' '" .. (luci.http.formvalue("dns2") or "") .. "'"
    elseif action == "install_extra_packages" or action == "install_opt_packages" then
        cmd = cmd .. " '" .. (luci.http.formvalue("packages") or "") .. "'"
    elseif action == "set_wifi_config" then
        cmd = cmd .. " '" .. (luci.http.formvalue("ssid") or "") .. "' '" .. (luci.http.formvalue("key") or "") .. "' '" .. (luci.http.formvalue("band") or "") .. "'"
    elseif action == "set_lan_ip" then
        cmd = cmd .. " '" .. (luci.http.formvalue("ipaddr") or "") .. "'"
    end
    
    -- Launch the runner script as a detached background process.
    -- The runner script handles its own logging and lock file.
    luci.sys.exec("nohup " .. cmd .. " &")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end
EOF
chmod 644 /usr/lib/lua/luci/controller/peditxos.lua
echo "Controller file created."

# Create the View file (MODIFIED)
cat > /usr/lib/lua/luci/view/peditxos/main.htm << 'EOF'
<%# LuCI - Lua Configuration Interface v58 %>
<%+header%>
<style>
    :root {
        --peditx-primary: #00b5e2;
        --peditx-orange: #ffae42;
        --peditx-dark-bg: #2d2d2d;
        --peditx-card-bg: #3a3a3a;
        --peditx-border: #444;
        --peditx-text-color: #f0f0f0;
        --peditx-hover-bg: #454545;
        --peditx-focus-ring: #008eb2;
        --peditx-red: #e74c3c;
        --peditx-red-hover: #c0392b;
        --peditx-pink: #ff79c6;
        --peditx-pink-hover: #ff55b3;
    }
    body { color: var(--peditx-text-color); }
    
    .peditx-tabs { display: flex; border-bottom: 1px solid var(--peditx-border); margin-bottom: 20px; flex-wrap: wrap; }
    .peditx-tab-link { background-color: var(--peditx-card-bg); border: none; border-bottom: 3px solid transparent; outline: none; cursor: pointer; padding: 14px 20px; transition: color 0.3s, background-color 0.3s, border-color 0.3s; font-size: 16px; font-weight: 500; color: #bbb; margin-right: 5px; margin-bottom: -1px; border-top-left-radius: 8px; border-top-right-radius: 8px; }
    .peditx-tab-link:hover { color: var(--peditx-text-color); background-color: var(--peditx-hover-bg); }
    .peditx-tab-link.active { color: #1a1a1a; background: linear-gradient(135deg, #ffae42, #ff8c00); border-bottom: 3px solid transparent; font-weight: 700; }
    .peditx-tab-content { display: none; padding: 6px 12px; border-top: none; }

    .action-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 15px; }
    .action-item { background: var(--peditx-card-bg); padding: 15px; border-radius: 8px; display: flex; align-items: center; cursor: pointer; border: 1px solid var(--peditx-border); transition: transform 0.2s, box-shadow 0.2s, background 0.2s; }
    .action-item:hover { transform: translateY(-3px); box-shadow: 0 4px 10px rgba(0,0,0,0.3); background: var(--peditx-hover-bg); }
    .action-item input[type="radio"], .pkg-item input[type="checkbox"] { margin-right: 15px; transform: scale(1.2); cursor: pointer; }
    .action-item input[type="radio"]:checked + label { color: var(--peditx-orange); font-weight: bold; }
    .action-item label, .pkg-item label { cursor: pointer; width: 100%; }
    .execute-bar { margin-top: 25px; text-align: center; display: flex; justify-content: center; gap: 20px; }

    @keyframes pulse { 0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 140, 0, 0.7), 0 4px 15px rgba(0,0,0,0.3); } 70% { transform: scale(1.02); box-shadow: 0 0 0 10px rgba(255, 140, 0, 0), 0 6px 25px rgba(0,0,0,0.4); } 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 140, 0, 0), 0 4px 15px rgba(0,0,0,0.3); } }

    .peditx-main-button { font-size: 18px; padding: 16px 45px; color: #1a1a1a; font-weight: bold; border: none; border-radius: 50px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); transition: background 0.3s ease, transform 0.2s ease; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; text-shadow: 0 1px 1px rgba(255,255,255,0.2); }
    #execute-button { background: linear-gradient(135deg, var(--peditx-orange), #ff8c00); animation: pulse 2.5s infinite; }
    #execute-button:hover { background: linear-gradient(135deg, #ff8c00, #e87a00); animation-play-state: paused; }
    #execute-button:disabled { background: #555; cursor: not-allowed; box-shadow: none; transform: none; animation: none; color: #999; }
    
    #stop-button { background: linear-gradient(135deg, var(--peditx-red), var(--peditx-red-hover)); }
    #stop-button:hover { background: linear-gradient(135deg, var(--peditx-red-hover), #a03228); }

    .peditx-log-container { background-color: var(--peditx-dark-bg); color: var(--peditx-text-color); font-family: monospace; padding: 15px; border-radius: 8px; height: 350px; overflow-y: scroll; white-space: pre-wrap; border: 1px solid var(--peditx-border); margin-top: 10px; box-shadow: inset 0 0 5px rgba(0,0,0,0.2); }
    .peditx-status { padding: 15px; margin-top: 20px; background-color: var(--peditx-card-bg); border-radius: 8px; text-align: center; font-weight: bold; border: 1px solid var(--peditx-border); color: var(--peditx-orange); }
    .input-group { display: flex; flex-direction: column; gap: 10px; margin-top: 15px; }
    .cbi-input-text, .cbi-input-password, .cbi-input-select { background-color: var(--peditx-card-bg); border: 1px solid var(--peditx-border); color: var(--peditx-text-color); padding: 10px; border-radius: 5px; width: 100%; box-sizing: border-box; transition: border-color 0.3s, box-shadow 0.3s; }
    .cbi-input-text:focus, .cbi-input-password:focus, .cbi-input-select:focus { outline: none; border-color: var(--peditx-orange); box-shadow: 0 0 0 3px rgba(255, 140, 0, 0.3); }
    .pkg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 10px; margin-top: 15px; }
    .pkg-item { background: var(--peditx-card-bg); padding: 10px; border-radius: 8px; display: flex; align-items: center; border: 1px solid var(--peditx-border); transition: background 0.2s; }
    .pkg-item:hover { background: var(--peditx-hover-bg); }
    .sub-section { border: 1px solid var(--peditx-border); padding: 20px; border-radius: 8px; margin-top: 20px; }
    .log-controls { display: flex; justify-content: flex-end; align-items: center; margin-top: 20px; gap: 10px; }
    .log-controls .cbi-button { font-size: 12px; padding: 8px 15px; border-radius: 5px; background-color: var(--peditx-card-bg); color: var(--peditx-text-color); border: 1px solid var(--peditx-border); transition: background 0.2s, border-color 0.2s; cursor: pointer; }
    .log-controls .cbi-button:hover { background-color: var(--peditx-hover-bg); border-color: var(--peditx-orange); }
    #logout-button { background: linear-gradient(135deg, var(--peditx-pink), var(--peditx-pink-hover)); color: #1a1a1a; border-color: var(--peditx-pink); }
    #logout-button:hover { background: linear-gradient(135deg, var(--peditx-pink-hover), #f73ca8); border-color: var(--peditx-pink-hover); }
    .log-controls label { margin-right: 10px; cursor: pointer; user-select: none; }
    .log-controls input[type="checkbox"] { vertical-align: middle; margin-right: 5px; }
    .peditx-modal { display: none; position: fixed; z-index: 100; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.6); backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px); }
    .peditx-modal-content { background-color: var(--peditx-card-bg); color: var(--peditx-text-color); margin: 15% auto; padding: 30px; border: 1px solid var(--peditx-border); width: 90%; max-width: 450px; border-radius: 12px; box-shadow: 0 8px 20px rgba(0,0,0,0.5); }
    .peditx-modal-buttons { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
    .peditx-modal-buttons .cbi-button { padding: 10px 20px; border-radius: 20px; }
</style>

<div id="peditx-confirm-modal" class="peditx-modal">
    <div class="peditx-modal-content">
        <p id="peditx-modal-text"></p>
        <div class="peditx-modal-buttons">
            <button id="peditx-modal-yes" class="cbi-button cbi-button-apply">Yes</button>
            <button id="peditx-modal-no" class="cbi-button">No</button>
        </div>
    </div>
</div>

<div class="cbi-map">
    <h2>PeDitXOS Tools</h2>
    <div class="peditx-tabs">
        <button class="peditx-tab-link active" onclick="showTab(event, 'main-tools')">Main Tools</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'dns-changer')">DNS Changer</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'service-installer')">Service Installer</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'extra-tools')">Extra Tools</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'x86-pi-opts')">x86/Pi Opts</button>
    </div>

    <div id="main-tools" class="peditx-tab-content" style="display:block;">
        <div class="action-grid">
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_pw1" value="install_pw1"><label for="action_install_pw1">Install Passwall 1</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_pw2" value="install_pw2"><label for="action_install_pw2">Install Passwall 2</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_both" value="install_both"><label for="action_install_both">Install Passwall 1 + 2</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_easy_exroot" value="easy_exroot"><label for="action_easy_exroot">Easy Exroot</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_uninstall_all" value="uninstall_all" data-confirm="This will remove all related packages and PeDitXOS Tools itself. Are you sure?"><label for="action_uninstall_all">Uninstall All Tools</label></div>
        </div>
    </div>
    <div id="dns-changer" class="peditx-tab-content">
        <div class="action-grid">
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_shecan" value="set_dns_shecan"><label for="action_set_dns_shecan">Shecan</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_electro" value="set_dns_electro"><label for="action_set_dns_electro">Electro</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_cloudflare" value="set_dns_cloudflare"><label for="action_set_dns_cloudflare">Cloudflare</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_google" value="set_dns_google"><label for="action_set_dns_google">Google</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_begzar" value="set_dns_begzar"><label for="action_set_dns_begzar">Begzar</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_radar" value="set_dns_radar"><label for="action_set_dns_radar">Radar</label></div>
        </div>
        <div class="action-item" style="margin-top: 15px;"><input type="radio" name="peditx_action" id="action_set_dns_custom" value="set_dns_custom"><label for="action_set_dns_custom">Custom DNS</label></div>
        <div class="input-group">
            <input class="cbi-input-text" type="text" id="custom_dns1" placeholder="Custom DNS 1">
            <input class="cbi-input-text" type="text" id="custom_dns2" placeholder="Custom DNS 2 (Optional)">
        </div>
    </div>
    <div id="service-installer" class="peditx-tab-content">
        <div class="action-grid">
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_torplus" value="install_torplus"><label for="action_install_torplus">Install TORPlus</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_sshplus" value="install_sshplus"><label for="action_install_sshplus">Install SSHPlus</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_aircast" value="install_aircast"><label for="action_install_aircast">Install Air-Cast</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_warp" value="install_warp"><label for="action_install_warp">Install Warp+</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_change_repo" value="change_repo"><label for="action_change_repo">Change to PeDitX Repo</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_wol" value="install_wol"><label for="action_install_wol">Install Wake On Lan</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_cleanup_memory" value="cleanup_memory"><label for="action_cleanup_memory">Cleanup Memory</label></div>
        </div>
    </div>
    <div id="extra-tools" class="peditx-tab-content">
        <div class="sub-section">
            <h4>WiFi Settings</h4>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_wifi_config" value="set_wifi_config"><label for="action_set_wifi_config">Apply WiFi Settings Below</label></div>
            <div class="input-group">
                <input class="cbi-input-text" type="text" id="wifi_ssid" placeholder="WiFi Name (SSID)">
                <input class="cbi-input-password" type="password" id="wifi_key" placeholder="WiFi Password">
                <div style="display: flex; gap: 20px; margin-top: 5px;">
                    <label><input type="checkbox" id="wifi_band_2g" checked> Enable 2.4GHz</label>
                    <label><input type="checkbox" id="wifi_band_5g" checked> Enable 5GHz</label>
                </div>
            </div>
        </div>
        <div class="sub-section">
            <h4>LAN IP Changer</h4>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_lan_ip" value="set_lan_ip"><label for="action_set_lan_ip">Set LAN IP Address Below</label></div>
            <div class="input-group">
                <select id="lan_ip_preset" class="cbi-input-select" onchange="document.getElementById('custom_lan_ip').value = this.value">
                    <option value="10.1.1.1">Default (10.1.1.1)</option>
                    <option value="192.168.1.1">192.168.1.1</option>
                    <option value="11.1.1.1">11.1.1.1</option>
                    <option value="192.168.0.1">192.168.0.1</option>
                    <option value="">Custom</option>
                </select>
                <input class="cbi-input-text" type="text" id="custom_lan_ip" placeholder="Custom LAN IP">
            </div>
        </div>
        <div class="sub-section">
            <h4>Extra Package Installer</h4>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_extra_packages" value="install_extra_packages"><label for="action_install_extra_packages">Install Selected Packages Below</label></div>
            <div class="log-controls">
                <button class="cbi-button cbi-button-action" onclick="startActionByName('opkg_update')">Update Package Lists</button>
            </div>
            <div class="pkg-grid">
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_sing-box" value="sing-box"><label for="pkg_sing-box">Sing-Box</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_haproxy" value="haproxy"><label for="pkg_haproxy">HAProxy</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_v2ray-core" value="v2ray-core"><label for="pkg_v2ray-core">V2Ray Core</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_luci-app-v2raya" value="luci-app-v2raya"><label for="pkg_luci-app-v2raya">V2RayA App</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_luci-app-openvpn" value="luci-app-openvpn"><label for="pkg_luci-app-openvpn">OpenVPN App</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_softethervpn5-client" value="softethervpn5-client"><label for="pkg_softethervpn5-client">SoftEther Client</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_luci-app-wol" value="luci-app-wol"><label for="pkg_luci-app-wol">Wake-on-LAN App</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_luci-app-smartdns" value="luci-app-smartdns"><label for="pkg_luci-app-smartdns">SmartDNS App</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_hysteria" value="hysteria"><label for="pkg_hysteria">Hysteria</label></div>
                <div class="pkg-item"><input type="checkbox" name="extra_pkg" id="pkg_btop" value="btop"><label for="pkg_btop">btop</label></div>
            </div>
        </div>
    </div>
    <div id="x86-pi-opts" class="peditx-tab-content">
        <div class="action-grid">
            <div class="action-item"><input type="radio" name="peditx_action" id="action_get_system_info" value="get_system_info"><label for="action_get_system_info">Get System Info</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_opt_packages" value="install_opt_packages"><label for="action_install_opt_packages">Install Opt Packages</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_apply_cpu_opts" value="apply_cpu_opts"><label for="action_apply_cpu_opts">Apply CPU Opts</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_apply_mem_opts" value="apply_mem_opts"><label for="action_apply_mem_opts">Apply Memory Opts</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_apply_net_opts" value="apply_net_opts"><label for="action_apply_net_opts">Apply Network Opts</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_apply_usb_opts" value="apply_usb_opts"><label for="action_apply_usb_opts">Apply USB Opts</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_enable_luci_wan" value="enable_luci_wan" data-confirm="SECURITY WARNING: This will expose your router's web interface to the Internet! Continue?"><label for="action_enable_luci_wan">Enable LuCI on WAN</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_expand_root" value="expand_root" data-confirm="CRITICAL WARNING: This will WIPE ALL DATA on your storage device! Are you absolutely sure?"><label for="action_expand_root">Expand Root Partition</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_restore_opt_backup" value="restore_opt_backup"><label for="action_restore_opt_backup">Restore Config Backup</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_reboot_system" value="reboot_system" data-confirm="Reboot the system now?"><label for="action_reboot_system">Reboot System</button></div>
        </div>
    </div>

    <div class="execute-bar">
        <button id="execute-button" class="peditx-main-button">Start</button>
        <button id="stop-button" class="peditx-main-button" style="display:none;">Stop</button>
    </div>

    <div id="peditx-status" class="peditx-status">Ready. Select an action and press Start.</div>
    <div class="log-controls">
		<label for="auto-refresh-toggle"><input type="checkbox" id="auto-refresh-toggle" checked> Auto Refresh</label>
        <button class="cbi-button" onclick="pollStatus(true)">Refresh Log</button>
        <button class="cbi-button" onclick="clearLog()">Clear Log</button>
        <button id="logout-button" class="cbi-button">Logout</button>
    </div>
    <pre id="log-output" class="peditx-log-container">Welcome to PeDitXOS Tools!</pre>
</div>
<script type="text/javascript">
    var modalCallback;
    var isPolling = false;
    var modal = document.getElementById('peditx-confirm-modal');
    var modalText = document.getElementById('peditx-modal-text');
    var modalYes = document.getElementById('peditx-modal-yes');
    var modalNo = document.getElementById('peditx-modal-no');
    var startButton = document.getElementById('execute-button');
    var stopButton = document.getElementById('stop-button');
    var statusDiv = document.getElementById('peditx-status');
    var logOutput = document.getElementById('log-output');
    var autoRefreshToggle = document.getElementById('auto-refresh-toggle');
    var statusURL = '<%=luci.dispatcher.build_url("admin", "peditxos", "status")%>';
    var runURL = '<%=luci.dispatcher.build_url("admin", "peditxos", "run")%>';

    function showTab(evt, tabName) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("peditx-tab-content");
        for (i = 0; i < tabcontent.length; i++) { tabcontent[i].style.display = "none"; }
        tablinks = document.getElementsByClassName("peditx-tab-link");
        for (i = 0; i < tablinks.length; i++) { tablinks[i].className = tablinks[i].className.replace(" active", ""); }
        document.getElementById(tabName).style.display = "block";
        evt.currentTarget.className += " active";
    }

    function showConfirmModal(message, callback) {
        modalText.innerText = message;
        modal.style.display = 'block';
        modalCallback = callback;
    }

    modalYes.onclick = function() {
        modal.style.display = 'none';
        if (modalCallback) modalCallback(true);
    };

    modalNo.onclick = function() {
        modal.style.display = 'none';
        if (modalCallback) modalCallback(false);
    };

    function pollStatus(force) {
        if (isPolling && !force) return;

        XHR.poll(2, statusURL, null, function(x, data) {
            if (!x || x.status !== 200 || !data) {
                XHR.poll.stop();
                isPolling = false;
                return;
            }

            if (logOutput.textContent !== data.log) {
                logOutput.textContent = data.log;
                logOutput.scrollTop = logOutput.scrollHeight;
            }
            
            if (data.running) {
                isPolling = true;
                startButton.disabled = true;
                startButton.style.display = 'none';
                stopButton.style.display = 'inline-flex';
            } else {
                if (!autoRefreshToggle.checked) {
                    XHR.poll.stop();
                }
                isPolling = false;
                startButton.disabled = false;
                startButton.style.display = 'inline-flex';
                stopButton.style.display = 'none';
            }
        });
    }
    
    function clearLog() {
        XHR.get(runURL, { action: 'clear_log' }, function(x, data) {
            if (x && x.status === 200) {
                pollStatus(true);
            }
        });
    }

    function startActionByName(actionName, params) {
        params = params || {};
        params.action = actionName;

        XHR.get(runURL, params, function(x, data) {
            if (x && x.status === 200 && data.success) {
                statusDiv.innerText = 'Starting ' + actionName + '...';
                pollStatus(true);
            } else {
                statusDiv.innerText = 'Error starting action: ' + (data ? data.error : 'Unknown');
            }
        });
    }

    startButton.addEventListener('click', function() {
        var selectedActionInput = document.querySelector('input[name="peditx_action"]:checked');
        if (!selectedActionInput) {
            showConfirmModal('Please select an action first.', function(result) {});
            return;
        }

        var action = selectedActionInput.value;
        var confirmationMessage = selectedActionInput.getAttribute('data-confirm');
        
        var doStart = function() {
            var params = {};
            if (action === 'set_dns_custom') {
                var dns1 = document.getElementById('custom_dns1').value.trim();
                if (!dns1) {
                    showConfirmModal('Please enter at least the first DNS IP.', function(result) {});
                    return;
                }
                params.dns1 = dns1;
                params.dns2 = document.getElementById('custom_dns2').value.trim();
            } else if (action === 'install_extra_packages' || action === 'install_opt_packages') {
                var selectedPkgs = Array.from(document.querySelectorAll('input[name="extra_pkg"]:checked')).map(cb => cb.value);
                if (selectedPkgs.length === 0 && action === 'install_extra_packages') {
                    showConfirmModal('Please select at least one extra package to install.', function(result) {});
                    return;
                }
                params.packages = selectedPkgs.join(' ');
            } else if (action === 'set_wifi_config') {
                params.ssid = document.getElementById('wifi_ssid').value.trim();
                params.key = document.getElementById('wifi_key').value;
                var band2g = document.getElementById('wifi_band_2g').checked;
                var band5g = document.getElementById('wifi_band_5g').checked;
                if (!params.ssid || !params.key) {
                    showConfirmModal('Please enter WiFi SSID and Password.', function(result) {});
                    return;
                }
                if (!band2g && !band5g) {
                    showConfirmModal('Please select at least one WiFi band to enable.', function(result) {});
                    return;
                }
                params.band = (band2g && band5g) ? 'Both' : (band2g ? '2G' : '5G');
            } else if (action === 'set_lan_ip') {
				var presetIp = document.getElementById('lan_ip_preset').value;
				var customIp = document.getElementById('custom_lan_ip').value.trim();
				var finalIp = (presetIp !== "") ? presetIp : customIp;

				if (!finalIp) {
					showConfirmModal('Please select a preset or enter a custom LAN IP address.', function(result) {});
					return;
				}
				params.ipaddr = finalIp.replace(/\s/g, '');
            }
            startActionByName(action, params);
        };

        if (confirmationMessage) {
            showConfirmModal(confirmationMessage, function(result) {
                if (result) {
                    doStart();
                }
            });
        } else {
            doStart();
        }
    });

    stopButton.addEventListener('click', function() {
        statusDiv.innerText = 'Stopping process...';
        XHR.get(runURL, { action: 'stop_process' }, function(x, data) {
            if (x && x.status === 200 && data.success) {
                pollStatus(true);
            } else {
                statusDiv.innerText = 'Error stopping process.';
            }
        });
    });

    autoRefreshToggle.addEventListener('change', function() {
		if (this.checked) {
            statusDiv.innerText = 'Auto-refresh enabled.';
			pollStatus(true);
		} else {
            statusDiv.innerText = 'Auto-refresh disabled.';
			XHR.poll.stop();
		}
	});

    document.getElementById('logout-button').addEventListener('click', function() {
        window.location.href = '<%=luci.dispatcher.build_url("admin", "logout")%>';
    });

	document.getElementById('custom_lan_ip').value = document.getElementById('lan_ip_preset').value;
    pollStatus(true);
</script>
<%+footer%>
EOF
chmod 644 /usr/lib/lua/luci/view/peditxos/main.htm
echo "View file created."

echo ">>> Step 3: Finalizing..."
rm -f /tmp/luci-indexcache
/etc/init.d/uhttpd restart
echo ""
echo "********************************************"
echo "           Update Successful!           "
echo "********************************************"
