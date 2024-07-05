local theme = 'kanagawa'
local user_cfg = {
  ui__theme_name = vim.g.vscode and 'default' or theme,
  plug__enable_codeium_nvim = false,
  plug__enable_codeium_vim = true,
  plug__enable_copilot_vim = false,
  edit__cmp_provider = 'coq',
}

return {
  setup = function()
    require('userlib.cfg').setup(user_cfg)
  end,
}
