-- entry and main helpers of our autocmds.
local M = {
  EVENTS = {
    on_git_blame_done = 'OnGitBlameDone',
  },
  --- execute autocmds.
  exec = vim.api.nvim_exec_autocmds,
}

function M.augroup(name) return vim.api.nvim_create_augroup('ty_au_' .. name, { clear = true }) end

function M.augroup_get(name) return vim.api.nvim_create_augroup('ty_au_' .. name, { clear = false }) end

---@usage require('ty.core.autocmd').with_group("editing_pkg"):create("BufRead", { pattern = node_modules_pattern, command = 'lua vim.diagnostic.disable(0)' })
function M.with_group(name)
  ---@class AutoCmd
  ---@field group number|string
  ---@field create fun(events: string, opts1?: string|table, opts2?: table): AutoCmd
  local o = {}
  o.group = M.augroup(name)
  setmetatable(o, {
    __index = function(_, k)
      if k == 'with_group' then return nil end
      return M[k]
    end,
  })
  return o
end

function M:create(events, opts)
  if self == nil then error('invalid usage of autocmd:create, use autocmd.with_group("name"):create(...)') end
  opts = opts or {}
  opts.group = self.group
  vim.api.nvim_create_autocmd(events, opts)
  return self
end

---@param on_attach fun(client, buffer, args)
---@param group? string|number
function M.on_attach(on_attach, group)
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer, args)
    end,
  })
end

function M.on_very_lazy(callback)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function() callback() end,
  })
end

--- must use before lazy setup.
function M.on_lazy_done(callback)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyDone',
    callback = function() callback() end,
  })
end

return M
