return {
  'mrjones2014/legendary.nvim',
  dependencies = {
    -- used for frecency sort
    'kkharji/sqlite.lua',
  },
  config = function()
    local function my_formatter(item)
      local default_columns = require('legendary.ui.format').default_format(item)
      local swap = default_columns[2]
      default_columns[2] = default_columns[3]
      default_columns[3] = swap
      -- remove the key|command column.
      table.remove(default_columns, 3)
      return default_columns
    end

    local lg = require("legendary");
    local au = require("libs.runtime.au")
    lg.setup({
      funcs = require('libs.legendary.funcs.migrate'),
      commands = require("libs.legendary.commands.migrate"),
      -- autocmds =
      default_item_formatter = my_formatter,
      include_builtin = false,
      include_legendary_cmds = false,
      default_opts = {
        keymaps = { silent = true, noremap = true },
      },
      select_prompt = " ⚒ ",
      icons = {
        fn = " ",
        command = " ",
        key = " ",
      },
    })

    au.do_useraucmd(au.user_autocmds.LegendaryConfigDone_User)
  end,
}
