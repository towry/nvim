local user_cfg = {
  ui__theme_name = "everforest",
  workbench__lualine_theme = 'everforest',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
}

return {
  setup = function()
    require('libs.cfg').setup(user_cfg)
  end
}
