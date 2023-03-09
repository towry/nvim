local M = {}

--- Open the file history like in vscode.
--
-- @func
M.open_file_history = function()
end

M.open_blame = function() require('ty.contrib.git.blame').open() end

M.toggle_file_history = require('ty.contrib.git.utils').toggle_file_history
M.toggle_git_changes = require('ty.contrib.git.utils').toggle_working_changes

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
