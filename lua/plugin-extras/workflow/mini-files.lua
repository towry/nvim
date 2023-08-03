local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

return plug({
  enabled = true,
  "echasnovski/mini.files",
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    windows = {
      preview = true,
      width_nofocus = 30,
      width_preview = 60,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
    },
    mappings = {
      go_in_plus = '',
      go_in = 'f',
      go_out = 'F',
      go_out_plus = '',
      reset = '<C-r>',
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
        if require('userlib.runtime.buffer').is_empty_buffer(0) then
          path = vim.uv.cwd()
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
    local MF = require('mini.files')
    MF.setup(opts)
    au.define_user_autocmd({
      pattern = 'MiniFilesWindowOpen',
      callback = function(args)
        local win_id = args.data.win_id;
        vim.wo[win_id].relativenumber = true
        vim.wo[win_id].winblend = 50
      end,
    })
    au.define_user_autocmd({
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args)
        local win_id = args.data.win_id;
        local curr_win_id = vim.api.nvim_get_current_win()
        local is_focus = curr_win_id == win_id
        if not is_focus then
          vim.wo[win_id].winblend = 10
          vim.api.nvim_win_set_config(win_id, { border = 'double' })
        else
          vim.wo[win_id].winblend = 40
          vim.api.nvim_win_set_config(win_id, { border = 'single' })
        end
      end,
    })
    vim.cmd('hi! link MiniFilesBorder NormalFloat')
  end,
})
