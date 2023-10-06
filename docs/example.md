# Example

To explain it the best I can I'm going to be illustrating how you'd go about making a library.

## Folder Structure

```
.
└── Library Folder
      ├── source
      |    └── main.lua 
      └── manifest.json

```

## Manifest Example
```json
{
    "meta": {
        "title": "Example",
        "version": "0.0.1"
    },
    "data": [
        {
            "name": "test",
            "script": "source/main.lua"
        }
    ]
}
```

## "main.lua" Example
```
local TestApi = {}

TestApi.Add = function(a, b)
    return a + b
end

return TestApi
```
