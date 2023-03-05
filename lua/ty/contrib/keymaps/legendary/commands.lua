local M = {}

function M.default_commands()
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
      ':Telescope find_files',
      description = 'Find project files',
    },
  }
end

function M.mini_commands()
  local commands = {
    {
      ':lua MiniTrailspace.trim()',
      description = 'Trim all trailing whitespace',
    },
    {
      ':lua MiniTrailspace.trim_last_lines()',
      description = 'Trim all trailing empty lines',
    },
  }

  return commands
end

-- @deprecated
function M.vim_clap_commands()
  local commands = {
    {
      ':Clap dumb_jump',
      description = 'Clap dumb jump',
    },
    {
      ':Clap blines',
      description = 'Clap blines',
    },
    {
      ':Clap colors',
      description = 'Clap colors',
    },
    {
      ':Clap',
      description = 'Clap clap 👏👏👏',
    },
    {
      ':Clap dumb_jump ++query=<cword> | startinsert',
      description = 'Clap dumb jump current word',
    },
  }

  return commands
end

-- @deprecated
function M.twilight_commands()
  return {
    {
      'TwilightEnable',
      description = 'Enable twilight',
    },
    {
      'Twilight',
      description = 'Toggle twilight',
    },
    {
      'TwilightDisable',
      description = 'Disable twilight',
    },
  }
end

return M
