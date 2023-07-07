local user_cfg = {
  ui__theme_name = "neobones",
  workbench__lualine_theme = 'auto',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
}

return {
  setup = function()
    require('userlib.cfg').setup(user_cfg)
  end
}
