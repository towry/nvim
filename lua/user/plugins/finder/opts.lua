return {
  code_outline = {
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
  },

  search_spectre = {
    color_devicons = true,
    open_cmd = 'vnew',
    live_update = true,
    is_insert_mode = false,
    is_open_target_win = false,
  },

  monorepo = {
    autoload_telescope = true,
  },

  surround = {
    keymaps = {
      delete = 'dz',
    },
  },

  grapple = {
    log_level = 'error',
    scope = 'git',
    integrations = {
      resession = false,
    },
  }
}
