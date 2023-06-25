local plug = require('libs.runtime.pack').plug

return plug({
  "echasnovski/mini.files",
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    windows = {
      preview = true,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
    },
  },
  keys = {
    {
      '<Char-0xAC>',
      function()
        local path = nil
        if vim.bo.buftype == 'nofile' then
          path = require('libs.runtime.utils').get_root()
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
      "<leader>eI",
      function()
        local path = nil
        if vim.bo.buftype == 'nofile' then
          path = require('libs.runtime.utils').get_root()
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
      "<leader>ei",
      function()
        require("mini.files").open(vim.loop.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
  config = function(_, opts)
    require('mini.files').setup(opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args) vim.wo[args.data.win_id].relativenumber = true end,
    })
  end,
  init = function()
    require('libs.finder.hook').register_select_folder_action(function(cwd)
      require('mini.files').open(cwd, false)
    end)
  end
})
