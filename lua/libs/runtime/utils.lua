local M = {}

M.root_patterns = { '.git', '_darcs', '.bzr', '.svn', '.vscode', '.gitmodules', 'pnpm-workspace.yaml', 'Cargo.toml' }
M.root_lsp_ignore = { 'null-ls', 'tailwindcss' }

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

M.log = function(message, title) require('notify')(message, 'info', { title = title or 'Info' }) end

M.warnlog = function(message, title) require('notify')(message, 'warn', { title = title or 'Warning' }) end

M.errorlog = function(message, title) require('notify')(message, 'error', { title = title or 'Error' }) end

M.jobstart = function(cmd, on_finish)
  local has_error = false
  local lines = {}

  local function on_event(_, data, event)
    if event == 'stdout' then
      data = M.handle_job_data(data)
      if not data then return end

      for i = 1, #data do
        table.insert(lines, data[i])
      end
    elseif event == 'stderr' then
      data = M.handle_job_data(data)
      if not data then return end

      has_error = true
      local error_message = ''
      for _, line in ipairs(data) do
        error_message = error_message .. line
      end
      M.log('Error during running a job: ' .. error_message)
    elseif event == 'exit' then
      if not has_error then on_finish(lines) end
    end
  end

  vim.fn.jobstart(cmd, {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

M.remove_whitespaces = function(string) return string:gsub('%s+', '') end

M.add_whitespaces = function(number) return string.rep(' ', number) end

-- has_plugin("noice.nvim")
M.has_plugin = function(plugin_name_string) return require('lazy.core.config').plugins[plugin_name_string] ~= nil end

M.pkg_loaded = function(mod_path)
  return package.loaded[mod_path] ~= nil
end

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
---@param root_opts? {root_patterns?:table,lsp_ignore?:table}
---@return string
function M.get_root(root_opts)
  root_opts = vim.tbl_extend('force', {
    root_patterns = M.root_patterns,
    lsp_ignore = M.root_lsp_ignore,
  }, root_opts or {})
  local rootPatterns = root_opts.root_patterns
  local lsp_ignore = root_opts.lsp_ignore or {}
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      if not vim.tbl_contains(lsp_ignore, client.name or "") then
        local workspace = client.config.workspace_folders
        local paths = workspace and vim.tbl_map(function(ws)
          return vim.uri_to_fname(ws.uri)
        end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
        for _, p in ipairs(paths) do
          local r = vim.loop.fs_realpath(p)
          if path:find(r, 1, true) then
            roots[#roots + 1] = r
          end
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(rootPatterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

M.use_plugin = function(plugin_name, callback)
  local ok, plugin = require(plugin_name)
  if not ok then
    M.log('Error loading plugin: ' .. plugin_name)
    return
  end
  callback(plugin)
end
---@usage load_plugins({'dression.nvim'})
M.load_plugins = function(plugins)
  if type(plugins) ~= 'table' then
    plugins = { plugins }
  end
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
    vim.schedule(function()
      cb(_unpack(args))
    end)
  end
end

---@see LazyVim
---@param opts? string|{msg:string, on_error:fun(msg)}
function M.try(fn, opts)
  opts = type(opts) == 'string' and { msg = opts } or opts or {}
  local msg = opts.msg
  -- error handler
  local error_handler = function(err)
    local trace = {}
    local level = 1
    while true do
      local info = debug.getinfo(level, 'Sln')
      if not info then break end
      if info.what ~= 'C' and not info.source:find('lazy.nvim') then
        local source = info.source:sub(2)
        source = vim.fn.fnamemodify(source, ':p:~:.')
        local line = '  - ' .. source .. ':' .. info.currentline
        if info.name then line = line .. ' _in_ **' .. info.name .. '**' end
        table.insert(trace, line)
      end
      level = level + 1
    end
    msg = (msg and (msg .. '\n\n') or '') .. err
    if #trace > 0 then msg = msg .. '\n\n# stacktrace:\n' .. table.concat(trace, '\n') end
    if opts.on_error then
      opts.on_error(msg)
    else
      vim.schedule(function() M.errorlog(msg) end)
    end
    return err
  end

  ---@type boolean, any
  local ok, result = xpcall(fn, error_handler)
  return ok and result or nil
end

---Parse the `style` string into nvim_set_hl options
---@param style string @The style config
---@return table
local function parse_style(style)
  if not style or style == "NONE" then
    return {}
  end

  local result = {}
  for field in string.gmatch(style, "([^,]+)") do
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
    link = true
  })
  if hl.link then
    return get_highlight(hl.link)
  end

  local result = parse_style(hl.style)
  result.fg = hl.foreground and string.format("#%06x", hl.foreground)
  result.bg = hl.background and string.format("#%06x", hl.background)
  result.sp = hl.special and string.format("#%06x", hl.special)
  for attr, val in pairs(hl) do
    if type(attr) == "string" and attr ~= "foreground" and attr ~= "background" and attr ~= "special" then
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
  return fg and { fg = string.format("#%06x", fg) }
end

---@see https://github.com/justchokingaround/nvim/blob/a11aae6d66d025627d7f52f705cbe5951f2f6eb6/lua/modules/utils/init.lua
---Extend a highlight group
---@param name string @Target highlight group name
---@param def table @Attributes to be extended
function M.extend_hl(name, def, ns)
  local hlexists = pcall(vim.api.nvim_get_hl, ns or 0, {
    name = name,
    link = true,
  })
  if not hlexists then
    -- Do nothing if highlight group not found
    return
  end
  local current_def = get_highlight(name)
  local combined_def = vim.tbl_deep_extend("force", current_def, def)
  -- print(vim.inspect(combined_def))

  vim.api.nvim_set_hl(ns or 0, name, combined_def)
end

M.vim_starts_without_buffer = function()
  return vim.fn.argc(-1) == 0
end

return M
