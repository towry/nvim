local au = require('userlib.runtime.au')
local M = {}

M.open = function(new_cwd)
  new_cwd = require('userlib.runtime.path').remove_path_last_separator(new_cwd)
  local nicely_cwd = require('userlib.runtime.path').make_relative(new_cwd, vim.cfg.runtime__starts_cwd)

  require('userlib.mini.clue').shortly_open(function(set, unset)
    set('n', '1', '<cmd>echo expand("%")<cr>', { desc = ' :' .. nicely_cwd })

    set('n', 'l', function()
      require('userlib.runtime.utils').lock_tcd(new_cwd)
    end, {
      desc = 'Lock cwd to current tab',
    })

    set('n', 'L', function()
      require('userlib.runtime.utils').lock_tcd_newtab(new_cwd)
    end, {
      desc = 'Lock cwd to new tab',
    })

    set('n', 'f', function()
      if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
        require('userlib.fzflua').files({
          cwd = new_cwd,
          cwd_header = true,
        })
      else
        require('userlib.telescope.pickers').project_files({
          cwd = new_cwd,
        })
      end
      unset()
    end, {
      desc = 'Open files',
    })
    set('n', 'p', function()
      if vim.cfg.plugin_fzf_or_telescope == 'telescope' then
        require('telescope').extensions.file_browser.file_browser(require('userlib.telescope.themes').get_dropdown({
          files = false,
          disable_devicons = true,
          use_fd = true,
          display_stat = false,
          hide_parent_dir = true,
          respect_gitignore = true,
          hidden = true,
          previewer = false,
          depth = 3,
          git_status = false,
          cwd = new_cwd,
        }))
      else
        require('userlib.fzflua').folders({
          cwd = new_cwd,
          cwd_header = true,
        })
      end
      unset()
    end, {
      desc = 'Open folders',
    })
    set('n', 's', function()
      if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
        require('fzf-lua').live_grep({
          cwd = new_cwd,
          cwd_header = true,
        })
      else
        require('userlib.telescope.live_grep_call')({
          cwd = new_cwd,
        })
      end
      unset()
    end, {
      desc = 'Search content',
    })

    set('n', '|', function()
      require('neo-tree.command').execute({
        position = 'right',
        reveal_file = new_cwd,
        reveal_force_cwd = true,
      })
    end, {
      desc = 'Open in tree',
    })

    set('n', '\\', function()
      require('neo-tree.command').execute({
        position = 'left',
        reveal_file = new_cwd,
        reveal_force_cwd = true,
        source = 'buffers',
      })
    end, {
      desc = 'Open in tree and reveal buffers',
    })

    set('n', 'g', function()
      require('rgflow').open(nil, nil, new_cwd)
    end, {
      desc = 'Grep on it',
    })
    set('n', 'r', function()
      require('fzf-lua').oldfiles({
        cwd_header = true,
        cwd = new_cwd,
        cwd_only = true,
        winopts = {
          fullscreen = false,
        },
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
