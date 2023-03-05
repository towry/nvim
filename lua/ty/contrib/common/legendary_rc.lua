local M = {}

local function my_formatter(item)
  local default_columns = require('legendary.ui.format').default_format(item)
  local swap = default_columns[2]
  default_columns[2] = default_columns[3]
  default_columns[3] = swap
  return default_columns
end

function M.setup()
  local lg = require("legendary");
  lg.setup({
    keymaps = require("ty.contrib.keymaps.legendary.keymap").default_keymaps(),
    funcs = require("ty.contrib.keymaps.legendary.functions").default_functions(),
    commands = require("ty.contrib.keymaps.legendary.commands").default_commands(),
    -- autocmds =
    default_item_formatter = my_formatter,
    include_builtin = false,
    include_legendary_cmds = false,
    default_opts = {
      keymaps = { silent = true, noremap = true },
    },
    which_key = {
      auto_register = false,
      do_binding = false,
    }
  })

  lg.commands(require("ty.contrib.keymaps.legendary.commands").mini_commands())
  require("ty.contrib.keymaps.legendary.lg-git").setup(lg)
end


return M