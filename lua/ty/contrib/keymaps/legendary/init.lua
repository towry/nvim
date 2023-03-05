local M = {}

M.open_legendary = function()
  require('legendary').find({ filters = require('legendary.filters').current_mode() })
end

return M
