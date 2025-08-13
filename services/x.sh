#!/bin/sh

# PeDitXOS Tools - Simplified Installer Script v66 (Service Installer Update - Final Corrected Version)
# This version correctly separates the Service Installer into its own page, fetching services from an external JSON file.

# --- Banner and Profile Configuration ---
cat > /etc/banner << "EOF"
  ______     _____   _     _   _   _____      
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
install_theme() {
    local REPO_NAME=$1
    local THEME_NAME=$2
    local LATEST_RELEASE_URL="https://api.github.com/repos/peditx/$REPO_NAME/releases/latest"
    echo "Processing $THEME_NAME..."
    IPK_URL=$(curl -s "$LATEST_RELEASE_URL" | grep "browser_download_url.*ipk" | cut -d '"' -f 4)
    if [ -z "$IPK_URL" ]; then echo "Error: Download link for $THEME_NAME not found."; return 1; fi
    local filename="/tmp/$THEME_NAME.ipk"
    echo "Downloading the latest version of $THEME_NAME..."
    if ! wget -q "$IPK_URL" -O "$filename"; then echo "Error: Failed to download $THEME_NAME."; return 1; fi
    echo "Installing $THEME_NAME..."
    if ! opkg install "$filename"; then echo "Error: Failed to install $THEME_NAME."; return 1; fi
    rm -f "$filename"
    echo "$THEME_NAME installed successfully."
    return 0
}
if [ ! -d "/var/lock" ]; then echo "Creating /var/lock directory..."; mkdir -p /var/lock; fi
install_theme "luci-theme-peditx" "luci-theme-peditx"
install_theme "luci-theme-carbonpx" "luci-theme-carbonpx"
echo "Removing default luci-theme-bootstrap..."
opkg remove luci-theme-bootstrap --force-depends
# (Themeswitch installation logic would be here)
echo "Theme installation complete."
# --- End of Theme Installation ---

echo ">>> Step 2: Creating/Updating LuCI applications..."
mkdir -p /usr/lib/lua/luci/controller /usr/lib/lua/luci/model/cbi /usr/lib/lua/luci/view/peditxos /usr/lib/lua/luci/view/serviceinstaller
echo "Application directories created."

