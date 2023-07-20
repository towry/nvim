local M = {}




M.open = function(cwd, buffer, pre_hook)
  local ok, Hydra = pcall(require, 'hydra')
  if not ok then return end

  local _ = function(callback)
    return function()
      if pre_hook then
        pre_hook()
      else
        vim.cmd('wincmd w')
      end
      vim.schedule(callback)
    end
  end

  local hydra = Hydra({
    name = '',
    mode = { 'n', 'i' },
    config = {
      buffer = buffer,
    },
    heads = {
      { "t", _(function()
        local nvim_tree_api = require('nvim-tree.api')
        nvim_tree_api.tree.open({
          update_root = false,
          find_file = false,
          current_window = false,
        })
        nvim_tree_api.tree.change_root(cwd)
      end), { private = true, desc = "Tree", exit = true } },
      -- {
      --   "m",
      --   _(function()
      --     require('mini.files').open(cwd, true)
      --   end),
      --   {
      --     private = true,
      --     nowait = true,
      --     desc = "M.Files",
      --     exit = true,
      --   },
      -- },
      {
        "f",
        _(function()
          require('userlib.telescope.pickers').project_files({
            cwd = cwd,
            use_all_files = true,
          })
        end),
        {
          private = true,
          exit = true,
          desc = 'T.Files',
        }
      },
      {
        "p",
        _(function()
          require('telescope').extensions.file_browser.file_browser({
            files = false,
            use_fd = true,
            cwd = cwd,
            depth = 1,
            respect_gitignore = false,
          })
        end),
        {
          private = true,
          desc = 'Folders',
          exit = true,
        },
      },
      {
        "s",
        _(function()
          require('userlib.telescope.live_grep_call')({
            cwd = cwd,
          })
        end),
        {
          desc = 'Content',
          private = true,
          exit = true,
        }
      },
      {
        "r",
        _(function()
          require('userlib.telescope.pickers').project_files({
            oldfiles = true,
            cwd_only = false,
            cwd = cwd,
          })
        end),
        {
          private = true,
          desc = 'Recent',
          exit = true,
        }
      },
      {
        "w",
        _(function()
          -- only change for current window.
          vim.cmd('lcd ' .. cwd)
          vim.notify(('New cwd: %s'):format(require('userlib.runtime.path').home_to_tilde(cwd)), vim.log.levels.INFO)
        end),
        {
          private = true,
          desc = 'Cwd',
          exit = true,
        }
      },
      {
        "<CR>",
        _(function()
          require('mini.files').open(cwd)
        end),
        {
          private = true,
          desc = 'MiniFiles',
          exit = true,
        }
      }
    }
  })

  hydra:activate()
end

return M
