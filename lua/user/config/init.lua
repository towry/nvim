local M = {}

function M.setup()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ','

  require('userlib.runtime.globals')
  require('user.config.custom').setup()
  require('user.config.options').init_edit()

  require('user.config.autocmd').setup({
    -- lazy
    resize_kitty = false,
    on_very_lazy = function()
      require('user.config.options').setup()
      require('user.config.keymaps').setup()
      require('user.config.commands')
    end,
  })

  require('user.config.lazy').setup({}, {
    getspec = function()
      local bundle_ok, spec = pcall(require, 'user.plugins_bundle')
      if not bundle_ok then spec = require('user.config.plugs') end
      return spec
    end,
  })

  require('user.config.theme').setup()
end

return M
