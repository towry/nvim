local M = {}

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

M.end_with = function(str, ending) return ending == '' or str:sub(-#ending) == ending end

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

function M.normname(name)
  local ret = name:lower():gsub('^n?vim%-', ''):gsub('%.n?vim$', ''):gsub('%.lua', ''):gsub('[^a-z]+', '')
  return ret
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@see https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= '' and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then roots[#roots + 1] = r end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
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

return M
