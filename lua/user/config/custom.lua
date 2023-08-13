local user_cfg = {
  ui__theme_name = "nightfox",
  workbench__lualine_theme = 'nightfox',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
}

return {
  setup = function()
    require('userlib.cfg').setup(user_cfg)
  end
}
