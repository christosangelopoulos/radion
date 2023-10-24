-- mpv script that logs metadata from Icecast streams.
-- script adapted from here: https://gist.github.com/alecwbr/c84381559ded9ed8553dc53dc251b416

local CONFIG_DIR = (os.getenv("APPDATA") or os.getenv("HOME").."/.config");
local HISTFILE = CONFIG_DIR.."/mpv/icyhistory.log";


local function append_to_file(file, val)
    local logfile;

    if val ~= nil and val["icy-title"] then
    title = val["icy-title"]
    name = val["icy-name"]
    end
        if val == nil then
    title = "No title available"
    name = "No name available"
    end
        logfile = io.open(file, "a+");
        logfile:write(("%s | %s | %s\n"):format(os.date("%Y-%m-%d | %H:%M:%S"), title, name));
        logfile:close();
end

mp.observe_property("metadata", "native", function(name, val)
    append_to_file(HISTFILE, val);
end)
