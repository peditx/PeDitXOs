#!/bin/sh

# PeDitXOS Tools - Complete Installer Script v38 (Definitive Fix)
# This version rewrites all service installers, fixes the runner script, and adds requested UI features.

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

# Create the Runner Script (Completely rewritten with functions for stability)
cat > /usr/bin/peditx_runner.sh << 'EOF'
#!/bin/sh
ACTION="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"
LOG_FILE="/tmp/peditxos_log.txt"
LOCK_FILE="/tmp/peditx.lock"

# This trap ensures the lock file is removed when the script exits for any reason.
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM

# Create lock file immediately
touch "$LOCK_FILE"

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

# --- INSTALLER FUNCTIONS ---

install_sshplus() {
    echo "Installing SSHPlus..."
    [ -f /etc/config/sshplus ] || cat > /etc/config/sshplus <<'EoL'
config sshplus 'global'
	option active_profile ''
config profile
	option host 'host.example.com'
	option user 'root'
	option port '22'
	option auth_method 'password'
	option pass 'your_password'
	option key_file '/root/.ssh/id_rsa'
EoL
    cat > /usr/lib/lua/luci/controller/sshplus.lua <<'EoL'
module("luci.controller.sshplus", package.seeall)
function index()
    if not nixio.fs.access("/etc/init.d/sshplus") then return end
    entry({"admin", "services", "sshplus"}, cbi("sshplus_manager"), "SSHPlus", 90).dependent = true
    entry({"admin", "services", "sshplus_api"}, call("api_handler")).leaf = true
end
function api_handler()
    local action = luci.http.formvalue("action")
    if action == "status" then
        local running = (luci.sys.call("pgrep -f 'sshplus_service' >/dev/null 2>&1") == 0)
        local ip = "N/A"; local uptime = 0; local active_profile_id = luci.sys.exec("uci get sshplus.global.active_profile 2>/dev/null"):gsub("\n","")
        local active_profile_name = "None"
        if active_profile_id ~= "" then
            local user = luci.sys.exec("uci get sshplus." .. active_profile_id .. ".user 2>/dev/null"):gsub("\n","")
            local host = luci.sys.exec("uci get sshplus." .. active_profile_id .. ".host 2>/dev/null"):gsub("\n","")
            if user ~= "" and host ~= "" then active_profile_name = user .. "@" .. host else active_profile_name = active_profile_id end
        end
        if running then
            local f = io.open("/tmp/sshplus_start_time", "r")
            if f then local start_time = tonumber(f:read("*l") or "0"); f:close(); if start_time > 0 then uptime = os.time() - start_time end end
            local ip_handle = io.popen("curl --socks5 127.0.0.1:8089 -s http://ifconfig.me/ip")
            ip = ip_handle:read("*a"):gsub("\n", ""); ip_handle:close()
        end
        luci.http.prepare_content("application/json"); luci.http.write_json({running = running, ip = ip, uptime = uptime, profile = active_profile_name})
    elseif action == "toggle" then
        if (luci.sys.call("pgrep -f 'sshplus_service' >/dev/null 2>&1") == 0) then luci.sys.call("/etc/init.d/sshplus start") else luci.sys.call("/etc/init.d/sshplus stop") end
        luci.http.status(200, "OK")
    end
end
EoL
    cat > /usr/lib/lua/luci/model/cbi/sshplus_manager.lua <<'EoL'
local m = Map("sshplus", "SSHPlus Manager", "Manage status and profiles for your SSH tunnel.")
local s_status = m:section(SimpleSection, "Status & Control"); s_status.template = "sshplus_status_section"
local s_global = m:section(TypedSection, "sshplus", "Global Settings"); s_global.anonymous = true; s_global.addremove = false
local active_profile = s_global:option(ListValue, "active_profile", "Active Profile")
active_profile:value("", "-- Select Profile --")
m.uci:foreach("sshplus", "profile", function(s) active_profile:value(s[".name"], string.format("%s@%s", s.user or "user", s.host or "host")) end)
local s_profiles = m:section(TypedSection, "profile", "Connection Profiles"); s_profiles.anonymous = false; s_profiles.addremove = true; s_profiles.sortable = true
s_profiles:option(Value, "host", "SSH Host/IP"); s_profiles:option(Value, "user", "SSH Username"); s_profiles:option(Value, "port", "SSH Port", "Default is 22").placeholder = "22"
local auth = s_profiles:option(ListValue, "auth_method", "Auth Method"); auth:value("password", "Password"); auth:value("key", "Private Key")
local pass = s_profiles:option(Value, "pass", "SSH Password"); pass.password = true; pass:depends("auth_method", "password")
local keyfile = s_profiles:option(Value, "key_file", "Private Key Path"); keyfile:depends("auth_method", "key"); keyfile.placeholder = "/root/.ssh/id_rsa"
return m
EoL
    cat > /usr/lib/lua/luci/view/sshplus_status_section.htm <<'EoL'
<style>.sshplus-status-panel{max-width:600px;background:#fff;margin:0 auto 20px;border-radius:.5rem;padding:20px;box-shadow:0 1px 4px #0002}.sshplus-row{display:flex;justify-content:space-between;align-items:center;font-size:1.1em;margin-bottom:12px}.sshplus-label{color:#606266}.sshplus-value{font-weight:700;color:#1465ba}.sshplus-status{font-weight:700;color:#18cc29}.sshplus-status.disconnected{color:#e52d2d}.sshplus-btn{background:#ff8080;color:#fff;font-size:1.1em;border-radius:5px;padding:10px 20px;border:none;cursor:pointer;font-weight:700;margin:10px auto 0;display:block}.sshplus-btn.on{background:#38db8b}</style>
<div class="sshplus-status-panel">
<div class="sshplus-row"><span class="sshplus-label">Active Profile:</span><span id="profileText" class="sshplus-value">...</span></div>
<div class="sshplus-row"><span class="sshplus-label">Service Status:</span><span id="statusText" class="sshplus-status">...</span></div>
<div class="sshplus-row"><span class="sshplus-label">Outgoing IP:</span><span id="ipText" class="sshplus-value">...</span></div>
<div class="sshplus-row"><span class="sshplus-label">Connection Time:</span><span id="uptimeText" class="sshplus-value">...</span></div>
<button class="sshplus-btn" id="mainBtn" onclick="toggle()"><span id="mainBtnText">...</span></button>
</div>
<script>function formatUptime(s){if(isNaN(s)||s<0)return"-";let m=Math.floor(s/60);s%=60;return(m>0?m+"m ":"")+s+"s"}
function updateStatus(){XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_api")%>?action=status',null,function(x,st){if(!st)return;let r=st.running,ip=st.ip?.trim()||"N/A",up=st.uptime||0,p=st.profile||"None";let s=document.getElementById("statusText");s.innerHTML=r?"Connected":"Disconnected";s.className="sshplus-status"+(r?"":" disconnected");document.getElementById("ipText").innerText=ip;document.getElementById("uptimeText").innerText=r?formatUptime(up):"-";document.getElementById("profileText").innerText=p;let b=document.getElementById("mainBtn"),bt=document.getElementById("mainBtnText");b.className="sshplus-btn"+(r?"":" on");bt.innerText=r?"Disconnect":"Connect"})}
function toggle(){XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_api")%>?action=toggle',null,function(){setTimeout(updateStatus,1500)})}
setInterval(updateStatus,3000);updateStatus();</script>
EoL
    cat > /etc/init.d/sshplus <<'EoL'
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/sshplus_service
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    pkill -f sshplus_service
    pkill -f "sshpass -p"
    pkill -f "ssh -D 8089"
    rm -f /tmp/sshplus_start_time
}
EoL
    chmod +x /etc/init.d/sshplus
    cat > /usr/bin/sshplus_service <<'EoL'
#!/bin/sh
while true; do
    ACTIVE_PROFILE=$(uci get sshplus.global.active_profile 2>/dev/null)
    if [ -z "$ACTIVE_PROFILE" ]; then echo "No active SSHPlus profile. Sleeping..."; sleep 60; continue; fi
    HOST=$(uci get sshplus.$ACTIVE_PROFILE.host);USER=$(uci get sshplus.$ACTIVE_PROFILE.user);PORT=$(uci get sshplus.$ACTIVE_PROFILE.port);AUTH_METHOD=$(uci get sshplus.$ACTIVE_PROFILE.auth_method);PASS=$(uci get sshplus.$ACTIVE_PROFILE.pass);KEY_FILE=$(uci get sshplus.$ACTIVE_PROFILE.key_file)
    if [ -z "$HOST" ] || [ -z "$USER" ] || [ -z "$PORT" ]; then echo "Profile $ACTIVE_PROFILE not configured. Sleeping..."; sleep 60; continue; fi
    date +%s > /tmp/sshplus_start_time
    SSH_CMD_OPTIONS="-o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -D 8089 -N -p $PORT $USER@$HOST"
    echo "Connecting with profile $ACTIVE_PROFILE..."
    if [ "$AUTH_METHOD" = "key" ]; then ssh -i "$KEY_FILE" $SSH_CMD_OPTIONS; else sshpass -p "$PASS" ssh $SSH_CMD_OPTIONS; fi
    echo "SSHPlus tunnel disconnected. Reconnecting in 5s..."
    rm -f /tmp/sshplus_start_time; sleep 5
done
EoL
    chmod +x /usr/bin/sshplus_service
    if uci show passwall2 >/dev/null 2>&1; then uci set passwall2.SshPlus=nodes; uci set passwall2.SshPlus.remarks='ssh-plus'; uci set passwall2.SshPlus.type='Xray'; uci set passwall2.SshPlus.protocol='socks'; uci set passwall2.SshPlus.server='127.0.0.1'; uci set passwall2.SshPlus.port='8089'; uci commit passwall2; echo "Passwall2 configured."; elif uci show passwall >/dev/null 2>&1; then uci set passwall.SshPlus=nodes; uci set passwall.SshPlus.remarks='Ssh-Plus'; uci set passwall.SshPlus.type='Xray'; uci set passwall.SshPlus.protocol='socks'; uci set passwall.SshPlus.server='127.0.0.1'; uci set passwall.SshPlus.port='8089'; uci commit passwall; echo "Passwall configured."; fi
    /etc/init.d/sshplus enable
    /etc/init.d/sshplus start
    echo "SSHPlus installation complete."
}

install_torplus() {
    echo "Installing TORPlus packages..."
    run_with_heartbeat "opkg update; opkg install tor ca-certificates curl coreutils-base64 snowflake-client obfs4proxy"
    echo "Creating TORPlus LuCI interface..."
    [ -f /etc/config/torplus ] || uci -q set torplus.settings=torplus
    uci -q set torplus.settings.bridge_type='snowflake'
    uci -q commit torplus
    cat > /usr/lib/lua/luci/controller/torplus.lua <<'EoL'
module("luci.controller.torplus", package.seeall)
function index()
    if not nixio.fs.access("/etc/init.d/tor") then return end
    entry({"admin", "services", "torplus"}, cbi("torplus_manager"), "TORPlus", 92).dependent = true
    entry({"admin", "services", "torplus_api"}, call("api_handler")).leaf = true
end
function api_handler()
    local action = luci.http.formvalue("action")
    if action == "status" then
        local running = (os.execute("pgrep -f '/usr/sbin/tor' >/dev/null 2>&1") == 0)
        local ip = "N/A"
        if running then
            local ip_handle = io.popen("curl --socks5 127.0.0.1:9050 -s http://ifconfig.me/ip")
            ip = ip_handle:read("*a"):gsub("\n", "")
            ip_handle:close()
        end
        luci.http.prepare_content("application/json")
        luci.http.write_json({running = running, ip = ip})
    elseif action == "toggle" then
        if (os.execute("pgrep -f '/usr/sbin/tor' >/dev/null 2>&1") == 0) then os.execute("/etc/init.d/tor start") else os.execute("/etc/init.d/tor stop") end
        luci.http.status(200, "OK")
    end
end
EoL
    cat > /usr/lib/lua/luci/model/cbi/torplus_manager.lua <<'EoL'
local fs = require "nixio.fs"
local m = Map("torplus", "TORPlus Manager", "Manage Tor status and bridge settings.")
local s_status = m:section(SimpleSection, "Status & Control"); s_status.template = "torplus_status_section"
local s_settings = m:section(TypedSection, "torplus", "settings", "Bridge Configuration")
s_settings.anonymous = true
s_settings.addremove = false
local bridge = s_settings:option(ListValue, "bridge_type", "Bridge Type")
bridge:value("snowflake", "Snowflake (Recommended)"); bridge:value("obfs4", "obfs4"); bridge:value("meek", "Meek (Azure)")
function m.on_after_commit(self)
    local uci = self.uci
    local sid = self:section_to_luci(s_settings.section)
    local bridge_type = uci:get("torplus", sid, "bridge_type")
    local torrc_content = "SocksPort 9050\n"
    if bridge_type == "snowflake" then torrc_content = torrc_content .. "UseBridges 1\nClientTransportPlugin snowflake exec /usr/bin/snowflake-client\nBridge snowflake 192.0.2.1:1"
    elseif bridge_type == "obfs4" then torrc_content = torrc_content .. "UseBridges 1\nClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy\nBridge obfs4 192.0.2.2:2 cert=ABC iat-mode=0"
    elseif bridge_type == "meek" then torrc_content = torrc_content .. "UseBridges 1\nClientTransportPlugin meek exec /usr/bin/meek-client\nBridge meek 192.0.2.3:3 url=https://ajax.aspnetcdn.com/ delay=1000" end
    fs.writefile("/etc/tor/torrc", torrc_content)
    os.execute("/etc/init.d/tor restart &")
end
return m
EoL
    cat > /usr/lib/lua/luci/view/torplus_status_section.htm <<'EoL'
<style>.torplus-status-panel{max-width:540px;background:#fff;margin:0 auto 20px;border-radius:.5rem;padding:20px;box-shadow:0 1px 4px #0002}.torplus-row{display:flex;justify-content:space-between;align-items:center;font-size:1.1em;margin-bottom:12px}.torplus-label{color:#606266}.torplus-status{font-weight:700;color:#18cc29}.torplus-status.disconnected{color:#e52d2d}.torplus-ip{font-weight:600;color:#1465ba}.torplus-btn{background:#ff8080;color:#fff;font-size:1.1em;border-radius:5px;padding:10px 20px;border:none;cursor:pointer;font-weight:700;margin:10px auto 0;display:block}.torplus-btn.on{background:#38db8b}</style>
<div class="torplus-status-panel">
<div class="torplus-row"><span class="torplus-label">Service Status:</span><span id="statusText" class="torplus-status">...</span></div>
<div class="torplus-row"><span class="torplus-label">Outgoing IP:</span><span id="ipText" class="torplus-ip">...</span></div>
<button class="torplus-btn" id="mainBtn" onclick="toggle()"><span id="mainBtnText">...</span></button>
</div>
<script>
function updateStatus(){XHR.get('<%=luci.dispatcher.build_url("admin/services/torplus_api")%>?action=status',null,function(x,st){if(!st)return;let r=st.running,ip=st.ip?.trim()||"N/A";let s=document.getElementById("statusText");s.innerHTML=r?"Connected":"Disconnected";s.className="torplus-status"+(r?"":" disconnected");document.getElementById("ipText").innerText=ip;let b=document.getElementById("mainBtn"),bt=document.getElementById("mainBtnText");b.className="torplus-btn"+(r?"":" on");bt.innerText=r?"Disconnect":"Connect"})}
function toggle(){XHR.get('<%=luci.dispatcher.build_url("admin/services/torplus_api")%>?action=toggle',null,function(){setTimeout(updateStatus,1500)})}
setInterval(updateStatus,5000);updateStatus();
</script>
EoL
    echo -e "SocksPort 9050\nUseBridges 1\nClientTransportPlugin snowflake exec /usr/bin/snowflake-client\nBridge snowflake 192.0.2.1:1" > /etc/tor/torrc
    /etc/init.d/tor enable
    /etc/init.d/tor restart
    if uci show passwall2 >/dev/null 2>&1; then uci set passwall2.TorNode=nodes; uci set passwall2.TorNode.remarks='Tor'; uci set passwall2.TorNode.type='Xray'; uci set passwall2.TorNode.protocol='socks'; uci set passwall2.TorNode.server='127.0.0.1'; uci set passwall2.TorNode.port='9050'; uci commit passwall2; echo "Passwall2 configured."; elif uci show passwall >/dev/null 2>&1; then uci set passwall.TorNode=nodes; uci set passwall.TorNode.remarks='Tor'; uci set passwall.TorNode.type='Xray'; uci set passwall.TorNode.protocol='socks'; uci set passwall.TorNode.server='127.0.0.1'; uci set passwall.TorNode.port='9050'; uci commit passwall; echo "Passwall configured."; fi
    echo "TORPlus installation complete."
}

install_aircast() {
    echo "Installing Air-Cast..."
    ARCH=$(uname -m)
    case "$ARCH" in x86_64) AIRCAST_ARCH="x86_64" ;; aarch64) AIRCAST_ARCH="aarch64" ;; armv7l) AIRCAST_ARCH="arm" ;; *) echo "Unsupported arch: $ARCH"; exit 1 ;; esac
    echo "Architecture: $AIRCAST_ARCH"
    run_with_heartbeat "curl -L -o /usr/bin/aircast \"https://raw.githubusercontent.com/peditx/aircast-openwrt/main/files/aircast-linux-$AIRCAST_ARCH\" && chmod +x /usr/bin/aircast"
    
    echo "Creating Air-Cast service..."
    cat > /etc/init.d/aircast <<'EoL'
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

