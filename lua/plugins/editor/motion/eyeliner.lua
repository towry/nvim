return {
  'jinh0/eyeliner.nvim',
  keys = {
    'f',
    'F',
    't',
    'T',
  },
  opts = {
    highlight_on_key = true, -- show highlights only after keypress
    dim = true
  },
  config = function(_, opts)
    local au = require('libs.runtime.au')

    require('eyeliner').setup(opts)

    au.register_event(au.events.AfterColorschemeChanged, {
      name = 'update_eyeliner_hl',
      immediate = true,
      callback = function()
        vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
        vim.api.nvim_set_hl(0, 'EyelinerSecondary', { underline = true })
      end,
    })
  end,
}
