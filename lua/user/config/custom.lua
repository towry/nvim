local user_cfg = {
  ui__theme_name = 'kanagawa',
  workbench__lualine_theme = 'kanagawa',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
  plug__enable_codeium_vim = false,
}

return {
  setup = function() require('userlib.cfg').setup(user_cfg) end,
}
