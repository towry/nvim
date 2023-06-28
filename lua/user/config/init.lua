local M = {}

function M.setup()
  require('libs.runtime.globals')
  require('user.config.custom').setup()
  require('user.config.options').setup()

  require('user.config.autocmd').setup({
    resize_kitty = false,
    on_very_lazy = function()
      require('user.config.keymaps').setup()
    end,
  })

  local bundle_ok, spec = pcall(require, 'user.plugins_bundle')
  if not bundle_ok then
    spec = require('user.config.plugs')
  end
  require('user.config.lazy').setup({
    spec = spec
  })
end

return M
