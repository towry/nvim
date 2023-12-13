local M = {}


function M.make_session()
  local MS = require('mini.sessions')
  local branch_name = vim.fn['FugitiveHead']() or 'temp'
  local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
  local session_name = string.format('%s_%s', branch_name, cwd)
  -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
  session_name = string.gsub(session_name, '[/\\ .]', '_')
  MS.write(session_name, {
    force = true,
  })
end

function M.load_session()
  local MS = require('mini.sessions')
  local branch_name = vim.fn['FugitiveHead']() or 'temp'
  local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
  local session_name = string.format('%s_%s', branch_name, cwd)
  -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
  session_name = string.gsub(session_name, '[/\\ .]', '_')
  MS.read(session_name, {
    -- do not delete unsaved buffer.
    force = false,
    verbose = true,
  })
end

return M
