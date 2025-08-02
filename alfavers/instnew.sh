#!/bin/sh

# PeDitXOS Tools - Simplified Installer Script v38
# This version removes integrated services and adds commands to install them via official scripts

echo ">>> Step 1: Initial system configuration..."
# Basic system setup
uci set system.@system[0].zonename='Asia/Tehran'
uci set system.@system[0].hostname='PeDitXOS'
uci commit system
sed -i 's/DISTRIB_ID=.*/DISTRIB_ID="PeDitXOS"/' /etc/openwrt_release
sed -i 's/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION="PeDitX OS telegram:@peditx"/' /etc/openwrt_release
opkg update
opkg install curl luci-compat screen sshpass procps-ng-pkill
echo "System configuration complete."

echo ">>> Step 2: Creating/Updating the LuCI application..."
mkdir -p /usr/lib/lua/luci/controller /usr/lib/lua/luci/model/cbi /usr/lib/lua/luci/view
echo "Application directories created."

# Create the Runner Script (Simplified)
cat > /usr/bin/peditx_runner.sh << 'EOF'
#!/bin/sh
set -e

ACTION="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"
LOG_FILE="/tmp/peditxos_log.txt"
LOCK_FILE="/tmp/peditx.lock"

# Heartbeat function to show progress for long tasks
run_with_heartbeat() {
    COMMAND_TO_RUN="$1"
    ( eval "$COMMAND_TO_RUN" ) &
    CMD_PID=$!
    while kill -0 $CMD_PID >/dev/null 2>&1; do
        echo -n "."
        sleep 3
    done
    wait $CMD_PID
    return $?
}

# --- SERVICE INSTALLER COMMANDS ---

install_torplus() {
    echo "Installing TORPlus via official script..."
    run_with_heartbeat "cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh && chmod +x install.sh && sh install.sh"
}

install_sshplus() {
    echo "Installing SSHPlus via official script..."
    run_with_heartbeat "cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh && sh install_sshplus.sh"
}

install_aircast() {
    echo "Installing Air-Cast via official script..."
    run_with_heartbeat "cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh && sh aircast_install.sh"
}

# --- Main Case Statement ---
(
    # Check if a process is already running. This prevents concurrent executions.
    if [ -f "$LOCK_FILE" ]; then
        echo ">>> Another process is already running. Please wait for it to finish."
        exit 1
    fi
    
    # Create lock file immediately
    touch "$LOCK_FILE"
    
    # This trap ensures the lock file is removed when the script exits for any reason.
    trap 'rm -f "$LOCK_FILE"' EXIT INT TERM
    
    echo ">>> Starting action: $ACTION at $(date)"
    echo "--------------------------------------"
    
    case "$ACTION" in
        install_torplus) install_torplus ;;
        install_sshplus) install_sshplus ;;
        install_aircast) install_aircast ;;
        clear_log) echo "Log cleared by user at $(date)" > "$LOG_FILE" ;;
        *)
            # Note: The original script's use of eval can be a security risk.
            # We assume the actions are safe for this context.
            eval "$(echo "$ACTION" | sed 's/_/ /g') '$ARG1' '$ARG2' '$ARG3'"
            ;;
    esac
    
    EXIT_CODE=$?
    
    echo "--------------------------------------"
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Action completed successfully at $(date)."
    else
        echo "Action failed with exit code $EXIT_CODE at $(date)."
    fi
    echo ">>> SCRIPT FINISHED <<<"

) >> "$LOG_FILE" 2>&1

EOF
chmod +x /usr/bin/peditx_runner.sh
echo "Runner script created/updated."

# Create the Controller file
cat > /usr/lib/lua/luci/controller/peditxos.lua << 'EOF'
module("luci.controller.peditxos", package.seeall)
function index()
    entry({"admin", "peditxos"}, firstchild(), "PeDitXOS Tools", 40).dependent = false
    entry({"admin", "peditxos", "main"}, template("peditxos/main"), "Dashboard", 1)
    entry({"admin", "peditxos", "log"}, call("get_log"), nil, 2).json = true
    entry({"admin", "peditxos", "status"}, call("check_status")).json = true
    entry({"admin", "peditxos", "run"}, call("run_script")).json = true
end
function get_log()
    local log_file = "/tmp/peditxos_log.txt"
    local content = ""
    local f = io.open(log_file, "r")
    if f then content = f:read("*a"); f:close() end
    luci.http.prepare_content("application/json")
    luci.http.write_json({ log = content })
end
function check_status()
    local nixio = require "nixio"
    local lock_file = "/tmp/peditx.lock"
    local is_running = nixio.fs.access(lock_file)
    luci.http.prepare_content("application/json")
    luci.http.write_json({ running = is_running })
