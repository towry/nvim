local au = require('libs.runtime.au')

return {
  'lukas-reineke/indent-blankline.nvim',
  event = au.user_autocmds.FileOpened_User,
  config = function()
    require('indent_blankline').setup({
      use_treesitter = true,
      show_current_context = false,
      buftype_exclude = {
        'nofile',
        'terminal',
      },
      filetype_exclude = {
        'help',
        'startify',
        'Outline',
        'alpha',
        'dashboard',
        'lazy',
        'neogitstatus',
        'NvimTree',
        'neo-tree',
        'Trouble',
      },
    })

    au.register_event(au.events.AfterColorschemeChanged, {
      name = "update_indentline_hl",
      immediate = true,
      callback = function()
        -- local utils = require('libs.runtime.utils')
        -- vim.api.nvim_set_hl(0, 'IndentBlanklineChar', utils.fg("FloatBorder"))
      end,
    })
  end,
}
