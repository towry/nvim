return {
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

    local au = require('user.runtime.au')
    au.register_event(au.events.AfterColorschemeChanged, {
      name = "marks_ui",
      callback = function()
        -- FIXME
        local colors = nil
        vim.api.nvim_set_hl(0, 'MarkSignHL', {
          bg = colors.marks_sign,
          fg = '#ffffff',
          bold = true,
          italic = true,
        })
      end,
    })
  end,
}
