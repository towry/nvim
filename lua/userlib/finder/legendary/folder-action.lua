return function(cwd)
  local select_prompt = 'Folder action under: ' .. require('userlib.runtime.path').home_to_tilde(cwd)
  local funcs = {
    {
      label = '  Open NVimTree',
      function()
        local nvim_tree_api = require('nvim-tree.api')
        nvim_tree_api.tree.open({
          update_root = false,
          find_file = false,
          current_window = false,
        })
        nvim_tree_api.tree.change_root(cwd)
      end,
    },
    {
      label = '  Open mini.files',
      function()
        require('mini.files').open(cwd, true)
      end,
    },
    {
      label = '  Find files',
      hint = 'Telescope',
      function()
        require('userlib.telescope.pickers').project_files({
          cwd = cwd,
          use_all_files = true,
        })
      end,
    },
    {
      label = '  Recent files',
      hint = 'Telescope',
      function()
        require('userlib.telescope.pickers').project_files({
          oldfiles = true,
          cwd_only = true,
          cwd = cwd,
        })
      end,
    },
    {
      label = '  Search content',
      hint = 'Telescope rig',
      function()
        require('userlib.telescope.live_grep_call')({
          cwd = cwd,
        })
      end,
    },
    {
      label = '  Find folders',
      hint = 'Telescope',
      function()
        require('telescope').extensions.file_browser.file_browser({
          files = false,
          use_fd = true,
          cwd = cwd,
          depth = 1,
          respect_gitignore = false,
        })
      end,
    }
  }

  require('userlib.ui.dropdown').select({
    items = funcs,
    on_select = function(entry)
      entry.command()
    end
  }, {
    prompt_title = select_prompt,
  })
end
