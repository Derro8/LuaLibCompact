function lua_loadfile(file)
    local handle = io.popen("cd")
    local directory = handle:read("*a")

    file = string.gsub(string.gsub(string.format("%s/%s", directory, file), "\n", ""), "/", "\\")
    
    return loadfile(file)
end

local loadfile = io and lua_loadfile or loadfile

return loadfile("Import/main.lua")()