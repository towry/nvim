local utils = require('libs.runtime.utils')

return {
  {
    function()
      for name, _ in pairs(package.loaded) do
        if name:match('^plugins.') or name:match('^user.') or name:match('libs.') then
          package.loaded[name] = nil
        end
      end

      dofile(vim.env.MYVIMRC)
      Ty.NOTIFY('nvimrc reloaded')
    end,
    description = 'Reload nvimrc',
  },
  {
    function()
      require('libs.telescope.pickers').edit_neovim()
    end,
    description = "Edit Neovim dotfiles(nvimrc)",
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
    function() require('libs.lsp-format.autoformat').toggle() end,
    description = 'Toggle auto format',
  },
  {
    function() require('libs.session').save_current_session() end,
    description = "[Session] Save current session",
  },
  {
    function() require('libs.session').load_last_session() end,
    description = "[Session] Load last session",
  },
  {
    function() require('libs.session').load_current_session() end,
    description = "[Session] Load current dir session",
  },

  {
    function() require('libs.session').remove_current_sesion() end,
    description = "[Session] Remove current session",
  },
  {
    function() require('libs.session').list_all_session() end,
    description = "[Session] List all session",
  },
  {
    function() require('libs.telescope.pickers').project_files({ no_gitfiles = true }) end,
    description = "Telescope find project files (No Git)",
  },
  {
    itemgroup = "Navigation UI",
    funcs = {
      {
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
        description = "harpoon marks menu',"
      },
      {
        function()
          require('grapple').popup_tags()
        end,
        description = "grapple popup tags",
      }
    }
  },
  {
    function()
      utils.load_plugins('blackjack.nvim')
      vim.cmd('BlackJackNewGame')
    end,
    description = "New black jack game",
  },
  {
    function()
      utils.load_plugins('nvim-colorizer.lua')
      vim.cmd('ColorizerAttachToBuffer')
    end,
    description = 'Enable colorizer on buffer (color)',
  },
  {
    function()
      utils.load_plugins('nvim-colorizer.lua')
      vim.cmd('ColorizerToggle')
    end,
    description = 'Toggle colorizer',
  },
  {
    function()
      require('libs.telescope.pickers').project_files_toggle_between_git_and_fd()
      Ty.NOTIFY("Toggle between git and fd done", vim.log.levels.INFO)
    end,
    description = "Toggle telescope project files source, git or find files",
  },
  {
    function()
      vim.ui.input({
        prompt = "Are you sure? (y/n)",
      }, function(input)
        if input ~= 'y' and input ~= 'Y' and input ~= 'yes' then
          return
        end
        vim.cmd("e!")
        vim.notify("Changes reverted")
      end)
    end,
    description = "Discard changes",
  }
}
