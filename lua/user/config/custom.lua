local user_cfg = {
  -- ui__theme_name = "Forestbones",
  ui__theme_name = "ayu",
  workbench__lualine_theme = 'auto',
}

return {
  setup = function()
    require('libs.cfg').setup(user_cfg)
  end
}
