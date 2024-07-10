return {
  -- add LazyVim and import its plugins
  { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
  { import = 'lazyvim.plugins.extras.dap.core' },
  { import = 'lazyvim.plugins.extras.editor.overseer' },
  { import = 'lazyvim.plugins.extras.editor.fzf' },
  { import = 'lazyvim.plugins.extras.editor.mini-move' },
  -- import/override with your plugins
  { import = 'plugins' },
}
