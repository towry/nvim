return {
  {
    -- free the leader key.
    -- 'anuvyklack/hydra.nvim',
    'pze/hydra.nvim',
  },
  {
    'folke/which-key.nvim',
    lazy = true,
    pin = true,
    config = function()
      require_plugin_spec('keymaps.which-key').config()
    end,
  },
  {
    'mrjones2014/legendary.nvim',
    pin = true,
    dependencies = {
      -- used for frecency sort
      'kkharji/sqlite.lua',
    },
    config = function()
      require_plugin_spec('keymaps.legendary').config()
    end,
  }
}