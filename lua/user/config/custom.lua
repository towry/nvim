local theme = 'modus'
local user_cfg = {
  ui__theme_name = vim.g.vscode and 'default' or theme,
  plug__enable_codeium_vim = false,
  plug__enable_codeium_nvim = false,
  plug__enable_copilot_vim = true,
}

return {
  setup = function()
    require('userlib.cfg').setup(user_cfg)
  end,
}
