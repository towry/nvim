local M = {}

M.open = function()
  local hint = [[
  Snip run
  _f_: Run snip    _F_: Run snip operator
  _i_: Snip info   _r_: Snip reset
  _c_: Snip close  _m_: Snip repl memory clean
  _l_: Snip live   _q_: Exit
  ]]
  local Hydra = require('hydra')
  Hydra({
    name = 'Snip run',
    color = 'blue',
    hint = hint,
    config = {
      color = 'blue',
      hint = {
        border = true,
      }
    },
    heads = {
      { 'f', '<Plug>SnipRun', { desc = 'Snip run', silent = true } },
      { 'F', '<Plug>SnipRunOperator', { desc = 'Snip run operator', silent = true } },
      { 'i', '<Plug>SnipInfo', { desc = 'Snip info', silent = true } },
      { 'r', '<Plug>SnipReset', { desc = 'Snip reset', silent = true } },
      { 'c', '<Plug>SnipClose', { desc = 'Snip close', silent = true } },
      { 'm', '<Plug>SnipReplMemoryClean', { desc = 'Snip repl memory clean', silent = true } },
      { 'l', '<Plug>SnipLive', { desc = 'Snip live', silent = true } },
      { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
    },
  }):activate()
end

M.open_visual = function()
  local hint = [[
  Snip run visual
  _f_: Run snip    _F_: Run snip operator
 ]]
  local Hydra = require('hydra')
  Hydra({
    name = 'Snip run visual',
    color = 'blue',
    hint = hint,
    mode = 'v',
    config = {
      color = 'blue',
      hint = {
        border = true,
      }
    },
    heads = {
      { 'f', ":'<,'>SnipRun<cr>", { desc = 'Snip run', silent = true, } },
      { 'F', ":SnipRun<cr>", { desc = 'Snip run operator', silent = true, } },
      { 'q', nil, { exit = true, nowait = true, desc = 'exit', } },
    },
  }):activate()
end


return M
