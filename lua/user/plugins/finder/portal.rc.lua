return {
  config = function()
    -- FIXME
    local colors = nil
    local nvim_set_hl = vim.api.nvim_set_hl
    local au = require('libs.runtime.au')

    require('portal').setup({
      log_level = 'error',
      window_options = {
        relative = "cursor",
        width = 50,
        height = 3,
        col = 2,
        focusable = false,
        border = "rounded",
        noautocmd = true,
      }
    })

    au.register_event(au.events.AfterColorschemeChanged, {
      name = "portal_ui",
      callback = function()
        nvim_set_hl(0, 'PortalBorderForward', { fg = colors.portal_border_forward })
        nvim_set_hl(0, 'PortalBorderNone', { fg = colors.portal_border_none })
      end
    })
  end,
}
