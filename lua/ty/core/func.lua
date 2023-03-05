-- When user code calls `Ty.func.explorer.project_files`, we do following things:
-- 1. We load `explorer` from `ty/contrib/explorer/func.lua` module
-- call `project_files` on `explorer` module.
-- We use metadata __index meta method to archive this.

local M = {}

local numb_module = {
  __index = function(_, key)
    return function() Ty.NOTIFY('Method: "' .. key .. '" not found', 'error') end
  end,
}

setmetatable(M, {
  __index = function(_, key)
    -- load module from `ty/contrib/<key>/func`
    local ok, module = pcall(require, 'ty.contrib.' .. key .. '.func')
    if ok and type(module) == 'table' then
      return module
    else
      return numb_module
    end
  end,
})

return M
