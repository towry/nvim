local M = {}

M.config = {
  colorscheme = 'default',
}

M.update = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts)
end

return M
