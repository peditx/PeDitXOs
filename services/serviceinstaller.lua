module("luci.controller.serviceinstaller", package.seeall)

function index()
    -- Adds a new top-level menu item at position 41
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
