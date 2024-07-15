local utils = require('userlib.runtime.utils')

return {
  {
    function()
      local cwd = require('userlib.runtime.utils').get_root({
        root_patterns = { 'package.json' },
        pattern_start_path = vim.fn.expand('%:p:h'),
        only_pattern = true,
      })
      local pkg = require('userlib.runtime.path').join(cwd, 'package.json')
      if not vim.uv.fs_stat(pkg) then
        vim.notify('package.json not found', vim.log.levels.ERROR)
        return
      end
      if not vim.json then
        print('vim.json not found')
        return
      end
      local json = vim.json.decode(table.concat(vim.fn.readfile(pkg, ''), '\n'))
      vim.fn.setreg('+', json.name)
      vim.print(json.name)
    end,
    description = 'Copy current npm package.json name',
  },
  {
    function()
      local _ = require('userlib.runtime.utils')
      _.use_plugin('window-picker', function(winpick)
        local picked = winpick.pick_window({
          autoselect_one = false,
          include_current_win = false,
          hint = 'floating-big-letter',
        })
        if not picked then
          return
        end
        local current_buf = vim.api.nvim_get_current_buf()
        local current_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_call(picked, function()
          local bufnr = vim.fn.bufnr('#')
          if bufnr == current_buf or bufnr < 0 then
            vim.notify('No alternative buffer in window:' .. picked, vim.log.levels.INFO)
            return
          end
          -- set bufnr to current_win
          vim.api.nvim_win_set_buf(current_win, bufnr)
        end)
      end)
    end,
    description = 'Edit other window alternate buffer',
  },
  {
    function()
      vim.ui.input({
        prompt = 'Tab label:',
      }, function(input)
        vim.t.TabLabel = input or ''
      end)
    end,
    description = 'Name tab label',
  },
  {
    function()
      local user_config_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')
      local notes = user_config_dir .. '/doc/user-notes.md'
      vim.cmd.tabe(notes) -- edit user-notes
    end,
    description = 'Edit user-notes',
  },
  {
    function()
      local user_config_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')
      vim.cmd(
        ([[OverDispatch! cd %s && git add ./doc/user-notes.md && git commit -m "doc: update user-notes" && git push origin main]]):format(
          user_config_dir
        )
      )
    end,
    description = 'Sync user-notes',
  },
  {
    function()
      vim.fn.setreg('*', vim.fn.expand('%'))
      vim.notify('File path copied to register *', vim.log.levels.INFO)
    end,
    description = 'Copy current file path to register *',
  },
  {
    function()
      local user_config_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')
      vim.cmd(([[OverDispatch! cd %s && make doc]]):format(user_config_dir))
    end,
    description = 'Make user notes',
  },
  {
    function()
      require('userlib.mini.trim').trim()
    end,
    description = 'Trim all trailing whitespace',
  },
  {
    function()
      require('userlib.mini.trim').trim_last_lines()
    end,
    description = 'Trim all trailing empty lines',
  },
  {
    function()
      for name, _ in pairs(package.loaded) do
        if name:match('^plugins.') or name:match('^user.') or name:match('userlib.') then
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
      require('userlib.telescope.pickers').edit_neovim()
    end,
    description = 'Edit Neovim dotfiles(nvimrc)',
  },
  {
    function()
      vim.cmd('e ' .. vim.fs.dirname(vim.fn.expand('$MYVIMRC')) .. '/lua/ty/contrib/editing/switch_rc.lua')
    end,
    description = 'Edit switch definitions',
  },
  -- dismiss notify
  {
    function()
      require('notify').dismiss()
    end,
    description = 'Dismiss notifications',
  },
  -- toggle light mode.
  {
    function()
      Ty.ToggleTheme()
    end,
    description = 'Toggle dark/light mode',
  },
  {
    -- function() require('userlib.lsp.fmt').toggle_formatting_enabled() end,
    function()
      require('userlib.lsp.servers.null_ls.autoformat').toggle()
    end,
    description = 'Toggle auto format',
  },
  {
    function()
      require('userlib.telescope.pickers').project_files({ no_gitfiles = true })
    end,
    description = 'Telescope find project files (No Git)',
  },
  {
    itemgroup = 'Navigation UI',
    funcs = {
      {
        function()
          require('harpoon.ui').toggle_quick_menu()
        end,
        description = "harpoon marks menu',",
      },
      {
        function()
          require('grapple').popup_tags()
        end,
        description = 'grapple popup tags',
      },
    },
  },
  {
    function()
      utils.load_plugins('blackjack.nvim')
      vim.cmd('BlackJackNewGame')
    end,
    description = 'New black jack game',
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
      vim.ui.input({
        prompt = 'Are you sure? (y/n)',
      }, function(input)
        if input ~= 'y' and input ~= 'Y' and input ~= 'yes' then
          return
        end
        vim.cmd('e!')
        vim.notify('Changes reverted')
      end)
    end,
    description = 'Discard changes',
  },
  {
    function()
      vim.notify('Build start')
      if vim.loader then
        vim.loader.reset()
        vim.loader.disable()
      end
      vim.schedule(function()
        require('zenbones.shipwright').run()
        vim.notify('Build done')
      end)
    end,
    description = 'Build zenbones',
  },
}
