local cache = nil
local function nvim_empty_argc()
    if cache ~= nil then return cache end
    cache = vim.fn.argc(-1) == 0
    return cache
end

return nvim_empty_argc
