return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      diagnostics = {
        float = {
          border = vim.g.cfg_border_style,
        },
      },
    },
  },
  { import = 'lazyvim.plugins.extras.formatting.prettier' },
}
