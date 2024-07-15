local M = {}

local did_setup = false
M.setup = function(opts)
  require('internal.config').update(opts)
  if did_setup then return end
end

return setmetatable({}, {
  __index = function(_, key)
    if key == 'config' then
      return require('internal.config').config
    end
    return M[key]
  end
})
