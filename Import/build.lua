local json = require "libs/json";
local struct = require "libs/struct";

function writefile(file, data)
    pcall(function()
       local f = assert(io.open(file, "wb"));

       f:write(data);
       f:close();
    end)
end

function readfile(file)
   local status, txt = pcall(function()
       local f = assert(io.open(file, "rb"))
       local txt = f:read("*all")

       f:close()

       return txt
    end)

    return txt;
end;

local project_directory = arg[1] 
local manifest = json.decode(readfile(string.format("%s/manifest.json", project_directory)))

local metadata = manifest.meta
local scripts = manifest.data
local bytecode_array = {}

for order, script in next, scripts do
    local script_bytecode = string.dump(loadfile(string.format("%s/%s", project_directory, script.script)))
    
    table.insert(bytecode_array, struct.pack("<sl", script.name, #script_bytecode) .. script_bytecode)
end


writefile(string.format("%s/%s.lpkg", project_directory, metadata.title), struct.pack("bb", #metadata.title, #metadata.version) .. metadata.title .. metadata.version .. table.concat(bytecode_array, ""))