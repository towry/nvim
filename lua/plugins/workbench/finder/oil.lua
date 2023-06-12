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
        require('oil').toggle(cwd)
      end,
      desc = 'Toggle oil(CWD) file browser in float',
    },
    {
      '<leader>eo',
      function()
        require('oil').toggle()
      end,
      desc = 'Toggle oil(BUF) file browser in float',
    }
  }
}
