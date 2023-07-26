local set = require('userlib.runtime.keymap').map_buf_thunk(0)

set('n', '<localleader>cr', ':!cargo run<CR>', { noremap = true, desc = 'Run cargo run' })

set('n', '<localleader>b', function()
  local cwd = require('userlib.runtime.utils').get_root()
  require('userlib.terminal.rust-bacon-term').toggle_bacon_term(cwd)
end, { noremap = true, desc = 'Run bacon on cwd' })

set('n', '<localleader>B', function()
  local cwd = require('userlib.runtime.utils').get_root({
    only_pattern = true,
  })
  local workspace_root = require('userlib.runtime.utils').get_root({
    only_pattern = true,
    pattern_start_path = vim.fs.dirname(cwd),
  })
  if workspace_root then
    cwd = workspace_root
  end
  require('userlib.terminal.rust-bacon-term').toggle_bacon_term(cwd)
end, { noremap = true, desc = 'Run bacon on workspace root' })
