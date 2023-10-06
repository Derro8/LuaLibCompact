function lua_writefile(file, data)
    local handle = io.popen("cd")
    local directory = handle:read("*a")

    file = string.gsub(string.gsub(string.format("%s/%s", directory, file), "\n", ""), "/", "\\")

    pcall(function()
       local f = assert(io.open(file, "wb"))

       f:write(data)
       f:close()
    end)
end

function lua_readfile(file) 
    local handle = io.popen("cd")
    local directory = handle:read("*a")

    file = string.gsub(string.gsub(string.format("%s/%s", directory, file), "\n", ""), "/", "\\")

    local status, txt = pcall(function()
       local f = assert(io.open(file, "rb"))
       local txt = f:read("*all")

       f:close()

       return txt
    end)

    return txt
end

function lua_loadfile(file)
    local handle = io.popen("cd")
    local directory = handle:read("*a")

    file = string.gsub(string.gsub(string.format("%s/%s", directory, file), "\n", ""), "/", "\\")

    return loadfile(file)
end

function empty_read()
   assert(true == false, "Please use a lua version that has file support.")
end

local loadfile = io and lua_loadfile or loadfile or empty_read
local readfile = readfile or io and lua_readfile or empty_read
local writefile = writefile or io and lua_writefile or empty_read

local struct = loadfile("/Import/libs/struct.lua")

if(type(struct) == "function") then struct = struct() end

local Import = {
    PackageExtension = "lpkg",
    Load = function(self, package)
        local package_bytes = readfile(string.format("/Import/packages/%s.%s", package, self.PackageExtension))
        local offset = 3

        local name_size, version_size = struct.unpack("bb", package_bytes)

        local name = string.sub(package_bytes, offset, offset + name_size - 1)
        offset = offset + name_size
        local version = string.sub(package_bytes, offset, offset + version_size - 1)
        offset = offset + version_size

        local result = {
            __name__ = name,
            __version__ = version
        }

        while true do
            local bytes = string.sub(package_bytes, offset, #package_bytes)

            if(#bytes == 0) then break end

            local key, bytecode_size = struct.unpack("<sl", bytes)
            offset = offset + #key + 9
            local bytecode = string.sub(package_bytes, offset, offset + bytecode_size)
            offset = offset + bytecode_size

            result[key] = load(bytecode)()
        end

        return result
    end
}

return Import