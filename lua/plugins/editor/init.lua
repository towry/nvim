return {
  {
    'LazyVim/LazyVim',
    keys = {
      {
        "';",
        function()
          local V = require('v')
          local altbufnr = V.buffer_alt_focusable_bufnr()
          if altbufnr then
            vim.api.nvim_win_set_buf(0, altbufnr)
          end
        end,
      },
    },
  },
  {
    'folke/which-key.nvim',
    opts = {},
  },
  { import = 'lazyvim.plugins.extras.editor.fzf' },
  { import = 'plugins.editor.fzf-lua' },
  ---
  { import = 'plugins.editor.mini-clue' },
  { import = 'plugins.editor.smart-splits' },
  { import = 'plugins.editor.nvim-window-picker' },
}
