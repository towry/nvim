local M = {}

M.init = function()
  require('ty.core.autocmd').on_very_lazy(function() require('alpha').start(true) end)
end

return M
