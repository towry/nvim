local plug = require('userlib.runtime.pack').plug

return plug({
  enabled = true,
  "echasnovski/mini.files",
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    windows = {
      preview = true,
      width_nofocus = 30,
      width_preview = 40,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
    },
    mappings = {
      go_in_plus = '<CR>',
    }
  },
  keys = {
    {
      "<leader>fI",
      function()
        local path = nil
        if vim.bo.buftype == 'nofile' then
          path = require('userlib.runtime.utils').get_root()
        else
          path = vim.api.nvim_buf_get_name(0)
        end
        local mf = require("mini.files");
        local is_closed = mf.close()
        if is_closed == true then return end
        require("mini.files").open(path, true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
    {
      "<leader>fi",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
    {
      "-",
      function()
        local path = nil
        if vim.bo.buftype == 'nofile' then
          path = require('userlib.runtime.utils').get_root()
        else
          path = vim.api.nvim_buf_get_name(0)
        end
        local mf = require("mini.files");
        local is_closed = mf.close()
        if is_closed == true then return end
        require("mini.files").open(path, true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
  },
  config = function(_, opts)
    require('mini.files').setup(opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args) vim.wo[args.data.win_id].relativenumber = true end,
    })
    vim.cmd('hi! link MiniFilesBorder NormalFloat')
  end,
})