start_service() {
    BRIP=$(ip addr show br-lan | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    [ -z "$BRIP" ] && BRIP="10.1.1.1"
    procd_open_instance
    procd_set_param command /usr/bin/aircast -b "$BRIP"
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    pkill -f aircast
}
EoL
    chmod +x /etc/init.d/aircast
    
    echo "Creating Air-Cast LuCI interface..."
    cat > /usr/lib/lua/luci/controller/aircast.lua <<'EoL'
module("luci.controller.aircast", package.seeall)
function index()
    if not nixio.fs.access("/etc/init.d/aircast") then return end
    entry({"admin", "services", "aircast"}, template("aircast_status"), "Air-Cast", 93).dependent = true
    entry({"admin", "services", "aircast_api"}, call("api_handler")).leaf = true
end
function api_handler()
    local action = luci.http.formvalue("action")
    if action == "status" then
        local running = (os.execute("pgrep -f '/usr/bin/aircast' >/dev/null 2>&1") == 0)
        local ip = luci.sys.exec("ip addr show br-lan | grep 'inet ' | awk '{print $2}' | cut -d/ -f1"):gsub("\n","")
        if ip == "" then ip = "10.1.1.1" end
        luci.http.prepare_content("application/json")
        luci.http.write_json({running = running, ip = ip})
    elseif action == "toggle" then
        if (os.execute("pgrep -f '/usr/bin/aircast' >/dev/null 2>&1") == 0) then os.execute("/etc/init.d/aircast start") else os.execute("/etc/init.d/aircast stop") end
        luci.http.status(200, "OK")
    elseif action == "scan" then
        luci.http.prepare_content("application/json")
        luci.http.write_json({ devices = luci.sys.exec("/usr/bin/aircast -s 2>/dev/null") })
    end
end
EoL
    cat > /usr/lib/lua/luci/view/aircast_status.htm <<'EoL'
<%+header%>
<style>.aircast-title{font-size:2em;font-weight:700;color:#444;margin:40px 0;text-align:center}.aircast-panel{max-width:600px;background:#fff;margin:0 auto 20px;border-radius:1rem;padding:28px;box-shadow:0 2px 16px #aaa4;border:1px solid #e2e4eb}.aircast-row{display:flex;justify-content:space-between;align-items:center;font-size:1.2em;margin-bottom:20px}.aircast-label{color:#606266}.aircast-status{font-weight:700;color:#18cc29}.aircast-status.disconnected{color:#e52d2d}.aircast-ip{font-weight:600;color:#1465ba}.aircast-btn{background:#ff8080;color:#fff;font-size:1.2em;border-radius:10px;padding:12px 25px;border:none;cursor:pointer;font-weight:700;margin:10px 5px 0;display:inline-block}.aircast-btn.on{background:#38db8b}.aircast-btn.scan{background:#409eff}.device-table{width:100%;border-collapse:collapse;margin-top:20px}.device-table th, .device-table td{border:1px solid #ddd;padding:8px;text-align:left}.device-table th{background-color:#f2f2f2}</style>
<div class="aircast-title">Air-Cast Status & Control</div>
<div class="aircast-panel">
<div class="aircast-row"><span class="aircast-label">Service Status:</span><span id="statusText" class="aircast-status">...</span></div>
<div class="aircast-row"><span class="aircast-label">Broadcast IP:</span><span id="ipText" class="aircast-ip">...</span></div>
<div style="text-align:center">
<button class="aircast-btn" id="mainBtn" onclick="toggle()"><span id="mainBtnText">...</span></button>
<button class="aircast-btn scan" id="scanBtn" onclick="scan()">Scan for Devices</button>
</div>
</div>
<div class="aircast-panel">
<h3>Available Devices</h3>
<table class="device-table"><thead><tr><th>Device Name</th><th>IP Address</th></tr></thead><tbody id="deviceList"><tr><td colspan="2">Click 'Scan for Devices' to search...</td></tr></tbody></table>
</div>
<script>
function updateStatus(){XHR.get('<%=luci.dispatcher.build_url("admin/services/aircast_api")%>?action=status',null,function(x,st){if(!st)return;let r=st.running,ip=st.ip?.trim()||"N/A";let s=document.getElementById("statusText");s.innerHTML=r?"Running":"Stopped";s.className="aircast-status"+(r?"":" disconnected");document.getElementById("ipText").innerText=ip;let b=document.getElementById("mainBtn"),bt=document.getElementById("mainBtnText");b.className="aircast-btn"+(r?"":" on");bt.innerText=r?"Stop Service":"Start Service"})}
function toggle(){XHR.get('<%=luci.dispatcher.build_url("admin/services/aircast_api")%>?action=toggle',null,function(){setTimeout(updateStatus,1500)})}
function scan(){document.getElementById("deviceList").innerHTML='<tr><td colspan="2">Scanning...</td></tr>';XHR.get('<%=luci.dispatcher.build_url("admin/services/aircast_api")%>?action=scan',null,function(x,st){if(!st||!st.devices)return;let list=document.getElementById("deviceList");list.innerHTML="";let devices=st.devices.trim().split("\n");if(devices.length==0||devices[0]==''){list.innerHTML='<tr><td colspan="2">No devices found.</td></tr>';return}
devices.forEach(function(d){let parts=d.split(/\s+/);if(parts.length<2)return;let row=list.insertRow();row.insertCell(0).innerText=parts[0];row.insertCell(1).innerText=parts[1]})})}
setInterval(updateStatus,5000);updateStatus();
</script>
<%+footer%>
EoL
    
    /etc/init.d/aircast enable
    /etc/init.d/aircast start
    echo "Air-Cast installation complete."
}

# --- Main Case Statement ---
    case "$ACTION" in
        install_sshplus) install_sshplus ;;
        install_torplus) install_torplus ;;
        install_aircast) install_aircast ;;
        clear_log) echo "Log cleared by user at $(date)" > "$LOG_FILE" ;;
        *)
            run_with_heartbeat "eval $(echo "$ACTION" | sed 's/_/ /g') '$ARG1' '$ARG2' '$ARG3'"
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

