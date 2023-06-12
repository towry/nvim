return {
  'stevearc/oil.nvim',
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    default_file_explorer = true,
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-x>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
    float = {
      padding = 3,
      border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
      win_options = {
        winblend = 0,
      }
    }
  },
  keys = {
    {
      '<leader>eO',
      function()
        local cwd = require('libs.runtime.utils').get_root()
        require('oil').open(cwd)
      end,
      desc = 'Open oil(CWD) file browser',
    },
    {
      '<leader>eo',
      function()
        require('oil').open()
      end,
      desc = 'Open oil(BUF) file browser',
    },
    {
      -- Hyper+e
      '<C-S-A-e>',
      function()
        require('oil').open()
      end,
      desc = 'Open oil(BUF) file browser'
    }
  }
}
