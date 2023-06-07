return {
  'chentoast/marks.nvim',
  event = 'BufReadPost',
  config = function()
    require('marks').setup({
      default_mappings = false,
      builtin_marks = {},
      refresh_interval = 600,
      excluded_filetypes = { 'oil', 'expJABS', 'NvimTree' },
      -- keymaps for marks.
      mappings = {
        preview = 'm:',
        toggle = 'm<space>',
        next = 'm,',
        prev = 'm.',
        delete_buf = 'm<bs>',
      },
    })

    -- sync hl.
    local au = require('libs.runtime.au')
    au.register_event(au.events.AfterColorschemeChanged, {
      name = "update_marks_hl",
      callback = function()
        vim.api.nvim_set_hl(0, 'MarkSignHL', {
          bg = 'red',
          fg = '#ffffff',
          bold = true,
          italic = true,
        })
      end,
    })
  end,
}