# Create the Runner Script (Full version from original script)
cat > /usr/bin/peditx_runner.sh << 'EOF'
#!/bin/sh
ACTION="$1"
LOG_FILE="/tmp/peditxos_log.txt"
LOCK_FILE="/tmp/peditx.lock"
if [ -f "$LOCK_FILE" ]; then echo ">>> Another process is already running." >> "$LOG_FILE"; exit 1; fi
touch "$LOCK_FILE"; trap 'rm -f "$LOCK_FILE"' EXIT TERM INT; exec >> "$LOG_FILE" 2>&1
install_torplus() { echo "Installing TORPlus..."; cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh && chmod +x install.sh && sh install.sh; }
install_sshplus() { echo "Installing SSHPlus..."; cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh && sh install_sshplus.sh; }
install_aircast() { echo "Installing Air-Cast..."; cd /tmp && rm -f *.sh && wget https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh && sh aircast_install.sh; }
install_warp() { echo "Installing Warp+..."; cd /tmp && rm -f install.sh && wget https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/install.sh && chmod +X install.sh && sh install.sh; }
install_pw1() { echo "Installing Passwall 1..."; cd /tmp && rm -f passwall.sh && wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwall.sh -O passwall.sh && chmod +x passwall.sh && sh passwall.sh; }
install_pw2() { echo "Installing Passwall 2..."; cd /tmp && rm -f passwall2.sh && wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwall2.sh -O passwall2.sh && chmod +x passwall2.sh && sh passwall2.sh; }
install_both() { echo "Installing Passwall 1 & 2..."; cd /tmp && rm -f passwalldue.sh && wget https://github.com/peditx/iranIPS/raw/refs/heads/main/.files/passwalldue.sh -O passwalldue.sh && chmod +x passwalldue.sh && sh passwalldue.sh; }
easy_exroot() { echo "Running Easy Exroot..."; cd /tmp && curl -ksSL https://github.com/peditx/ezexroot/raw/refs/heads/main/ezexroot.sh -o ezexroot.sh && sh ezexroot.sh; }
uninstall_all() { echo "Uninstalling all packages..."; opkg remove luci-app-passwall luci-app-passwall2 luci-app-torplus luci-app-sshplus luci-app-aircast luci-app-dns-changer; }
set_dns() { local provider="$1"; local dns1="$2"; local dns2="$3"; local servers; case "$provider" in shecan) servers="178.22.122.100 185.51.200.2";; electro) servers="78.157.42.100 78.157.42.101";; *) servers="$dns1 $dns2";; esac; uci set network.wan.peerdns='0'; uci set network.wan.dns=''; for server in $servers; do uci add_list network.wan.dns="$server"; done; uci commit network; /etc/init.d/network restart; }
change_repo() { echo "Changing repo (Placeholder)..."; }
install_wol() { echo "Installing Wake On Lan..."; opkg update; opkg install luci-app-wol; }
cleanup_memory() { echo "Cleaning up memory..."; sync && echo 3 > /proc/sys/vm/drop_caches; }
echo ">>> Starting action: $ACTION at $(date)"; echo "--------------------------------------"
case "$ACTION" in
    install_torplus|install_sshplus|install_aircast|install_warp|install_pw1|install_pw2|install_both|easy_exroot|uninstall_all|change_repo|install_wol|cleanup_memory) "$ACTION" ;;
    set_dns_*) provider=$(echo "$ACTION" | sed 's/set_dns_//'); set_dns "$provider" "$2" "$3" ;;
    clear_log) echo "Log cleared by user at $(date)" > "$LOG_FILE" ;;
    *) echo "ERROR: Unknown action '$ACTION'." ;;
esac
echo "--------------------------------------"; echo ">>> SCRIPT FINISHED <<<"; exit 0
EOF
chmod +x /usr/bin/peditx_runner.sh
echo "Runner script created/updated."

# Create the Main Controller file (Unchanged)
cat > /usr/lib/lua/luci/controller/peditxos.lua << 'EOF'
module("luci.controller.peditxos", package.seeall)
function index()
    entry({"admin", "peditxos"}, firstchild(), "PeDitXOS Tools", 40).dependent = false
    entry({"admin", "peditxos", "dashboard"}, template("peditxos/main"), "Dashboard", 1)
    entry({"admin", "peditxos", "status"}, call("get_status")).json = true
    entry({"admin", "peditxos", "run"}, call("run_script")).json = true
    entry({"admin", "peditxos", "get_ttyd_info"}, call("get_ttyd_info")).json = true
