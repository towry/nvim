local user_cfg = {
  ui__theme_name = "Neobones",
  -- ui__theme_name = "ayu",
  workbench__lualine_theme = 'auto',
  --- treesitter
  lang__treesitter_plugin_rainbow = true,
}

return {
  setup = function()
    require('libs.cfg').setup(user_cfg)
  end
}
