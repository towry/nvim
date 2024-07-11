--- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/globals.lua

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts table?
local function nvim_command(name, rhs, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, rhs, opts)
end

---@private
local _autocmd_keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to as.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = vim.iter(command):map(function(key, _)
    if not vim.tbl_contains(_autocmd_keys, key) then
      return key
    end
  end)
  if #incorrect > 0 then
    vim.schedule(function()
      local msg = ('Incorrect keys: %s'):format(table.concat(incorrect, ', '))
      vim.notify(msg, vim.log.levels.ERROR, { title = ('Autocmd: %s'):format(name) })
    end)
  end
end

---@class AutocmdArgs
---@field id number autocmd ID
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string?
---@field event  (string | string[])? list of autocommand events
---@field pattern (string | string[])? list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
local function nvim_augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(#commands > 0, string.format('You must specify at least one autocommand for %s', name))
  local id = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      ---@diagnostic disable-next-line: assign-type-mismatch
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

local git_is_perform_merge_in_nvim = function()
  if vim.g.nvim_is_start_as_merge_tool == 1 then
    return true
  end
  local tail = vim.fn.expand('%:t')
  local args = { 'MERGE_MSG', 'COMMIT_EDITMSG' }
  if vim.tbl_contains(args, tail) then
    vim.g.nvim_is_start_as_merge_tool = 1
    return true
  end
  return false
end
local git_is_using_nvim_as_tool = function()
  if vim.fn.argc(-1) == 0 then
    return false
  end
  local argv = vim.v.argv
  local args = { { '-d' }, { '-c', 'DiffConflicts' } }
  -- each table in args is pairs of args that may exists in argv to determin the
  -- return value is true or false.
  for _, arg in ipairs(args) do
    local is_match = true
    for _, v in ipairs(arg) do
      if not vim.tbl_contains(argv, v) then
        is_match = false
      end
    end
    if is_match then
      return true
    end
  end

  return git_is_perform_merge_in_nvim()
end

local function register_global(name, value)
  _G[name] = value
end

local function buffer_is_empty(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = bufnr,
  })
  if buftype == 'nofile' then
    return true
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  return filename == ''
end

--- Get the window in current tab that showing this buffer.
--- @param bufnr number
local function buffer_get_tabwin(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

--- Set multiple options on a buffer
--- @param buf number
--- @param opts {[string]: any}
local function buffer_set_options(buf, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_set_option_value(k, v, {
      buf = buf,
    })
  end
end
--- Focus the buffer or set it as current buffer.
--- @param bufnr number
--- @param tabonly boolean Only check windows in current tab.
local function buffer_focus_or_current(bufnr, tabonly)
  if tabonly == nil then
    tabonly = true
  end

  if not tabonly then
    local buf_win_id = unpack(vim.fn.win_findbuf(bufnr))
    if buf_win_id ~= nil then
      vim.api.nvim_set_current_win(buf_win_id)
      return
    end
  else
    local w = buffer_get_tabwin(bufnr)
    if w then
      vim.api.nvim_set_current_win(w)
    end
  end

  vim.api.nvim_set_current_buf(bufnr)
end

--- Retrieve the focusable alternative buffer.
--- @return number|nil
local function buffer_alt_focusable_bufnr()
  local altnr = vim.fn.bufnr('#')
  if not altnr or altnr < 1 then
    return
  end
  -- if the buffer keep delete by other plugin wrongly, this will be a problem.
  -- plugin must be fixed.
  if not vim.api.nvim_buf_is_loaded(altnr) then
    -- buf is deleted but not wipped out
    return
  end
  if not altnr then
    return
  end
  return altnr
end

return {
  register_global = register_global,
  nvim_command = nvim_command,
  nvim_augroup = nvim_augroup,
  git_is_using_nvim_as_tool = git_is_using_nvim_as_tool,
  buffer_is_empty = buffer_is_empty,
  buffer_set_options = buffer_set_options,
  buffer_focus_or_current = buffer_focus_or_current,
  buffer_alt_focusable_bufnr = buffer_alt_focusable_bufnr,
}
