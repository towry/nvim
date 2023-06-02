
local M = {}

function M.setup()
  require('user.config.overall').setup()
  require('user.config.builtin').setup()
  require('user.config.autocmd').setup()
end

return M 