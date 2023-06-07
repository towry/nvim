return {
  -- copilot
  {
    ':Copilot enable',
    description = 'Enable github copilot',
  },
  {
    ':Copilot disable',
    description = 'Disable github copilot',
  },
  -- troubles.
  {
    ':TodoTrouble',
    description = 'Show todo in trouble',
  },
  {
    [[:exe "TodoTrouble cwd=" . expand("%:p:h")]],
    description = 'Show todo in trouble within current file directory',
  },
  -- switch
  {
    ':Switch',
    description = 'Switch variable, e.g: {true <-> false}',
  },
  -- markdown
  {
    ':MarkdownPreview',
    description = 'Start markdown preview',
  },
  {
    ':MarkdownPreviewStop',
    description = 'Stop markdown preview',
  },
  {
    ':Telescope keymaps',
    description = 'Show all  keymaps',
  },
  {
    ':Cheat',
    description = 'Open cheat.sh',
  },
  {
    ':Cheatsheet',
    description = 'Open cheatsheet',
  },

  ------ mini
  {
    ':lua MiniTrailspace.trim()',
    description = 'Trim all trailing whitespace',
  },
  {
    ':lua MiniTrailspace.trim_last_lines()',
    description = 'Trim all trailing empty lines',
  },
  ----------------------------------
}
