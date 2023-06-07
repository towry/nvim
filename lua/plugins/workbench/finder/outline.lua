return {
  'simrat39/symbols-outline.nvim',
  keys = {
    { '<leader>/o', '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' }
  },
  cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
  opts = {
    -- https://github.com/simrat39/symbols-outline.nvim
    show_guides = true,
    auto_preview = false,
    autofold_depth = 3,
    width = 20,
    auto_close = true, -- auto close after selection
    keymaps = {
      close = { "<Esc>", "q", "Q", "<leader>x" },
    },
    -- on_attach = function(bufnr)
    --   -- Jump forwards/backwards with '{' and '}'
    --   vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    --   vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
    -- end,
  }
}
