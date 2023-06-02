
local function my_formatter(item)
  local default_columns = require('legendary.ui.format').default_format(item)
  local swap = default_columns[2]
  default_columns[2] = default_columns[3]
  default_columns[3] = swap
  -- remove the key|command column.
  table.remove(default_columns, 3)
  return default_columns
end

return {
  config = function()
    local lg = require("legendary");
    lg.setup({
      keymaps = require("user.keymaps.legendary.keymap").default_keymaps(),
      funcs = require("user.keymaps.legendary.functions").default_functions(),
      commands = require("user.keymaps.legendary.commands").default_commands(),
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

    lg.commands(require("user.keymaps.legendary.commands").mini_commands())
    require("user.keymaps.legendary.lg-git").setup(lg)
  end,
}