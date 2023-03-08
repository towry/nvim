-- most of the code comes from which-key plugin.

local M = {}

M.mappings = {}
M.duplicates = {}


function M.count(tab)
  local ret = 0
  for _, _ in pairs(tab) do
    ret = ret + 1
  end
  return ret
end

function M.get_mode()
  local mode = vim.api.nvim_get_mode().mode
  mode = mode:gsub(M.t("<C-V>"), "v")
  mode = mode:gsub(M.t("<C-S>"), "s")
  return mode:lower()
end

function M.is_empty(tab)
  return M.count(tab) == 0
end

function M.t(str)
  -- https://github.com/neovim/neovim/issues/17369
  local ret = vim.api.nvim_replace_termcodes(str, false, true, true):gsub("\128\254X", "\128")
  return ret
end

-- stylua: ignore start
local utf8len_tab = {
  -- ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9 ?A ?B ?C ?D ?E ?F
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 0?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 1?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 2?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 3?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 4?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 5?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 6?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 7?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 8?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- 9?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- A?
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -- B?
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, -- C?
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, -- D?
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, -- E?
  4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1, -- F?
}
-- stylua: ignore end

---@return KeyCodes
function M.parse_keys(keystr)
  local keys = {}
  local cur = ""
  local todo = 1
  local special = nil
  for i = 1, #keystr, 1 do
    local c = keystr:sub(i, i)
    if special then
      if todo == 0 then
        if c == ">" then
          table.insert(keys, special .. ">")
          cur = ""
          todo = 1
          special = nil
        elseif c == "-" then
          -- When getting a special key notation:
          --   todo = 0 means it can be ended by a ">" now.
          --   todo = 1 means ">" should be treated as the modified character.
          todo = 1
        end
      else
        todo = 0
      end
      if special then
        special = special .. c
      end
    elseif c == "<" then
      special = "<"
      todo = 0
    else
      if todo == 1 then
        todo = utf8len_tab[c:byte() + 1]
      end
      cur = cur .. c
      todo = todo - 1
      if todo == 0 then
        table.insert(keys, cur)
        cur = ""
        todo = 1
      end
    end
  end
  local ret = { keys = M.t(keystr), internal = {}, notation = {} }
  for i, key in pairs(keys) do
    if key == " " then
      key = "<space>"
    end
    if i == 1 and vim.g.mapleader and M.t(key) == M.t(vim.g.mapleader) then
      key = "<leader>"
    end
    table.insert(ret.internal, M.t(key))
    table.insert(ret.notation, key)
  end
  return ret
end

-- @return string[]
function M.parse_internal(keystr)
  local keys = {}
  local cur = ""
  local todo = 1
  local utf8 = false
  for i = 1, #keystr, 1 do
    local c = keystr:sub(i, i)
    if not utf8 then
      if todo == 1 and c == "\128" then
        -- K_SPECIAL: get 3 bytes
        todo = 3
      elseif cur == "\128" and c == "\252" then
        -- K_SPECIAL KS_MODIFIER: repeat after getting 3 bytes
        todo = todo + 1
      elseif todo == 1 then
        -- When the second byte of a K_SPECIAL sequence is not KS_MODIFIER,
        -- the third byte is guaranteed to be between 0x02 and 0x7f.
        todo = utf8len_tab[c:byte() + 1]
        utf8 = todo > 1
      end
    end
    cur = cur .. c
    todo = todo - 1
    if todo == 0 then
      table.insert(keys, cur)
      cur = ""
      todo = 1
      utf8 = false
    end
  end
  return keys
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "WhichKey" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "WhichKey" })
end

local function lookup(...)
  local ret = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      ret[v] = v
    end
  end
  return ret
end

local mapargs = {
  "noremap",
  "desc",
  "expr",
  "silent",
  "nowait",
  "script",
  "unique",
  "callback",
  "replace_keycodes", -- TODO: add config setting for default value
}
local wkargs = {
  "prefix",
  "mode",
  "plugin",
  "buffer",
  "remap",
  "cmd",
  "name",
  "group",
  "preset",
  "cond",
}
local transargs = lookup({
  "noremap",
  "expr",
  "silent",
  "nowait",
  "script",
  "unique",
  "prefix",
  "mode",
  "buffer",
  "preset",
  "replace_keycodes",
})
local args = lookup(mapargs, wkargs)

