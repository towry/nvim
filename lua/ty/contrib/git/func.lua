local M = {}

--- Open the file history like in vscode.
--
-- @func
M.open_file_history = function() end

M.open_blame = function() require('ty.contrib.git.blame').open() end

M.toggle_file_history = require('ty.contrib.git.utils').toggle_file_history

return M
