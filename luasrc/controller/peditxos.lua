module("luci.controller.peditxos", package.seeall)

function index()
    entry({"admin", "peditxos"}, firstchild(), "PeDitXOS Tools", 40).dependent = false
    entry({"admin", "peditxos", "dashboard"}, template("peditxos/main"), "Dashboard", 1)
    entry({"admin", "peditxos", "status"}, call("get_status")).json = true
    entry({"admin", "peditxos", "run"}, call("run_script")).json = true
    -- New endpoint to get TTYD config
    entry({"admin", "peditxos", "get_ttyd_info"}, call("get_ttyd_info")).json = true
end

function get_ttyd_info()
    local uci = require "luci.model.uci".cursor()
    local port = uci:get("ttyd", "core", "port") or "7681"
    local ssl = (uci:get("ttyd", "core", "ssl") == "1")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        port = port,
        ssl = ssl
    })
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
    
    luci.sys.exec("nohup " .. cmd .. " &")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end
