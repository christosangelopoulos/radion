-- mpv script that logs metadata from Icecast streams.
-- script adapted from here: https://gist.github.com/alecwbr/c84381559ded9ed8553dc53dc251b416

local CONFIG_DIR = (os.getenv("APPDATA") or os.getenv("HOME").."/.config");
local HISTFILE = CONFIG_DIR.."/mpv/icyhistory.log";


local function append_to_file(file, val)
    local logfile;

    if val == nil then
    title = "No title available"
    name = "No name"
    artist = "Uknown artist"
    end
    if val ~= nil  then
     if val["icy-title"] then
      name = val["icy-name"]
      title = val["icy-title"]
      artist = ""
     end
     if val["title"] then
      name = val["icy-name"]
      title = val["title"]
      artist = val["artist"]
     end
     if val["Title"] then
      name = val["icy-name"]
      title = val["Title"]
      artist = val["Artist"]
     end
     if val["TITLE"] then
      name = val["icy-name"]
      title = val["TITLE"]
      artist = val["ARTIST"]
     end
    end

        logfile = io.open(file, "a+");

        logfile:write(("%s | %s - %s | %s\n"):format(os.date("%Y-%m-%d | %H:%M:%S"), title, artist, name));
        logfile:close();
end

mp.observe_property("metadata", "native", function(name, val)
    append_to_file(HISTFILE, val);
end)
