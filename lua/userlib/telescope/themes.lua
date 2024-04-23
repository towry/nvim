local M = {}

function M.get_dropdown(opts)
  opts = opts or {}
  opts.borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default
  return require('telescope.themes').get_dropdown(opts)
end

return M
