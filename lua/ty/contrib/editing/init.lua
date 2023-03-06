local M = {}

local init_autocmds = function()
  local au = require('ty.core.autocmd')
  local node_modules_pattern = '*/node_modules/*'

  au.with_group('no_ls_in_node_modules'):create({ 'BufRead', 'BufNewFile' }, {
    pattern = node_modules_pattern,
    command = 'lua vim.diagnostic.disable(0)',
  })

  local current_timeoutlen = vim.opt.timeoutlen:get() or 400
  au.with_group('no_insert_delay')
      :create('InsertEnter', {
        callback = function()
          vim.opt.timeoutlen = 1
        end,
      })
      :create('InsertLeave', {
        callback = function() vim.opt.timeoutlen = current_timeoutlen end,
      })
end

M.init = function() init_autocmds() end

return M
