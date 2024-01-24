-- credits:
-- * https://github.com/LunarVim/LunarVim/blob/master/lua/lvim/lsp/manager.lua
--
local au = require('userlib.runtime.au')

--- handle multiple files being added in short time.

local M = {}
--- FileType being called twice.
local bufcache = {}

local server_configurations_done = {}
local CustomServerSetup = {
  ['null-ls'] = function()
    require('userlib.lsp.servers.null_ls').setup()
  end,
}

function M.get_supported_filetypes(server_name)
  local status_ok, config = pcall(require, ('lspconfig.server_configurations.%s'):format(server_name))
  if not status_ok then
    return {}
  end

  return config.default_config.filetypes or {}
end

---@param name string
---@param bufnr? number
function M.is_client_active(name, bufnr)
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    name = name,
  })
  return #clients > 0
end

---@param filetype string
---@param opts? { bufnr? number, name? string, ignores? table }
function M.get_active_clients_by_ft(filetype, opts)
  opts = opts or {}
  local ignores = { 'null-ls' }
  if type(opts.ignores) == 'table' then
    ignores = opts.ignores
  end

  local matches = {}
  local clients = vim.lsp.get_clients({
    bufnr = opts.bufnr,
    name = opts.name,
  })

  for _, client in pairs(clients) do
    local supported_filetypes = client.config.filetypes or {}
    if not vim.tbl_contains(ignores, client.name) and vim.tbl_contains(supported_filetypes, filetype) then
      table.insert(matches, client)
    end
  end
  return matches
end

function M.buf_try_add_lspconfig(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lspconfig_for_server = require('lspconfig')[server_name]
  if not lspconfig_for_server then
    vim.notify(string.format("_%s_ doesn't have lspconfig configuration", server_name), vim.log.levels.ERROR)
    return
  end
  if not lspconfig_for_server.manager then
    -- vim.notify(string.format('_%s_ not installed', server_name), vim.log.levels.ERROR)
    return
  end
  lspconfig_for_server.manager:try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
function M.client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.api.nvim_get_autocmds({ event = 'FileType', pattern = ft })
  for _, result in ipairs(active_autocmds) do
    if result.desc ~= nil and result.desc:match('server ' .. server_name .. ' ') then
      return true
    end
  end
  return false
end

function M.setup_server(server_name, config_tbl_or_func)
  local config = {}
  if type(config_tbl_or_func) == 'function' then
    config = config_tbl_or_func({})
  else
    config = config_tbl_or_func
  end
  local is_autostart = false
  if config.autostart == true then
    is_autostart = true
  end
  local _, error = pcall(function()
    if not server_configurations_done[server_name] or is_autostart == true then
      local command = config.cmd
        or (function()
          local ok, cfg_in_lspconfig = pcall(require, 'lspconfig.server_configurations.' .. server_name)
          if ok then
            return cfg_in_lspconfig.default_config.cmd
          end
          return nil
        end)()
      -- some servers have dynamic commands defined with on_new_config
      if type(command) == 'table' and type(command[1]) == 'string' and vim.fn.executable(command[1]) ~= 1 then
        vim.notify('LSP server ' .. server_name .. ' is not installed', vim.log.levels.ERROR)
        return
      end

      config.autostart = is_autostart
      require('lspconfig')[server_name].setup(config)
      server_configurations_done[server_name] = true
    end
  end)
  if error then
    vim.notify(error, vim.log.levels.ERROR)
  end
end

function M.launch_server_on_buf(server_name, config, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.b[bufnr].lsp_disable then
    return
  end

  config = config or {}
  M.setup_server(server_name, config)
  M.buf_try_add_lspconfig(server_name, bufnr)
end

function M.toggle_buf_lsp(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if M.is_client_active(server_name, bufnr) then
    vim.lsp.stop_client(vim.lsp.get_client_by_id(
      vim.lsp.get_clients({
        bufnr = bufnr,
        name = server_name,
      }),
      true
    ))
    return 0
  else
    M.buf_try_add_lspconfig(server_name, bufnr)
    return 1
  end
end

local function current_buf_matches_filetypes(bufnr, filetypes)
  if not bufnr then
    return false
  end
  local buf_filetype = vim.api.nvim_get_option_value('filetype', {
    buf = bufnr,
  })
  if not buf_filetype or buf_filetype == '' then
    return false
  end
  return vim.tbl_contains(filetypes, buf_filetype)
end

local function setup_lspconfig_servers(servers, bufnr)
  local lspcfg = require('userlib.lsp.cfg')
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  for _, server_name in ipairs(servers) do
    if CustomServerSetup[server_name] then
      CustomServerSetup[server_name](bufnr)
    else
      if not M.is_client_active(server_name, bufnr) then
        M.launch_server_on_buf(server_name, lspcfg.get_config_for_server(server_name), bufnr)
      end
    end
  end
end

local function setup_lspconfig_servers_lazy_without_block_neovim(servers, bufnr)
  vim.defer_fn(function()
    setup_lspconfig_servers(servers, bufnr)
  end, 1)
end

local function setup_lspconfig_servers_once(filetypes, servers)
  local bufnr = vim.api.nvim_get_current_buf()
  if current_buf_matches_filetypes(bufnr, filetypes) then
    setup_lspconfig_servers(servers, bufnr)
  end
  local bufcount = #vim.api.nvim_list_bufs()

  --- TODO: handle rename.
  if #filetypes > 0 then
    au.define_autocmd('FileType', {
      group = 'lspconfig_filetype',
      pattern = filetypes,
      callback = function(ctx)
        local buf = ctx.buf
        if bufcache[buf] then
          return
        end
        bufcache[buf] = true

        --- invalid the cache on buf unload
        au.define_autocmd('BufUnload', {
          group = 'invalid_buf_cache',
          buffer = buf,
          callback = function()
            bufcache[buf] = false
          end,
        })

        vim.schedule(function()
          if vim.api.nvim_get_current_buf() == buf then
            setup_lspconfig_servers(servers, buf)
            return
          end
          local bufcount_now = #vim.api.nvim_list_bufs()
          if bufcount_now - bufcount < 10 then
            setup_lspconfig_servers(servers, buf)
          else
            setup_lspconfig_servers_lazy_without_block_neovim(servers, buf)
          end
        end)
      end,
    })
  end
end

function M.setup()
  local cfg = require('userlib.filetypes.config')
  for filetype, filetype_config in pairs(cfg) do
    -- if filetype is like less>css, it means less filetype extends cfg[css] or {}, css is base filetype.
    -- split child filetype and base filetype.
    if filetype:match('>') then
      local child_filetype, base_filetype = unpack(vim.split(filetype, '>'))
      filetype_config = vim.tbl_extend('keep', filetype_config, cfg[base_filetype] or {})
      filetype = child_filetype
    end
    if type(filetype_config.lspconfig) == 'table' then
      local filetypes = filetype_config.filetypes or { filetype }
      local servers = filetype_config.lspconfig

      setup_lspconfig_servers_once(filetypes, servers)
    end
  end

  require('userlib.lsp.fswatch').setup()
end

return M
