local M = {}

---@type {[string]:{ count:number, callbacks:{[string]:function}, args: table?}}
local events_registry = {}

M.events = {
  AfterColorschemeChanged = "AfterColorschemeChanged",
  onGitsignsAttach = "onGitsignsAttach",
  onGitDiffviewOpen = "onGitDiffviewOpen",
  onGitDiffviewBufRead = "onGitDiffviewBufRead",
  -- close all buffers except current one.
  doBufferCloseAllButCurrent = "doBufferCloseAllButCurrent",
  onLspAttach = "onLspAttach",
}
M.user_autocmds = setmetatable({
  -- File is opened.
  FileOpened = "FileOpened",
  -- Wait few moments after file is opened.
  FileOpenedAfter = "FileOpenedAfter",
  LspConfigDone = "LspConfigDone",
  TermIsOpen = "TermIsOpen",
  TelescopeConfigDone = "TelescopeConfigDone",
  on_git_blame_done = "on_git_blame_done",
}, {
  __index = function(_, key)
    -- if key suffix with '_User' then return 'User_' .. <real key>.
    if string.match(key, '_User$') then
      return 'User ' .. string.sub(key, 1, -6)
    else
      error("key " .. key .. " not found in user_autocmds.")
    end
  end
})

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds { group = name }
    end)
  end)
end

---@param name string `User <name>`
function M.do_useraucmd(name)
  vim.cmd("do " .. name)
end

--- do user autocmds
---@param name string the autocmd pattern name
---@param opts? {modeline?:boolean,data?:table} the autocmd options
function M.exec_useraucmd(name, opts)
  vim.api.nvim_exec_autocmds('User', vim.tbl_extend('force', {
    pattern = name,
    modeline = false,
    data = {
      bufnr = vim.api.nvim_get_current_buf(),
    }
  }, opts or {}))
end

--- Create autocommand groups based on the passed definitions
--- Also creates the augroup automatically if it doesn't exist
---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
  for _, entry in ipairs(definitions) do
    local event = entry[1]
    local opts = entry[2]
    if type(opts.group) == "string" and opts.group ~= "" then
      local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
      if not exists then
        vim.api.nvim_create_augroup(opts.group, {})
      end
    end
    vim.api.nvim_create_autocmd(event, opts)
  end
end

---@param callback function(client:any, bufnr:number)
function M.on_lsp_attach(callback)
  M.define_autocmds({
    {
      'LspAttach',
      {
        group = '_lsp_attach',
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          callback(client, bufnr)
        end,
      }
    }
  })
end

---@param args table see `:h nvim_get_autocmds`
function M.has_autocmds(args)
  return pcall(vim.api.nvim_get_autocmds, args)
end

--- Add event to be fired.
---@param event_name string: The event name.
---@param opts {name:string, callback:function, immediate?:boolean}: required options
function M.register_event(event_name, opts)
  vim.validate({
    opts = { opts, "table" },
  })
  events_registry[event_name] = events_registry[event_name] or {
    count = 0,
    callbacks = {}
  }

  events_registry[event_name].callbacks[opts.name] = opts.callback
  -- fire immediately
  if opts.immediate ~= nil and opts.immediate == false and events_registry[event_name].count > 0 then
    opts.callback(events_registry[event_name].args)
  end
end

--- Remove event.
---@param event_name string
---@param handler_name string
function M.remove_event(event_name, handler_name)
  if not events_registry[event_name] then
    return
  end
  events_registry[event_name].callbacks[handler_name] = nil
end

--- Fire an event.
---@param event_name string
---@param args table?
function M.fire_event(event_name, args)
  if not events_registry[event_name] then
    events_registry[event_name] = {
      count = 1,
      callbacks = {},
      args = args
    }
    return
  end
  events_registry[event_name].args = args
  local callbacks = events_registry[event_name].callbacks or {}
  -- loop through callbacks {[string]: function} and call the function.
  for _, callback in pairs(callbacks) do
    callback(args)
  end
end

return M
