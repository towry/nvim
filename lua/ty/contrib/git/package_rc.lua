local M = {}

M.setup_gitsigns = require('ty.contrib.git.gitsigns_rc').setup
M.setup_git_conflict = function()
  local conflict = pcall(require, 'git-conflict')

  conflict.setup({
    default_mappings = true, -- disable buffer local mapping created by this plugin
    disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
    highlights = { -- They must have background color, otherwise the default color will be used
      incoming = 'DiffText',
      current = 'DiffAdd',
    },
  })
end
M.setup_git_worktree = require('ty.contrib.git.worktree_rc').setup

return M