function M.child_opts(opts)
  local ret = {}
  for k, v in pairs(opts) do
    if transargs[k] then
      ret[k] = v
    end
  end
  return ret
end

function M._process(value, opts)
  local list = {}
  local children = {}
  for k, v in pairs(value) do
    if type(k) == "number" then
      if type(v) == "table" then
        -- nested child, without key
        table.insert(children, v)
      else
        -- list value
        table.insert(list, v)
      end
    elseif args[k] then
      -- option
      opts[k] = v
    else
      -- nested child, with key
      children[k] = v
    end
  end
  return list, children
end

function M._parse(value, mappings, opts)
  if type(value) ~= "table" then
    value = { value }
  end

  local list, children = M._process(value, opts)

  if opts.plugin then
    opts.group = true
  end
  if opts.name then
    -- remove + from group names
    opts.name = opts.name and opts.name:gsub("^%+", "")
    opts.group = true
  end

  -- fix remap
  if opts.remap then
    opts.noremap = not opts.remap
    opts.remap = nil
  end

  -- fix buffer
  if opts.buffer == 0 then
    opts.buffer = vim.api.nvim_get_current_buf()
  end

  if opts.cond ~= nil then
    if type(opts.cond) == "function" then
      if not opts.cond() then
        return
      end
    elseif not opts.cond then
      return
    end
  end

  -- process any array child mappings
  for k, v in pairs(children) do
    local o = M.child_opts(opts)
    if type(k) == "string" then
      o.prefix = (o.prefix or "") .. k
    end
    M._try_parse(v, mappings, o)
  end

  -- { desc }
  if #list == 1 then
    assert(type(list[1]) == "string", "Invalid mapping for " .. vim.inspect({ value = value, opts = opts }))
    opts.desc = list[1]
    -- { cmd, desc }
  elseif #list == 2 then
    -- desc
    assert(type(list[2]) == "string")
    opts.desc = list[2]

    -- cmd
    if type(list[1]) == "string" then
      opts.cmd = list[1]
    elseif type(list[1]) == "function" then
      opts.cmd = ""
      opts.callback = list[1]
    else
      error("Incorrect mapping " .. vim.inspect(list))
    end
  elseif #list > 2 then
    error("Incorrect mapping " .. vim.inspect(list))
  end

  if opts.desc or opts.group then
    if type(opts.mode) == "table" then
      for _, mode in pairs(opts.mode) do
        local mode_opts = vim.deepcopy(opts)
        mode_opts.mode = mode
        table.insert(mappings, mode_opts)
      end
    else
      table.insert(mappings, opts)
    end
  end
end

