return {
  config = function()
    local conflict = require('git-conflict')

    conflict.setup({
      default_mappings = false, -- disable buffer local mapping created by this plugin
      default_commands = true,
      disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = {            -- They must have background color, otherwise the default color will be used
        -- incoming = 'DiffText',
        -- current = 'DiffAdd',
      },
    })
  end,
}
