local user_cfg = {
  ui__theme_name = "everforest",
  -- ui__theme_name = "kanagawa",
  workbench__lualine_theme = 'auto',
}

return {
  setup = function()
    require('libs.cfg').setup(user_cfg)
  end
}
