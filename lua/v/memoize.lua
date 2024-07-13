local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param fn T
---@return T
local function memoize(fn)
    return function(...)
        local key = vim.inspect({ ... })
        cache[fn] = cache[fn] or {}
        if cache[fn][key] == nil then cache[fn][key] = fn(...) end
        return cache[fn][key]
    end
end

return memoize
