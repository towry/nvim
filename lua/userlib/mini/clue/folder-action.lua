local au = require('userlib.runtime.au')
local M = {}

M.open = function(new_cwd)
  new_cwd = require('userlib.runtime.path').remove_path_last_separator(new_cwd)
  local nicely_cwd = require('userlib.runtime.path').make_relative(new_cwd, vim.cfg.runtime__starts_cwd)

  require('userlib.mini.clue').shortly_open(function(set, unset)
    set('n', '1', '<cmd>echo expand("%")<cr>', { desc = ' :' .. nicely_cwd })
    set('n', 'f', function()
      require('userlib.telescope.pickers').project_files({
        cwd = new_cwd,
        use_all_files = true,
      })
      unset()
    end, {
      desc = 'Open files',
    })
    set('n', 'p', function()
      require('telescope').extensions.file_browser.file_browser({
        files = false,
        use_fd = true,
        cwd = new_cwd,
        respect_gitignore = true,
      })
      unset()
    end, {
      desc = 'Open folders',
    })
    set('n', 's', function()
      require('userlib.telescope.live_grep_call')({
        cwd = new_cwd,
      })
      unset()
    end, {
      desc = 'Search content',
    })
    set('n', 'g', function()
      require('rgflow').open(nil, nil, new_cwd)
    end, {
      desc = 'Grep on it',
    })
    set('n', 'r', function()
      require('userlib.telescope.pickers').project_files({
        oldfiles = true,
        cwd_only = false,
        cwd = new_cwd,
      })
      unset()
    end, {
      desc = 'Open recent',
    })
    set('n', 'w', function()
      require('userlib.runtime.utils').change_cwd(new_cwd, 'tcd')
      vim.schedule(function()
        au.exec_useraucmd(au.user_autocmds.DoEnterDashboard)
      end)
      unset()
    end, {
      desc = 'Change cwd',
    })
    set('n', 'o', function()
      require('oil').open(new_cwd)
      unset()
    end, {
      desc = 'Open in oil',
    })
    set('n', 't', function()
      vim.cmd('tabfind ' .. new_cwd)
      unset()
    end, {
      desc = 'Open in tab',
    })
    set('n', 'c', function()
      vim.cmd(string.format('ToggleTerm dir=%s', new_cwd))
    end, {
      desc = 'Open in terminal',
    })
    set('n', 'p', function()
      require('userlib.mini.visits').add_project(new_cwd, vim.cfg.runtime__starts_cwd)
    end, {
      desc = 'Mark project',
    })
  end)
end

return M
