# Usage

### Building a LPKG file from a library folder.
------
```
$ cd ./Import
$ lua build.lua PROJECT_ROOT
```

### Installing an LPKG file
-------
To install a Lua Package you'll have to put the LPKG file inside of `./Import/packages/`

### Importing an LPKG file
-----
```lua
local import = require "import"

local library = import:Load("TestAPI")

print(library.math.add(5, 5))
```
