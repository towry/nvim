local M = {}

M.attach = function(bufnr)
  local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

  set(
    'n',
    '<localleader>db',
    "<CMD>lua require('dap').toggle_breakpoint()<CR>",
    { noremap = true, silent = true }
  )
  set(
    'n',
    '<localleader>dc',
    "<CMD>lua require('dap').continue()<CR>",
    { noremap = true, silent = true }
  )
  set(
    'n',
    '<localleader>dd',
    "<CMD>lua require('dap').continue()<CR>",
    { noremap = true, silent = true }
  )
  set('n', '<localleader>dh', "<CMD>lua require('dapui').eval()<CR>", { noremap = true, silent = true })
  set(
    'n',
    '<localleader>di',
    "<CMD>lua require('dap').step_into()<CR>",
    { noremap = true, silent = true }
  )
  set(
    'n',
    '<localleader>do',
    "<CMD>lua require('dap').step_out()<CR>",
    { noremap = true, silent = true }
  )
  set(
    'n',
    '<localleader>dO',
    "<CMD>lua require('dap').step_over()<CR>",
    { noremap = true, silent = true }
  )
  set(
    'n',
    '<localleader>dt',
    "<CMD>lua require('dap').terminate()<CR>",
    { noremap = true, silent = true }
  )
end

return M
