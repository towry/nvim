local user_cfg = {
  ui__theme_name = "everforest",
}

return {
  setup = function()
    require('libs.cfg').setup(user_cfg)
  end
}