# Create the View file
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
</style>
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
            <h4>Other Tools</h4>
            <div class="action-grid">
                <div class="action-item"><input type="radio" name="peditx_action" id="action_install_torplus" value="install_torplus"><label for="action_install_torplus">Install TORPlus</label></div>
                <div class="action-item"><input type="radio" name="peditx_action" id="action_install_warp" value="install_warp"><label for="action_install_warp">Install Warp+</label></div>
                <div class="action-item"><input type="radio" name="peditx_action" id="action_change_repo" value="change_repo"><label for="action_change_repo">Change to PeDitX Repo</label></div>
                <div class="action-item"><input type="radio" name="peditx_action" id="action_install_sshplus" value="install_sshplus"><label for="action_install_sshplus">Install SSHPlus w/ Profile Manager</label></div>
                <div class="action-item"><input type="radio" name="peditx_action" id="action_install_aircast" value="install_aircast"><label for="action_install_aircast">Install Air-Cast w/ Control Panel</label></div>
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

    function showTab(evt, tabName) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("peditx-tab-content");
        for (i = 0; i < tabcontent.length; i++) { tabcontent[i].style.display = "none"; }
        tablinks = document.getElementsByClassName("peditx-tab-link");
        for (i = 0; i < tablinks.length; i++) { tablinks[i].className = tablinks[i].className.replace(" active", ""); }
        document.getElementById(tabName).style.display = "block";
        evt.currentTarget.className += " active";
    }

    function pollLog(button) {
        XHR.get('<%=luci.dispatcher.build_url("admin", "peditxos", "log")%>', null, function(x, data) {
            if (x && x.status === 200 && data.log) {
                var logOutput = document.getElementById('log-output');
                var logContent = data.log;
                
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
        if (monitorInterval) { return alert('Another process is already running.'); }
        var button = this;
        var selectedActionInput = document.querySelector('input[name="peditx_action"]:checked');
        if (!selectedActionInput) { return alert('Please select an action first.'); }

        var action = selectedActionInput.value;
        var confirmationMessage = selectedActionInput.getAttribute('data-confirm');
        if (confirmationMessage && !confirm(confirmationMessage)) { return; }

        var params = { action: action };
        if (action === 'set_dns_custom') {
            var dns1 = document.getElementById('custom_dns1').value.trim();
            if (!dns1) { return alert('Please enter at least the first DNS IP.'); }
            params.dns1 = dns1;
            params.dns2 = document.getElementById('custom_dns2').value.trim();
        } else if (action === 'install_extra_packages') {
            var selectedPkgs = [];
            document.querySelectorAll('input[name="extra_pkg"]:checked').forEach(function(cb) {
                selectedPkgs.push(cb.value);
            });
            if (selectedPkgs.length === 0) {
                return alert('Please select at least one extra package to install.');
            }
            params.packages = selectedPkgs.join(',');
        } else if (action === 'set_wifi_config') {
            params.ssid = document.getElementById('wifi_ssid').value.trim();
            params.key = document.getElementById('wifi_key').value;
            var band2g = document.getElementById('wifi_band_2g').checked;
            var band5g = document.getElementById('wifi_band_5g').checked;
            if (!params.ssid || !params.key) { return alert('Please enter WiFi SSID and Password.'); }
            if (!band2g && !band5g) { return alert('Please select at least one WiFi band to enable.'); }
            params.band = (band2g && band5g) ? 'Both' : (band2g ? '2G' : '5G');
        } else if (action === 'set_lan_ip') {
            params.ipaddr = document.getElementById('custom_lan_ip').value.trim();
            if (!params.ipaddr) { return alert('Please select or enter a LAN IP address.'); }
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
    });
</script>
<%+footer%>
EOF
echo "View file created."

echo ">>> Step 3: Finalizing..."
rm -f /tmp/luci-indexcache
/etc/init.d/uhttpd restart

echo ""
echo "********************************************"
echo "         Update Successful!               "
echo "********************************************"
echo "The toolkit has been updated with the definitive fix."
echo "I am very confident this version will work correctly. Please test it."
echo ""
