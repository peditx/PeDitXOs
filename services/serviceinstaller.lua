module("luci.controller.serviceinstaller", package.seeall)

function index()
    -- Main entry for the page, named "Store"
    entry({"admin", "peditxos", "serviceinstaller"}, template("serviceinstaller/main"), "Store", 2).dependent = false
    
    -- JSON endpoint to get the list of services from the JSON file
    entry({"admin", "peditxos", "serviceinstaller", "get_services"}, call("get_services_list")).json = true
    
    -- JSON endpoints for status polling and running scripts, pointing to the main controller's functions
    -- This ensures the Store page uses the same logging and execution engine as the Dashboard
    entry({"admin", "peditxos", "serviceinstaller", "status"}, call("get_status")).json = true
    entry({"admin", "peditxos", "serviceinstaller", "run"}, call("run_script")).json = true
end

-- Function to read and parse the services.json file
function get_services_list()
    local jsonc = require "luci.jsonc"
    local nixio = require "nixio"
    
    local services_file = "/etc/config/peditx_services.json"
    local content = nixio.fs.readfile(services_file)
    
    if content then
        local stat, data = pcall(jsonc.parse, content)
        if stat and type(data) == "table" then
            luci.http.prepare_content("application/json")
            luci.http.write_json(data)
            return
        end
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({ error = "Service list is not valid or not found." })
end

-- This function gets the log and running status. It's identical to the one in peditxos.lua
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

-- This function runs the selected script via peditx_runner.sh. It's identical to the one in peditxos.lua
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
    
    luci.sys.exec("nohup " .. cmd .. " &")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end
