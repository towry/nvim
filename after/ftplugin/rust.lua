local set = require('userlib.runtime.keymap').map_buf_thunk(0)

set('n', '<localleader>cr', ':QfCloseNextEsc | OverDispatch cargo run<CR>', { noremap = true, desc = 'Run cargo run' })
set(
  'n',
  '<localleader>cb',
  ':QfCloseNextEsc | OverDispatch! cargo build<cr>',
  { noremap = true, desc = 'Run cargo build' }
)

set('n', '<localleader>b', function()
  local cwd = require('userlib.runtime.utils').get_root()
  require('userlib.terminal.rust-bacon-term').toggle_bacon_term(cwd)
end, { noremap = true, desc = 'Run bacon on cwd', nowait = true })

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

if not (vim.b.is_big_file and vim.g.vscode) then
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
end

if vim.cfg.edit__use_coc then
  set('n', '<localleader>r', ':<C-u>CocCommand rust-analyzer.run<cr>', {
    noremap = true, desc = 'Run run', })
end

if vim.fn.executable('codesort') == 1 then
  set('n', '<localleader>cs',
    [[ma<ESC>:execute ":%!codesort --around ".line('.')." --detect ".shellescape(expand('%:t'))<CR>`a]], {
      noremap = true,
      desc = 'Sort code',
    })
  set('x', '<localleader>cs', [[:<C-u>'<,'>!codesort<cr>]], { noremap = true, desc = 'Sort code' })
end
