return {
  {
    'telescope.nvim',
    dependencies = {
      {
        'ahmedkhalf/project.nvim',
        name = 'project_nvim',
        cmd = { 'ProjectRoot' },
        keys = {
          {
            '<leader>ep', '<Cmd>Telescope projects<CR>', desc = 'Projects',
          }
        },
        config = function(_, opts)
          require('project_nvim').setup(opts)
          require('telescope').load_extension('projects')
        end,
        opts = {
          patterns = { '.git', '_darcs', '.bzr', '.svn', '.vscode', '.gitmodules', 'pnpm-workspace.yaml' },
          manual_mode = false,
          -- Table of lsp clients to ignore by name
          -- eg: { "efm", ... }
          ignore_lsp = {},
          -- Don't calculate root dir on specific directories
          -- Ex: { "~/.cargo/*", ... }
          exclude_dirs = {},
          -- Show hidden files in telescope
          show_hidden = false,
          -- When set to false, you will get a message when project.nvim changes your
          -- directory.
          silent_chdir = true,
          -- What scope to change the directory, valid options are
          -- * global (default)
          -- * tab
          -- * win
          scope_chdir = 'global',
        }
      }
    }
  },
  {
    "goolord/alpha-nvim",
    optional = true,
    opts = function(_, dashboard)
      local button = dashboard.button("p", " " .. " Projects", ":Telescope projects <CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
    end
  },
  {
    "echasnovski/mini.starter",
    optional = true,
    opts = function(_, opts)
      local items = {
        {
          name = "Projects",
          action = "Telescope projects",
          section = string.rep(" ", 22) .. "Telescope",
        },
      }
      vim.list_extend(opts.items, items)
    end,
  },
}
