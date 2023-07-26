local M = {}

---@see vim.keymap.set
M.set = vim.keymap.set

---Wrap string inside `<cmd>{str}<cr>`
---@param cmd string
---@return string
function M.cmdstr(cmd)
  return string.format('<cmd>%s<cr>', cmd)
end

---wrap string inside `<cmd>lua require(<module_path>)[call_sig]()<cr>`
function M.cmd_modcall(module_path, call_sig)
  if call_sig ~= '()' then
    call_sig = '.' .. call_sig
  end
  local cmd = 'lua require("' .. module_path .. '")' .. call_sig
  return M.cmdstr(cmd)
end

---Wrap string inside `<C-u><cmd>{str}<cr>`
---@param cmd string
---@return string
function M.cu_cmdstr(cmd)
  return string.format('<C-u><cmd>%s<cr>', cmd)
end

local map_buf_thunk_defered = {}
--- maybe use ft as throttle key
---@param bufnr number
function M.map_buf_thunk(bufnr)
  if bufnr == 0 or not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    M.set(mode, lhs, rhs, opts)
    if not map_buf_thunk_defered[bufnr] then
      map_buf_thunk_defered[bufnr] = true
      vim.schedule(function()
        require('userlib.runtime.au').exec_whichkey_refresh({
          buffer = bufnr
        })
      end)
    end
  end
end

return M
