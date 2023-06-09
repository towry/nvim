return {
  'simrat39/symbols-outline.nvim',
  keys = {
    { '<leader>/o',  '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' },
    -- <CMD-o> open the outline.
    { '<Char-0xAF>', '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' },
  },
  cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
  opts = {
    -- https://github.com/simrat39/symbols-outline.nvim
    show_guides = true,
    auto_preview = false,
    autofold_depth = 2,
    width = 20,
    auto_close = true, -- auto close after selection
    keymaps = {
      close = { "<Esc>", "q", "Q", "<leader>x" },
      focus_location = '<S-CR>',
    },
    lsp_blacklist = {
      "null-ls",
      "tailwindcss",
    },
  }
}
