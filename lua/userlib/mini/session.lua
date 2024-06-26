local M = {}

--- @param verbose? boolean
function M.make_session(verbose)
  local MS = require('mini.sessions')
  local branch_name = vim.fn['FugitiveHead']() or 'temp'
  local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
  local session_name = string.format('%s_%s', branch_name, cwd)
  -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
  session_name = string.gsub(session_name, '[/\\ .]', '_')
  MS.write(session_name, {
    force = true,
    verbose = verbose,
  })
end

function M.load_session()
  local MS = require('mini.sessions')
  local branch_name = vim.fn['FugitiveHead']() or 'temp'
  local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
  local session_name = string.format('%s_%s', branch_name, cwd)
  -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
  session_name = string.gsub(session_name, '[/\\ .]', '_')
  local _, err = pcall(MS.read, session_name, {
    -- do not delete unsaved buffer.
    force = false,
    verbose = true,
  })
  if err then
    vim.notify('Load session fail: ' .. session_name, vim.log.levels.ERROR)
  end
end

return M