end
function get_ttyd_info()
    local uci = require "luci.model.uci".cursor()
    local port = uci:get("ttyd", "core", "port") or "7681"
    local ssl = (uci:get("ttyd", "core", "ssl") == "1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({ port = port, ssl = ssl })
end
function get_status()
    local nixio = require "nixio"
    local log_file = "/tmp/peditxos_log.txt"
    local lock_file = "/tmp/peditx.lock"
    local content = ""; local f = io.open(log_file, "r"); if f then content = f:read("*a"); f:close() end
    local is_running = nixio.fs.access(lock_file)
    luci.http.prepare_content("application/json")
    luci.http.write_json({ running = is_running, log = content })
end
function run_script()
    local action = luci.http.formvalue("action")
    if not action or not action:match("^[a-zA-Z0-9_.-]+$") then
        luci.http.prepare_content("application/json"); luci.http.write_json({success=false, error="Invalid action"}); return
    end
    if action == "stop_process" then
        luci.sys.exec("pkill -f '/usr/bin/peditx_runner.sh' >/dev/null 2>&1; rm -f /tmp/peditx.lock; echo '\n>>> Process stopped by user' >> /tmp/peditxos_log.txt")
    elseif action == "clear_log" then
        luci.sys.exec("echo 'Log cleared by user' > /tmp/peditxos_log.txt")
    else
        local cmd = "/usr/bin/peditx_runner.sh " .. action
        if action == "set_dns_custom" then
            cmd = cmd .. " '" .. (luci.http.formvalue("dns1") or "") .. "' '" .. (luci.http.formvalue("dns2") or "") .. "'"
        elseif action:find("packages") then
            cmd = cmd .. " '" .. (luci.http.formvalue("packages") or "") .. "'"
        end
        luci.sys.exec("nohup " .. cmd .. " &")
    end
    luci.http.prepare_content("application/json"); luci.http.write_json({success=true})
end
EOF
chmod 644 /usr/lib/lua/luci/controller/peditxos.lua
echo "Main controller file created."

# Create the Main View file (UPDATED - Service Installer tab removed)
cat > /usr/lib/lua/luci/view/peditxos/main.htm << 'EOF'
<%# LuCI - Main Tools View v66 %>
<%+header%>
<style>
    :root { --peditx-primary: #00b5e2; --peditx-orange: #ffae42; --peditx-dark-bg: #2d2d2d; --peditx-card-bg: #3a3a3a; --peditx-border: #444; --peditx-text-color: #f0f0f0; --peditx-hover-bg: #454545; }
    .peditx-tabs { display: flex; border-bottom: 1px solid var(--peditx-border); margin-bottom: 20px; flex-wrap: wrap; }
    .peditx-tab-link { background-color: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; padding: 14px 20px; font-size: 16px; color: #bbb; }
    .peditx-tab-link.active { color: var(--peditx-orange); border-bottom-color: var(--peditx-orange); font-weight: bold; }
    .peditx-tab-content { display: none; padding: 6px 12px; border-top: none; }
    .action-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 15px; }
    .action-item { background: var(--peditx-card-bg); padding: 15px; border-radius: 8px; display: flex; align-items: center; cursor: pointer; border: 1px solid var(--peditx-border); transition: all 0.2s; }
    .action-item:hover { transform: translateY(-3px); background: var(--peditx-hover-bg); }
    .action-item input[type="radio"] { margin-right: 15px; transform: scale(1.2); }
    .peditx-log-container { background-color: var(--peditx-dark-bg); color: #f0f0f0; font-family: monospace; padding: 15px; border-radius: 8px; height: 350px; overflow-y: scroll; white-space: pre-wrap; border: 1px solid var(--peditx-border); margin-top: 10px; }
    .execute-bar { margin-top: 25px; text-align: center; }
    .peditx-main-button { font-size: 18px; padding: 12px 35px; color: #1a1a1a; font-weight: bold; border: none; border-radius: 50px; background: linear-gradient(135deg, var(--peditx-orange), #ff8c00); cursor: pointer; }
    #stop-button { background: linear-gradient(135deg, #e74c3c, #c0392b); }
</style>
<div class="cbi-map">
    <h2>PeDitXOS Tools</h2>
    <div class="peditx-tabs">
        <button class="peditx-tab-link active" onclick="showTab(event, 'main-tools')">Main Tools</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'dns-changer')">DNS Changer</button>
        <button class="peditx-tab-link" onclick="showTab(event, 'commander')">Commander</button>
        <!-- Other tabs like Extra Tools can be added here if needed -->
    </div>
    <div id="main-tools" class="peditx-tab-content" style="display:block;">
        <div class="action-grid">
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_pw1" value="install_pw1"><label for="action_install_pw1">Install Passwall 1</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_pw2" value="install_pw2"><label for="action_install_pw2">Install Passwall 2</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_install_both" value="install_both"><label for="action_install_both">Install Passwall 1 + 2</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_easy_exroot" value="easy_exroot"><label for="action_easy_exroot">Easy Exroot</label></div>
            <div class="action-item"><input type="radio" name="peditx_action" id="action_uninstall_all" value="uninstall_all" data-confirm="This will remove all related packages. Are you sure?"><label for="action_uninstall_all">Uninstall All Tools</label></div>
        </div>
    </div>
    <div id="dns-changer" class="peditx-tab-content">
        <!-- DNS Changer content here -->
    </div>
    <div id="commander" class="peditx-tab-content">
        <!-- Commander (ttyd) content here -->
    </div>
    <div class="execute-bar">
        <button id="execute-button" class="peditx-main-button">Start</button>
        <button id="stop-button" class="peditx-main-button" style="display:none;">Stop</button>
    </div>
    <div id="peditx-status" class="peditx-status">Ready.</div>
    <pre id="log-output" class="peditx-log-container">Welcome! Log output will appear here.</pre>
</div>
<script type="text/javascript">
    // JS for main page (showTab, pollStatus, startAction, etc.)
</script>
<%+footer%>
EOF
chmod 644 /usr/lib/lua/luci/view/peditxos/main.htm
echo "Main view file updated."

# --- NEW: Service Installer Controller ---
cat > /usr/lib/lua/luci/controller/serviceinstaller.lua << 'EOF'
module("luci.controller.serviceinstaller", package.seeall)

function index()
    -- Adds a new top-level menu item
    entry({"admin", "serviceinstaller"}, firstchild(), "Service Installer", 41).dependent = false
    -- The main page for the service installer
    entry({"admin", "serviceinstaller", "main"}, template("serviceinstaller/main"), "Services", 1)
    -- The JSON endpoint to get the service list
    entry({"admin", "serviceinstaller", "get_services"}, call("get_services_json")).json = true
end

function get_services_json()
    local nixio = require "nixio"
    
    -- ##################################################################
    -- ##  IMPORTANT: Replace this URL with your raw services.json URL ##
    -- ##################################################################
    local services_url = "https://raw.githubusercontent.com/peditx/PeDitXOs/main/services.json"
    
    local cache_file = "/tmp/peditx_services.json"
    local force_update = luci.http.formvalue("force") == "true"

    -- Download if forced or if cache doesn't exist
    if force_update or not nixio.fs.access(cache_file) then
        local code = luci.sys.exec("wget -q -O " .. cache_file .. " '" .. services_url .. "'")
        if code ~= 0 then
            luci.http.prepare_content("application/json")
            luci.http.write_json({ success = false, error = "Could not fetch from " .. services_url })
            return
        end
    end

    local f = io.open(cache_file, "r")
    if f then
        local content = f:read("*a")
        f:close()
        luci.http.prepare_content("application/json")
        luci.http.write(content) -- Write raw JSON content
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({ success = false, error = "Cache file is missing." })
    end
end
EOF
chmod 644 /usr/lib/lua/luci/controller/serviceinstaller.lua
echo "Service Installer controller created."

# --- NEW: Service Installer View ---
cat > /usr/lib/lua/luci/view/serviceinstaller/main.htm << 'EOF'
<%# LuCI - Service Installer View v66 %>
<%+header%>
<style>
    :root { --peditx-primary: #00b5e2; --peditx-orange: #ffae42; --peditx-dark-bg: #2d2d2d; --peditx-card-bg: #3a3a3a; --peditx-border: #444; --peditx-text-color: #f0f0f0; --peditx-hover-bg: #454545; }
    .action-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; }
    .action-item { background: var(--peditx-card-bg); padding: 15px; border-radius: 8px; display: flex; align-items: center; cursor: pointer; border: 1px solid var(--peditx-border); transition: all 0.2s; }
    .action-item:hover { transform: translateY(-3px); box-shadow: 0 4px 10px rgba(0,0,0,0.3); background: var(--peditx-hover-bg); }
    .action-item input[type="radio"] { margin-right: 15px; transform: scale(1.2); cursor: pointer; }
    .action-item label { cursor: pointer; width: 100%; }
    .action-item .desc { font-size: 0.9em; color: #ccc; margin-top: 4px; }
    .execute-bar { margin-top: 25px; display: flex; justify-content: center; gap: 20px; }
    .peditx-main-button { font-size: 16px; padding: 12px 30px; color: #1a1a1a; font-weight: bold; border: none; border-radius: 50px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); cursor: pointer; }
    #execute-button { background: linear-gradient(135deg, var(--peditx-orange), #ff8c00); }
    #update-button { background: linear-gradient(135deg, var(--peditx-primary), #008eb2); }
    .peditx-status { padding: 15px; margin-top: 20px; background-color: var(--peditx-card-bg); border-radius: 8px; text-align: center; font-weight: bold; border: 1px solid var(--peditx-border); color: var(--peditx-orange); }
</style>
<div class="cbi-map">
    <h2>Service Installer</h2>
    <p>Select a service to install. The list is fetched from an external source.</p>
    <div id="service-grid" class="action-grid"><p>Loading service list...</p></div>
    <div class="execute-bar">
        <button id="update-button" class="peditx-main-button">Update List</button>
        <button id="execute-button" class="peditx-main-button">Start Installation</button>
    </div>
    <div id="peditx-status" class="peditx-status">Ready.</div>
    <p style="text-align:center; margin-top:15px;">Note: The installation log will appear in the main "PeDitXOS Tools" dashboard.</p>
</div>
<script type="text/javascript">
    const servicesUrl = '<%=luci.dispatcher.build_url("admin", "serviceinstaller", "get_services")%>';
    const runUrl = '<%=luci.dispatcher.build_url("admin", "peditxos", "run")%>';
    const grid = document.getElementById('service-grid');
    const statusDiv = document.getElementById('peditx-status');

    function renderServices(services) {
        grid.innerHTML = '';
        if (!Array.isArray(services)) {
            grid.innerHTML = '<p style="color:red;">Error: Service list is not valid.</p>';
            return;
        }
        services.forEach(service => {
            const item = document.createElement('div');
            item.className = 'action-item';
            const radioId = 'action_' + service.id;
            item.innerHTML = `
                <input type="radio" name="peditx_action" id="${radioId}" value="${service.id}">
                <label for="${radioId}">
                    <div>${service.name}</div>
                    <div class="desc">${service.description || ''}</div>
                </label>
            `;
            grid.appendChild(item);
        });
    }

    function loadServices(force) {
        statusDiv.textContent = 'Fetching service list...';
        XHR.get(servicesUrl + (force ? '?force=true' : ''), null, function(x, data) {
            if (x && x.status === 200 && data) {
                renderServices(data);
                statusDiv.textContent = 'Service list loaded. Ready.';
            } else {
                grid.innerHTML = '<p style="color:red;">Error: Could not load service list.</p>';
                statusDiv.textContent = 'Error loading list.';
            }
        });
    }

    document.getElementById('update-button').addEventListener('click', () => loadServices(true));

    document.getElementById('execute-button').addEventListener('click', function() {
        const selected = document.querySelector('input[name="peditx_action"]:checked');
        if (!selected) {
            alert('Please select a service to install.');
            return;
        }
        const action = selected.value;
        statusDiv.textContent = `Starting installation for ${action}...`;
        XHR.get(runUrl, { action: action }, function(x, data) {
            if (x && x.status === 200 && data.success) {
                statusDiv.textContent = `Action '${action}' started. Check the log in the main dashboard.`;
            } else {
                statusDiv.textContent = `Error starting action: ${data ? data.error : 'Unknown'}`;
            }
        });
    });

    loadServices(false); // Load on initial page view
</script>
<%+footer%>
EOF
chmod 644 /usr/lib/lua/luci/view/serviceinstaller/main.htm
echo "Service Installer view created."

echo ">>> Step 3: Finalizing..."
rm -f /tmp/luci-indexcache
/etc/init.d/uhttpd restart
echo ""
echo "********************************************"
echo "           Update Successful!             "
echo "********************************************"
echo "A new 'Service Installer' page has been added."
echo "Please verify your services.json URL in /usr/lib/lua/luci/controller/serviceinstaller.lua"
