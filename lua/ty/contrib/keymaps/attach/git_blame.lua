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
  local n, cmd = keymap.nmap, keymap.cmd
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
    callback = function(ctx) bind_git_blame_keys(ctx.buf) end,
  })

  au.listen(au.EVENTS.on_git_diffview_open, function(ctx)
    local view = ctx.data.view
    local km = require('ty.core.keymap')
    local lib = require('diffview.lib')

    km.nmap('<leader>q', ' Quit git diff', { function()
      if not view then
        vim.cmd("DiffviewClose")
        return
      end
      view:close()
      lib.dispose_view(view)
    end, {
      buffer = ctx.buf,
    } })
  end)
end
