local set = vim.keymap.set
local M = {}

--- parse { '+silent', '-silent', buffer = bufnr } etc opt into dict.
local function parse_opts(opts)
  local result = {
    silent = true,
  }

  if not opts then return result end

  for _, opt in ipairs(opts) do
    local first_char = opt:sub(1, 1)
    if first_char == '+' then
      result[opt:sub(2)] = true
    elseif first_char == '-' then
      result[opt:sub(2)] = false
    end
  end

  if opts.buffer ~= nil then result.buffer = opts.buffer end

  return result
end

local function map_one(mode, lhs, desc, rhs_opts)
  if type(rhs_opts) ~= 'table' then error('invalid usage, correct`map(lhs, description, (key|cmd)(rhs, opts))`') end

  local rhs = rhs_opts[1]
  local opts = rhs_opts[2] or {}
  opts.desc = desc
  set(mode, lhs, rhs, opts)
end

---@usage map('n', 'a', 'desc', cmd('<cmd ...>', {'+silent', '-noremap' })
local function map(mode, lhs, desc, rhs_opts)
  if type(lhs) == 'table' and type(lhs[1]) ~= 'table' then
    error('invalid usage')
  elseif type(lhs) == 'table' then
    for _, locallhs in ipairs(lhs) do
      -- mode, lhs, desc, rhs_opts.
      map_one(mode, locallhs[1], locallhs[2], locallhs[3])
    end
    return
  end
  if not rhs_opts then return end -- do not set for empty descriptive keymap.
  map_one(mode, lhs, desc, rhs_opts)
end

M.map = map
M.nmap = function(lhs, desc, rhs_opts) map('n', lhs, desc, rhs_opts) end
M.vmap = function(lhs, desc, rhs_opts) map('v', lhs, desc, rhs_opts) end
M.xmap = function(lhs, desc, rhs_opts) map('x', lhs, desc, rhs_opts) end
M.imap = function(lhs, desc, rhs_opts) map('i', lhs, desc, rhs_opts) end
M.tmap = function(lhs, desc, rhs_opts) map('t', lhs, desc, rhs_opts) end
M.cmap = function(lhs, desc, rhs_opts) map('c', lhs, desc, rhs_opts) end
M.nimap = function(lhs, desc, rhs_opts) map({ 'i', 'n' }, lhs, desc, rhs_opts) end
M.amap = function(lhs, desc, rhs_opts) map({ 'i', 'n', 'v', 'x', 't', 'c' }, lhs, desc, rhs_opts) end
M.nxv = function(lhs, desc, rhs_opts) map({ 'n', 'v', 'x' }, lhs, desc, rhs_opts) end
M.nx = function(lhs, desc, rhs_opts) map({ 'n', 'x' }, lhs, desc, rhs_opts) end
M.nv = function(lhs, desc, rhs_opts) map({ 'n', 'v' }, lhs, desc, rhs_opts) end

---@param str string command string
---@param opts_tbl? table additional options.
---@field opts_tbl.buffer number the local buffer
---@usage cmd('lua Ty.Func.xxx()', { '-silent' })
M.cmd = function(str, opts_tbl)
  local opts = parse_opts(opts_tbl)
  return { '<cmd>' .. str .. '<cr>', opts }
end
M.key = function(sr, opts_tbl)
  local opts = parse_opts(opts_tbl)
  return { sr, opts }
end
--- visual
---@see cmd
M.cu = function(str, opts_tbl)
  local opts = parse_opts(opts_tbl)
  return { '<C-u><cmd>' .. str .. '<CR>', opts }
end

return M
