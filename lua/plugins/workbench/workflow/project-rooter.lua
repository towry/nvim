return {
  {
    'ahmedkhalf/project.nvim',
    name = 'project_nvim',
    event = { 'VeryLazy' },
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
