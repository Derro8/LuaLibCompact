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

local struct = loadfile("/Import/libs/struct.lua")()

local Import = {
    packageExtension = "lpkg",
    loadedPackages = {},
    loadFrom = function(self, package, sub_package)
        local package_bytes = readfile(string.format("/Import/packages/%s.%s", package, self.packageExtension))
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

        local loaded = self.loadedPackages[name .. sub_package]

        if loaded then
            if loaded.__version__ == result.__version__ then
                return loaded
            end
        end

        local loaded = self.loadedPackages[name]

        if loaded then
            if loaded.__version__ == result.__version__ then
                return loaded[sub_package]
            end
        end

        while true do
            local bytes = string.sub(package_bytes, offset, #package_bytes)

            if(#bytes == 0) then break end

            local key, bytecode_size = struct.unpack("<sl", bytes)
            offset = offset + #key + 9

            if(key == sub_package) then 
                local bytecode = string.sub(package_bytes, offset, offset + bytecode_size)
                offset = offset + bytecode_size

                local loaded = load(bytecode)()

                loaded.__version__ = result.__version__

                self.loadedPackages[name .. sub_package] = loaded;

                return loaded
            end
        end
    end,
    Load = function(self, package)
        local package_bytes = readfile(string.format("/Import/packages/%s.%s", package, self.packageExtension))
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

        local loaded = self.loadedPackages[name]

        if loaded then
            if loaded.__version__ == result.__version__ then
                return loaded
            end
        end

        while true do
            local bytes = string.sub(package_bytes, offset, #package_bytes)

            if(#bytes == 0) then break end

            local key, bytecode_size = struct.unpack("<sl", bytes)
            offset = offset + #key + 9
            local bytecode = string.sub(package_bytes, offset, offset + bytecode_size)
            offset = offset + bytecode_size

            result[key] = self.loadedPackages[name .. key] or load(bytecode)()
        end

        self.loadedPackages[name] = result

        return result
    end
}

return Import
