local user_cfg = {
  ui__theme_name = 'sonokai',
  workbench__lualine_theme = 'sonokai',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
}

return {
  setup = function()
    require('userlib.cfg').setup(user_cfg)
  end
}
