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

return M
