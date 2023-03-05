local function bind_jest_keys(bufnr)
  local utils = require('ty.core.utils')
  local keymap = require('ty.core.keymap')
  local n, cmd = keymap.n, keymap.cmd
  if not utils.has_plugin('neotest') then return end

  local prefix = 'lua require("neotest").'
  n('<localleader>jt', 'Jest: Run current test', cmd(prefix .. 'run.run(vim.fn.expand("%"))', { buffer = bufnr }))
  n('<localleader>ji', 'Jest: Toggle info panel', cmd(prefix .. 'summary.toggle()', { buffer = bufnr }))
  n('<localleader>jj', 'Jest: Run nearest test', cmd(prefix .. 'run.run()', { buffer = bufnr }))
  n('<localleader>jl', 'Jest: Run last test', cmd(prefix .. 'run.run_last()', { buffer = bufnr }))
  n('<localleader>jo', 'Jest: Open test output', cmd(prefix .. 'output.open({ enter = true })', { buffer = bufnr }))
  n('<localleader>js', 'Jest: Stop', cmd(prefix .. 'run.stop()', { buffer = bufnr }))
end

return function(au)
  au:create('BufEnter', {
    pattern = Ty.Config.with_default('debugger.testing.jest_file_pattern', { '*test.js', '*test.ts', '*test.tsx' }),
    callback = function(ctx) bind_jest_keys(ctx.bufnr) end,
  })
end
