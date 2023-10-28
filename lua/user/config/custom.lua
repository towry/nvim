local user_cfg = {
  ui__theme_name = 'gruvbox',
  workbench__lualine_theme = 'gruvbox',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
  plug__enable_codeium_vim = false,
}

return {
  setup = function() require('userlib.cfg').setup(user_cfg) end,
}
