local user_cfg = {
  ui__theme_name = 'slated',
  plug__enable_codeium_vim = false,
}

return {
  setup = function() require('userlib.cfg').setup(user_cfg) end,
}
