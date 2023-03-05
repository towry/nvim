local M = {}

function M.default_functions()
  return {
    {
      function()
        vim.cmd('source $MYVIMRC')
        Ty.NOTIFY('nvimrc reloaded')
      end,
      description = 'Reload nvimrc',
    },
    {
      function() vim.cmd('e ' .. vim.fs.dirname(vim.fn.expand('$MYVIMRC')) .. '/lua/ty/contrib/editing/switch_rc.lua') end,
      description = 'Edit switch definitions',
    },
    {
      function()
        local config = require('gitsigns.config').config
        if config.current_line_blame then
          -- disable
          config.current_line_blame = false
          vim.api.nvim_create_augroup('gitsigns_blame', {
            clear = true,
          })
          Ty.NOTIFY('line blame OFF')
        else
          -- enable.
          config.current_line_blame = true
          require('gitsigns.current_line_blame').setup()
          Ty.NOTIFY('line blame ON')
        end
      end,
      description = 'Gitsigns toggle line blame',
    },
    -- dismiss notify
    {
      function() require('notify').dismiss() end,
      description = 'Dismiss notifications',
    },
    -- git worktree
    {
      function() require('telescope').extensions.git_worktree.git_worktrees() end,
      description = 'Git worktrees',
    },
    {
      function() require('telescope').extensions.git_worktree.create_git_worktree() end,
      description = 'Git create worktree',
    },
    -- toggle light mode.
    {
      function() Ty.ToggleTheme() end,
      description = 'Toggle dark/light mode',
    },
    {
      function() require('ty.contrib.editing.lsp.formatting').toggle_format() end,
      description = 'Toggle auto format',
    },
  }
end

-- @deprecated
function M.vim_clap_funcs()
  local funcs = {
    {
      function() vim.fn['clap#installer#download_binary']() end,
      description = 'Download and install clap binary',
    },
  }
  return funcs
end

return M
