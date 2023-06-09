return {
  {
    -- https://github.com/Wansmer/treesj
    'Wansmer/treesj',
    keys = {
      {
        '<leader>mjt',
        '<cmd>lua require("treesj").toggle()<cr>',
        desc = 'Toggle',
      },
      {
        '<leader>mjs',
        '<cmd>lua require("treesj").split()<cr>',
        desc = 'Split',
      },
      {
        '<leader>mjj',
        '<cmd>lua require("treesj").join()<cr>',
        desc = 'Join',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    }
  }
}
