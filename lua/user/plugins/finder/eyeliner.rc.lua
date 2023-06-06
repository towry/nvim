return {
  config = function()
    require('eyeliner').setup({
      highlight_on_key = true,
      dim = true,
    })

    -- local au = require('libs.runtime.au')
    -- au.register_event(au.events.AfterColorschemeChanged, {
    --   name = "eyeliner_ui",
    --   callback = function()
    --     vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
    --     vim.api.nvim_set_hl(0, 'EyelinerSecondary', { underline = true })
    --   end
    -- })
  end,
}
