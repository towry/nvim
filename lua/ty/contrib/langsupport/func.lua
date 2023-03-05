local utils = require('ty.core.utils')
local M = {}

M.attach_colorizer_to_buffer = function(bufnr, opts)
  if utils.has_plugin('nvim-colorizer.lua') then
    require('colorizer').attach_to_buffer(bufnr, opts)
  end
end

return M