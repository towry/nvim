local M = {}
local tig_pool = {}

--- Open the file history like in vscode.
--
-- @func
M.open_file_history = function()
end

M.open_blame = function() require('ty.contrib.git.blame').open() end

M.toggle_file_history = require('ty.contrib.git.utils').toggle_file_history
M.toggle_git_changes = require('ty.contrib.git.utils').toggle_working_changes

M.toggle_tig_file_history = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local tig = tig_pool[bufnr]
  if not tig then
    local Terminal  = require('toggleterm.terminal').Terminal
    local tig_      = Terminal:new({
      cmd = string.format("tig %s", vim.fn.expand("%")),
      dir = "git_dir",
      direction = "float",
      hidden = true,
      float_opts = {
        border = "double",
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
      -- function to run on closing the terminal
      on_close = function(term)
        vim.cmd("startinsert!")
      end,
    })
    tig_pool[bufnr] = tig_
    tig             = tig_

    vim.api.nvim_create_autocmd("BufUnload", {
      group = vim.api.nvim_create_augroup("tig_file_his_" .. bufnr, { clear = true }),
      buffer = bufnr,
      callback = function()
        if tig_pool[bufnr] then
          Ty.ECHO({ { "unload tig for buf " .. bufnr, "Comment" } }, true, {})
          tig_pool[bufnr]:close()
          tig_pool[bufnr] = nil
        end
      end,
    })
  end

  tig:toggle()
end

M.next_hunk = function()
  local gs = require('gitsigns')
  if vim.wo.diff then return end
  vim.schedule(function() gs.next_hunk() end)
end

M.prev_hunk = function()
  local gs = require('gitsigns')
  if vim.wo.diff then return end
  vim.schedule(function()
    gs.prev_hunk()
  end)
end

return M
