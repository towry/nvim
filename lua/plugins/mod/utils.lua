local M = {}

function M.get_plugin(name)
    return require("lazy.core.config").spec.plugins[name]
end

function M.has(name)
    return M.get_plugin(name) ~= nil
end

return M
