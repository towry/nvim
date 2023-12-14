local M = {}

M.root_patterns =
{ '_darcs', '.bzr', '.vscode', 'package.json', 'pnpm-workspace.yaml', 'Cargo.toml', '.git', '.gitmodules', '.svn' }
--- ignore jsonls: inside package.json, it give root to parent root.
M.root_lsp_ignore = { 'tailwindcss', 'jsonls', 'copilot', 'null-ls', 'eslint' }

M.file_exists = function(path)
  local f = io.open(path, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

M.get_relative_fname = function()
  local fname = vim.fn.expand('%:p')
  return fname:gsub(vim.fn.getcwd() .. '/', '')
end

M.get_relative_gitpath = function()
  local fpath = vim.fn.expand('%:h')
  local fname = vim.fn.expand('%:t')
  local gitpath = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  local relative_gitpath = fpath:gsub(gitpath, '') .. '/' .. fname

  return relative_gitpath
end

M.sleep = function(n) os.execute('sleep ' .. tonumber(n)) end

M.toggle_quicklist = function()
  if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix')) == 1 then
    if not vim.o.modifiable then return end
    vim.cmd('copen')
  else
    vim.cmd('cclose')
  end
end

M.starts_with = function(str, start) return str:sub(1, #start) == start end

M.end_with = function(str, ending) return ending == '' or str:sub(- #ending) == ending end

M.split = function(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
    table.insert(result, match)
  end

  return result
end

M.handle_job_data = function(data)
  if not data then return nil end
  if data[#data] == '' then table.remove(data, #data) end
  if #data < 1 then return nil end
  return data
end

M.log = function(message, title) vim.notify(message, vim.log.levels.INFO, { title = title or 'Info' }) end

M.warnlog = function(message, title) vim.notify(message, vim.log.levels.WARN, { title = title or 'Warning' }) end

M.errorlog = function(message, title) vim.notify(message, vim.log.levels.ERROR, { title = title or 'Error' }) end

M.remove_whitespaces = function(string) return string:gsub('%s+', '') end

M.add_whitespaces = function(number) return string.rep(' ', number) end

-- has_plugin("noice.nvim")
M.has_plugin = function(plugin_name_string) return require('lazy.core.config').plugins[plugin_name_string] ~= nil end

M.pkg_loaded = function(mod_path) return package.loaded[mod_path] ~= nil end

function M.normname(name)
  local ret = name:lower():gsub('^n?vim%-', ''):gsub('%.n?vim$', ''):gsub('%.lua', ''):gsub('[^a-z]+', '')
  return ret
end

-- taken from lazyvim.
-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@param root_opts? {root_patterns?:table,lsp_ignore?:table,only_pattern?:boolean,pattern_start_path?:string}
---@return string
function M.get_root(root_opts)
  local has_root_patterns_opt = root_opts and root_opts.root_patterns ~= nil
  root_opts = vim.tbl_extend('force', {
    root_patterns = M.root_patterns,
    lsp_ignore = M.root_lsp_ignore,
  }, root_opts or {})
  local only_pattern = root_opts.only_pattern
  if not (has_root_patterns_opt or only_pattern) and M.has_plugin('project_nvim') then
    local is_ok, project_nvim = pcall(require, 'project_nvim.project')
    if is_ok then
      local project_root, _ = project_nvim.get_project_root()
      if project_root ~= nil then return project_root end
    end
  end

  local rootPatterns = root_opts.root_patterns
  local lsp_ignore = root_opts.lsp_ignore or {}
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= '' and vim.uv.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path and not only_pattern then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      if not vim.tbl_contains(lsp_ignore, client.name or '') then
        local workspace = client.config.workspace_folders
        local paths = workspace and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
            or client.config.root_dir and { client.config.root_dir }
            or {}
        for _, p in ipairs(paths) do
          local r = vim.uv.fs_realpath(p)
          if path:find(r, 1, true) then roots[#roots + 1] = r end
        end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = root_opts.pattern_start_path or (path and vim.fs.dirname(path)) or vim.uv.cwd()
    ---@type string?
    root = vim.fs.find(rootPatterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.uv.cwd()
  end
  if root == vim.uv.os_homedir() then return vim.uv.cwd() end
  ---@cast root string
  return root
end

M.use_plugin = function(plugin_name, callback, on_fail)
  if not callback then return end
  local ok, plugin = pcall(require, plugin_name)
  if not ok then
    if on_fail then
      on_fail()
      return
    end
    M.log('Error loading plugin: ' .. plugin_name)
    return false
  end
  callback(plugin)
end

---@usage load_plugins({'dression.nvim'})
M.load_plugins = function(plugins)
  if type(plugins) ~= 'table' then plugins = { plugins } end
  require('lazy').load({ plugins = plugins })
end

---Safely call plugin.
---@param plugins table|string
---@param cb function
M.plugin_schedule = function(plugins, cb)
  M.load_plugins(plugins)
  vim.schedule(cb)
end

---Wrap a callback with plugins.
---@param plugins table|string
---@param cb function
---@return function
M.plugin_schedule_wrap = function(plugins, cb)
  return function(...)
    local args = ...
    if type(cb) ~= 'function' then return end
    M.load_plugins(plugins)
    vim.schedule(function() cb(unpack(args)) end)
  end
end

---Parse the `style` string into nvim_set_hl options
---@param style string @The style config
---@return table
local function parse_style(style)
  if not style or style == 'NONE' then return {} end

  local result = {}
  for field in string.gmatch(style, '([^,]+)') do
    result[field] = true
  end

  return result
end

---Wrapper function for nvim_get_hl_by_name
---@param hl_group string @Highlight group name
---@return table
local function get_highlight(hl_group)
  local hl = vim.api.nvim_get_hl(0, {
    name = hl_group,
    link = true,
  })
  if hl.link then return get_highlight(hl.link) end

  local result = parse_style(hl.style)
  result.fg = hl.foreground and string.format('#%06x', hl.foreground)
  result.bg = hl.background and string.format('#%06x', hl.background)
  result.sp = hl.special and string.format('#%06x', hl.special)
  for attr, val in pairs(hl) do
    if type(attr) == 'string' and attr ~= 'foreground' and attr ~= 'background' and attr ~= 'special' then
      result[attr] = val
    end
  end

  return result
end

--- taken from LazyVim
function M.fg(name)
  ---@type {foreground?:number}?
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format('#%06x', fg) }
end

function M.bg(name)
  ---@type {foreground?:number}?
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  local bg = hl and hl.bg or hl.background
  return bg and { bg = string.format('#%06x', bg) }
end

---@see https://github.com/justchokingaround/nvim/blob/a11aae6d66d025627d7f52f705cbe5951f2f6eb6/lua/modules/utils/init.lua
---Extend a highlight group
---@param name string|string[] @Target highlight group name
---@param def table @Attributes to be extended
function M.extend_hl(name, def, ns)
  ---@type string
  local base_name = name
  if type(name) == 'table' then
    base_name = name[2] or name[1]
    name = name[1]
  end

  local hlexists = pcall(vim.api.nvim_get_hl, ns or 0, {
    name = base_name,
    link = true,
  })
  if not hlexists then
    -- Do nothing if highlight group not found
    return
  end
  local current_def = get_highlight(base_name)
  local combined_def = vim.tbl_deep_extend('force', current_def, def)
  -- print(vim.inspect(combined_def))

  vim.api.nvim_set_hl(ns or 0, name, combined_def)
end

M.vim_starts_without_buffer = function() return vim.fn.argc(-1) == 0 end

function M.change_cwd(cwd, cmd, silent)
  if not cwd then return end
  cwd = require('userlib.runtime.path').remove_path_last_separator(cwd)
  vim.cmd((cmd or 'cd') .. ' ' .. cwd)
  M.update_cwd_env(cwd)
  if not silent then vim.notify(('New cwd: %s'):format(vim.t.cwd_short), vim.log.levels.INFO) end
end

---@param cwd string
---@param cwd_short? string
function M.update_cwd_env(cwd, cwd_short)
  cwd = require('userlib.runtime.path').remove_path_last_separator(cwd)
  vim.t.cwd = cwd
  -- only show last part of path.
  vim.t.cwd_short = cwd_short or require('userlib.runtime.path').home_to_tilde(cwd, { shorten = true })
  return cwd, vim.t.cwd_short
end

---- UTF-8
-- Convert a number to a utf8 string
M.utf8 = function(decimal)
  if type(decimal) == 'string' then decimal = vim.fn.char2nr(decimal) end
  if decimal < 128 then return string.char(decimal) end
  local charbytes = {}
  for bytes, vals in ipairs({ { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }) do
    if decimal <= vals[1] then
      for b = bytes + 1, 2, -1 do
        local mod = decimal % 64
        decimal = (decimal - mod) / 64
        charbytes[b] = string.char(128 + mod)
      end
      charbytes[1] = string.char(vals[2] + decimal)
      break
    end
  end
  return table.concat(charbytes)
end

-- For each { k = v } in keys, return a table that when indexed by any k' such
-- that tolower(k') == tolower(k) returns utf8(v)
M.utf8keys = function(keys, disable)
  local _keys = {}
  for k, v in pairs(keys) do
    _keys[string.lower(k)] = disable and k or M.utf8(v)
  end
  return setmetatable(_keys, {
    __index = function(self, k) return rawget(self, string.lower(k)) end,
    __call = function(self, k) return self[k] end,
  })
end

M.is_start_as_git_tool = function()
  if vim.fn.argc(-1) == 0 then return false end
  local argv = vim.v.argv
  local args = { { '-d' }, { '-c', 'DiffConflicts' }, }
  -- each table in args is pairs of args that may exists in argv to determin the
  -- return value is true or false.
  for _, arg in ipairs(args) do
    local is_match = true
    for _, v in ipairs(arg) do
      if not vim.tbl_contains(argv, v) then is_match = false end
    end
    if is_match then return true end
  end

  argv = { vim.fn.expand('%:t') }
  args = { "MERGE_MSG", "COMMIT_EDITMSG" }
  for _, arg in ipairs(args) do
    local is_match = true
    if not vim.tbl_contains(argv, arg) then is_match = false end
    if is_match then return true end
  end

  return false
end

M.get_range = function()
  if vim.fn.mode() == "n" then
    local pos = vim.api.nvim_win_get_cursor(0)
    return {
      pos[1],
      pos[1],
    }
  end

  return {
    vim.fn.getpos("v")[2],
    vim.fn.getpos(".")[2],
  }
end

return M
