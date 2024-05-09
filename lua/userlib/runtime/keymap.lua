local M = {}

local is_in_tmux = vim.env['TMUX'] ~= nil
local is_mimic_super = vim.env['MIMIC_SUPER'] ~= nil

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
  call_sig = vim.trim(call_sig)
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

local buf_local_help = {}

function M.get_buf_local_help(label)
  return buf_local_help[label] or {}
end

local map_buf_thunk_defered = {}
--- maybe use ft as throttle key
---@param bufnr number
---@param opts? { label: string }
function M.map_buf_thunk(bufnr, opts)
  opts = opts or {}

  if opts.label and opts.label ~= '' and not buf_local_help[opts.label] then
    buf_local_help[opts.label] = {}
  end

  if bufnr == 0 or not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  return function(mode, lhs, rhs, opts_)
    opts_ = opts_ or {}
    opts_.buffer = bufnr

    if opts_.desc and (opts.label and opts.label ~= '') then
      table.insert(buf_local_help[opts.label], {
        mode = mode,
        lhs = lhs,
        desc = opts_.desc,
      })
    end

    M.set(mode, lhs, rhs, opts_)
    if not map_buf_thunk_defered[bufnr] then
      map_buf_thunk_defered[bufnr] = true

      vim.schedule(function()
        require('userlib.runtime.au').exec_whichkey_refresh({
          buffer = bufnr,
        })
      end)
    end
  end
end

---WezTerm support super key
function M.super(c)
  if not is_in_tmux or not is_mimic_super then
    if c == ';' then
      return [[<C-;>]]
    end
    return string.format('<D-%s>', c)
  end
  return string.format('<Char-0xAE>%s', c)
end

return M