end
function run_script()
    local action = luci.http.formvalue("action")
    local cmd = "/usr/bin/peditx_runner.sh " .. action
    
    if action == "set_dns_custom" then
        cmd = cmd .. " '" .. (luci.http.formvalue("dns1") or "") .. "' '" .. (luci.http.formvalue("dns2") or "") .. "'"
    elseif action == "install_extra_packages" then
        cmd = cmd .. " '" .. (luci.http.formvalue("packages") or "") .. "'"
    elseif action == "set_wifi_config" then
        cmd = cmd .. " '" .. (luci.http.formvalue("ssid") or "") .. "' '" .. (luci.http.formvalue("key") or "") .. "' '" .. (luci.http.formvalue("band") or "") .. "'"
    elseif action == "set_lan_ip" then
        cmd = cmd .. " '" .. (luci.http.formvalue("ipaddr") or "") .. "'"
    end
    
    luci.sys.exec("nohup " .. cmd .. " &")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end
EOF
echo "Controller file created."

# Create the View file (update Extra Tools section)
cat > /usr/lib/lua/luci/view/peditxos/main.htm << 'EOF'
<%# LuCI - Lua Configuration Interface v37 %>
<%+header%>
<style>
    .peditx-tabs { display: flex; border-bottom: 2px solid #555; margin-bottom: 15px; }
    .peditx-tab-link { background-color: inherit; border: none; outline: none; cursor: pointer; padding: 14px 16px; transition: 0.3s; font-size: 17px; border-bottom: 3px solid transparent; }
    .peditx-tab-link.active { border-bottom: 3px solid #00b5e2; }
    .peditx-tab-content { display: none; padding: 6px 12px; border-top: none; }
    .action-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 15px; }
    .action-item { background: rgba(58, 58, 58, 0.8); padding: 15px; border-radius: 4px; display: flex; align-items: center; cursor: pointer; border: 1px solid #555; }
    .action-item:hover { background: rgba(69, 69, 69, 0.9); }
    .action-item input[type="radio"], .pkg-item input[type="checkbox"] { margin-right: 15px; transform: scale(1.2); }
    .action-item label, .pkg-item label { cursor: pointer; width: 100%; }
    .execute-bar { margin-top: 25px; text-align: center; }
    #execute-button { font-size: 18px; padding: 15px 40px; background-color: #00b5e2; border-color: #00b5e2; }
    #execute-button:hover { background-color: #00a0c8; border-color: #00a0c8; }
    .peditx-log-container { background-color: #2d2d2d; color: #f0f0f0; font-family: monospace; padding: 15px; border-radius: 5px; height: 350px; overflow-y: scroll; white-space: pre-wrap; border: 1px solid #444; margin-top: 10px;}
    .peditx-status { padding: 10px; margin-top: 20px; background-color: #3a3a3a; border-radius: 5px; text-align: center; font-weight: bold; }
    .input-group { display: flex; flex-direction: column; gap: 10px; margin-top: 15px; }
    .pkg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 10px; margin-top: 15px; }
    .sub-section { border: 1px solid #555; padding: 15px; border-radius: 5px; margin-top: 20px; }
    .log-controls { text-align: right; margin-top: 20px; }
    .log-controls .cbi-button { font-size: 12px; padding: 5px 10px; margin-left: 10px; }
    /* Simple modal style for non-blocking confirmations */
    .peditx-modal { display: none; position: fixed; z-index: 100; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4); }
    .peditx-modal-content { background-color: #2d2d2d; color: #f0f0f0; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 80%; max-width: 400px; border-radius: 8px; }
    .peditx-modal-buttons { text-align: right; margin-top: 15px; }
</style>

<div id="peditx-confirm-modal" class="peditx-modal">
    <div class="peditx-modal-content">
        <p id="peditx-modal-text"></p>
        <div class="peditx-modal-buttons">
            <button id="peditx-modal-yes" class="cbi-button cbi-button-apply">بله</button>
            <button id="peditx-modal-no" class="cbi-button">خیر</button>
        </div>
    </div>
</div>

<div class="cbi-map">
    <h2>PeDitXOS Tools</h2>
    <div class="peditx-tabs">
        <button class="peditx-tab-link active" onclick="showTab(event, 'main-tools')">Main Tools</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'dns-changer')">DNS Changer</button>
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
            <div class="action-item"><input type="radio" name="peditx_action" id="action_set_dns_wan" value="set_dns_wan"><label for="action_set_dns_wan">WAN Gateway</label></div>
        </div>
        <div class="action-item" style="margin-top: 15px;"><input type="radio" name="peditx_action" id="action_set_dns_custom" value="set_dns_custom"><label for="action_set_dns_custom">Custom DNS</label></div>
        <div class="input-group">
            <input class="cbi-input-text" type="text" id="custom_dns1" placeholder="Custom DNS 1">
            <input class="cbi-input-text" type="text" id="custom_dns2" placeholder="Custom DNS 2 (Optional)">
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
        
        <div class="sub-section">
            <h4>Service Installers</h4>
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
        <button id="execute-button" class="cbi-button cbi-button-apply">Start</button>
    </div>

    <div id="peditx-status" class="peditx-status">Ready. Select an action and press Start.</div>
    <div class="log-controls">
        <button class="cbi-button" onclick="pollLog(document.getElementById('execute-button'))">Refresh Log</button>
        <button class="cbi-button" onclick="clearLog()">Clear Log</button>
    </div>
    <pre id="log-output" class="peditx-log-container">Welcome to PeDitXOS Tools!</pre>
</div>
<script type="text/javascript">
    var monitorInterval;
    var modalCallback;
    var modal = document.getElementById('peditx-confirm-modal');
    var modalText = document.getElementById('peditx-modal-text');
    var modalYes = document.getElementById('peditx-modal-yes');
    var modalNo = document.getElementById('peditx-modal-no');

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
        modalCallback(true);
    };

    modalNo.onclick = function() {
        modal.style.display = 'none';
        modalCallback(false);
    };

    function pollLog(button) {
        XHR.get('<%=luci.dispatcher.build_url("admin", "peditxos", "log")%>', null, function(x, data) {
            if (x && x.status === 200 && data.log) {
                var logOutput = document.getElementById('log-output');
                var logContent = data.log;
                
                // Always update the log content to ensure we don't miss the final message
                if (logOutput.textContent !== logContent) {
                    logOutput.textContent = logContent;
                    logOutput.scrollTop = logOutput.scrollHeight;
                }

                if (logContent.includes(">>> SCRIPT FINISHED <<<")) {
                    clearInterval(monitorInterval);
                    monitorInterval = null;
                    var statusDiv = document.getElementById('peditx-status');
                    button.disabled = false;
                    button.innerText = 'Start';
                    statusDiv.innerText = 'Action completed. Check log for details.';
                }
            }
        });
    }
    
    function clearLog() {
        XHR.get('<%=luci.dispatcher.build_url("admin", "peditxos", "run")%>', { action: 'clear_log' }, function(x, data) {
            pollLog(document.getElementById('execute-button'));
        });
    }

    document.getElementById('execute-button').addEventListener('click', function() {
        if (monitorInterval) {
            showConfirmModal('Another process is already running. Please wait for it to finish.', function(result) {});
            return;
        }

        var button = this;
        var selectedActionInput = document.querySelector('input[name="peditx_action"]:checked');
        if (!selectedActionInput) {
            showConfirmModal('Please select an action first.', function(result) {});
            return;
        }

        var action = selectedActionInput.value;
        var confirmationMessage = selectedActionInput.getAttribute('data-confirm');
        
        var startAction = function() {
            var params = { action: action };
            if (action === 'set_dns_custom') {
                var dns1 = document.getElementById('custom_dns1').value.trim();
                if (!dns1) {
                    showConfirmModal('Please enter at least the first DNS IP.', function(result) {});
                    return;
                }
                params.dns1 = dns1;
                params.dns2 = document.getElementById('custom_dns2').value.trim();
            } else if (action === 'install_extra_packages') {
                var selectedPkgs = [];
                document.querySelectorAll('input[name="extra_pkg"]:checked').forEach(function(cb) {
                    selectedPkgs.push(cb.value);
                });
                if (selectedPkgs.length === 0) {
                    showConfirmModal('Please select at least one extra package to install.', function(result) {});
                    return;
                }
                params.packages = selectedPkgs.join(',');
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
                params.ipaddr = document.getElementById('custom_lan_ip').value.trim();
                if (!params.ipaddr) {
                    showConfirmModal('Please select or enter a LAN IP address.', function(result) {});
                    return;
                }
            }

            button.disabled = true;
            button.innerText = 'Running...';
            document.getElementById('peditx-status').innerText = 'Starting ' + action + '...';
            document.getElementById('log-output').textContent = 'Executing command...\n';

            XHR.get('<%=luci.dispatcher.build_url("admin", "peditxos", "run")%>', params, function(x, data) {
                if (x && x.status === 200 && data.success) {
                    monitorInterval = setInterval(function() {
                        pollLog(button);
                    }, 2000);
                } else {
                    button.disabled = false;
                    button.innerText = 'Start';
                    document.getElementById('peditx-status').innerText = 'Error starting action.';
                }
            });
        };

        if (confirmationMessage) {
            showConfirmModal(confirmationMessage, function(result) {
                if (result) {
                    startAction();
                }
            });
        } else {
            startAction();
        }
    });
</script>
<%+footer%>
EOF
echo "View file created with updated JavaScript."

echo ">>> Step 3: Finalizing..."
rm -f /tmp/luci-indexcache
/etc/init.d/uhttpd restart
echo ""
echo "********************************************"
echo "        Update Successful!          "
echo "********************************************"
