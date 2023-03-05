-- bind keys when git blame is open.

local config = {
  keymaps = {
    quit_blame = 'q',
    blame_commit = '<CR>',
  },
}

local function bind_git_blame_keys(bufnr)
  if not bufnr then error('invalid setup') end

  local keymap = require('ty.core.keymap')
  local n, cmd = keymap.n, keymap.cmd
  local opts = {
    '+noremap',
    '+silent',
    '-expr',
    buffer = bufnr,
  }
  n(config.keymaps.quit_blame, '[Git] Quit git blame', cmd('q', opts))
  n(
    config.keymaps.blame_commit,
    '[Git] Open blame commit',
    cmd([[lua require('ty.contrib.git.blame').blame_commit()]], opts)
  )
end

return function(au)
  au:create('User', {
    pattern = au.EVENTS.on_git_blame_done,
    callback = function(ctx) bind_git_blame_keys(ctx.bufnr) end,
  })
end