---@return Mapping
function M.to_mapping(mapping)
  mapping.silent = mapping.silent ~= false
  mapping.noremap = mapping.noremap ~= false
  if mapping.cmd and mapping.cmd:lower():find("^<plug>") then
    mapping.noremap = false
  end

  mapping.buf = mapping.buffer
  mapping.buffer = nil

  mapping.mode = mapping.mode or "n"
  mapping.label = mapping.desc or mapping.name
  mapping.keys = M.parse_keys(mapping.prefix or "")

  local opts = {}
  for _, o in ipairs(mapargs) do
    opts[o] = mapping[o]
    mapping[o] = nil
  end

  if vim.fn.has("nvim-0.7.0") == 0 then
    opts.replace_keycodes = nil

    -- Neovim < 0.7.0 doesn't support descriptions
    opts.desc = nil

    -- use lua functions proxy for Neovim < 0.7.0
    if opts.callback then
      local functions = require("which-key.keys").functions
      table.insert(functions, opts.callback)
      if opts.expr then
        opts.cmd = string.format([[luaeval('require("which-key").execute(%d)')]], #functions)
      else
        opts.cmd = string.format([[<cmd>lua require("which-key").execute(%d)<cr>]], #functions)
      end
      opts.callback = nil
    end
  end

  mapping.opts = opts
  return mapping
end

function M._try_parse(value, mappings, opts)
  local ok, err = pcall(M._parse, value, mappings, opts)
  if not ok then
    M.error(err)
  end
end

---@return Mapping[]
function M.parse(mappings, opts)
  opts = opts or {}
  local ret = {}
  M._try_parse(mappings, ret, opts)
  return vim.tbl_map(function(m)
    return M.to_mapping(m)
  end, ret)
end

function M.map(mode, prefix_n, cmd, buf, opts)
  local other = vim.api.nvim_buf_call(buf or 0, function()
    local ret = vim.fn.maparg(prefix_n, mode, false, true)
    ---@diagnostic disable-next-line: undefined-field
    return (ret and ret.lhs and ret.rhs and ret.rhs ~= cmd) and ret or nil
  end)
  if other then
    table.insert(M.duplicates, { mode = mode, prefix = prefix_n, cmd = cmd, buf = buf, other = other })
  end
  if buf ~= nil then
    pcall(vim.api.nvim_buf_set_keymap, buf, mode, prefix_n, cmd, opts)
  else
    pcall(vim.api.nvim_set_keymap, mode, prefix_n, cmd, opts)
  end
end

---@class Tree
---@field root Node
local Tree = {}
Tree.__index = Tree

---@class Node
---@field mapping Mapping
---@field prefix_i string
---@field prefix_n string
---@field children table<string, Node>
-- selene: allow(unused_variable)
local Node

---@return Tree
function Tree:new()
  local this = { root = { children = {}, prefix_i = "", prefix_n = "" } }
  setmetatable(this, self)
  return this
end

---@param prefix_i string
---@param index? number defaults to last. If < 0, then offset from last
---@param plugin_context? any
---@return Node?
function Tree:get(prefix_i, index, plugin_context)
  local prefix = M.parse_internal(prefix_i)
  local node = self.root
  index = index or #prefix
  if index < 0 then
    index = #prefix + index
  end
  for i = 1, index, 1 do
    node = node.children[prefix[i]]
    if node and plugin_context and node.mapping and node.mapping.plugin then
      local children = require("which-key.plugins").invoke(node.mapping, plugin_context)
      node.children = {}
      for _, child in pairs(children) do
        self:add(child)
      end
    end
    if not node then
      return nil
    end
  end
  return node
end

-- Returns the path (possibly incomplete) for the prefix
---@param prefix_i string
---@return Node[]
function Tree:path(prefix_i)
  local prefix = M.parse_internal(prefix_i)
  local node = self.root
  local path = {}
  for i = 1, #prefix, 1 do
    node = node.children[prefix[i]]
    table.insert(path, node)
    if not node then
      break
    end
  end
  return path
end

---@param mapping Mapping
function Tree:add(mapping)
  local prefix_i = mapping.keys.internal
  local prefix_n = mapping.keys.notation
  local node = self.root
  local path_i = ""
  local path_n = ""
  for i = 1, #prefix_i, 1 do
    path_i = path_i .. prefix_i[i]
    path_n = path_n .. prefix_n[i]
    if not node.children[prefix_i[i]] then
      node.children[prefix_i[i]] = { children = {}, prefix_i = path_i, prefix_n = path_n }
    end
    node = node.children[prefix_i[i]]
  end
  node.mapping = vim.tbl_deep_extend("force", node.mapping or {}, mapping)
end

---@param cb fun(node:Node)
---@param node? Node
function Tree:walk(cb, node)
  node = node or self.root
  cb(node)
  for _, child in pairs(node.children) do
    self:walk(cb, child)
  end
end

function M.get_tree(mode, buf)
  if mode == "s" or mode == "x" then
    mode = "v"
  end
  M.check_mode(mode, buf)
  local idx = mode .. (buf or "")
  if not M.mappings[idx] then
    M.mappings[idx] = { mode = mode, buf = buf, tree = Tree:new() }
  end
  return M.mappings[idx]
end

function M.register(mappings, opts)
  opts = opts or {}

  mappings = M.parse(mappings, opts)

  -- always create the root node for the mode, even if there's no mappings,
  -- to ensure we have at least a trigger hooked for non documented keymaps
  local modes = {}

  for _, mapping in pairs(mappings) do
    if not modes[mapping.mode] then
      modes[mapping.mode] = true
      M.get_tree(mapping.mode)
    end
    if mapping.cmd ~= nil then
      M.map(mapping.mode, mapping.prefix, mapping.cmd, mapping.buf, mapping.opts)
    end
    M.get_tree(mapping.mode, mapping.buf).tree:add(mapping)
  end
end

return M
