local M = {}

function M.setup()
  require('userlib.runtime.globals')
  require('user.config.custom').setup()
  require('user.config.options').setup()

  require('user.config.autocmd').setup({
    -- lazy
    resize_kitty = false,
    on_very_lazy = function() require('user.config.keymaps').setup() end,
  })

  require('user.config.lazy').setup({}, {
    getspec = function()
      local bundle_ok, spec = pcall(require, 'user.plugins_bundle')
      if not bundle_ok then spec = require('user.config.plugs') end
      return spec
    end,
  })

  require('user.config.theme').setup()
  require('user.config.commands')
end

return M
