-- credits:
-- * https://github.com/LunarVim/LunarVim/blob/master/lua/lvim/lsp/manager.lua
--
local au = require('userlib.runtime.au')

local M = {}

local server_configurations_done = {}
local CustomServerSetup = {
  ['null-ls'] = function()
    require('userlib.lsp.servers.null_ls').setup()
  end
}

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
  require('lspconfig')[server_name].manager:try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
function M.client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.api.nvim_get_autocmds { event = "FileType", pattern = ft }
  for _, result in ipairs(active_autocmds) do
    if result.desc ~= nil and result.desc:match("server " .. server_name .. " ") then
      return true
    end
  end
  return false
end

function M.setup_server(server_name, config)
  config = config or {}
  local is_autostart = false
  if config.autostart == true then
    is_autostart = true
  end
  pcall(function()
    if not server_configurations_done[server_name] or is_autostart == true then
      local command = config.cmd
          or (function()
            local default_config = require("lspconfig.server_configurations." .. server_name).default_config
            return default_config.cmd
          end)()
      -- some servers have dynamic commands defined with on_new_config
      if type(command) == "table" and type(command[1]) == "string" and vim.fn.executable(command[1]) ~= 1 then
        return
      end

      config.autostart = is_autostart
      require("lspconfig")[server_name].setup(config)
      server_configurations_done[server_name] = true
    end
  end)
end

function M.launch_server_on_buf(server_name, config, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  config = config or {}
  M.setup_server(server_name, config)
  M.buf_try_add_lspconfig(server_name, bufnr)
end

function M.toggle_buf_lsp(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if M.is_client_active(server_name, bufnr) then
    vim.lsp.stop_client(vim.lsp.get_client_by_id(vim.lsp.get_clients({
      bufnr = bufnr,
      name = server_name,
    }), true))
  else
    M.buf_try_add_lspconfig(server_name, bufnr)
  end
end

local function current_buf_matches_file_patterns(bufnr, patterns)
  if not bufnr then return false end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if not bufname then return false end

  for _, pattern in ipairs(patterns) do
    if string.match(bufname, string.format('.%s', pattern)) then
      return true
    end
  end
  return false
end

local function current_buf_matches_filetypes(bufnr, filetypes)
  if not bufnr then return false end
  local buf_filetype = vim.api.nvim_get_option_value('filetype', {
    buf = bufnr,
  })
  if not buf_filetype or buf_filetype == '' then return false end
  return vim.tbl_contains(filetypes, buf_filetype)
end

function M.get_lspconfig_for_server(server_name)
  local lspconfig = require('lspconfig')
  if lspconfig[server_name] then
    return lspconfig[server_name]
  end
  return {}
end

local function setup_lspconfig_server_once(filetypes, file_patterns, server_name)
  local bufnr = vim.api.nvim_get_current_buf()
  local lspcfg = require('userlib.lsp.cfg')
  if current_buf_matches_file_patterns(bufnr, file_patterns) or current_buf_matches_filetypes(bufnr, filetypes) then
    M.launch_server_on_buf(server_name, lspcfg.get_config_for_server(server_name), bufnr)
  end
  --- TODO: handle rename.
  au.define_autocmds({
    {
      'FileType',
      {
        group = string.format('lspconfig_filetype_%s', server_name),
        pattern = filetypes,
        callback = function(ctx)
          if M.is_client_active(server_name, ctx.buf) then return end
          M.launch_server_on_buf(server_name, lspcfg.get_config_for_server(server_name), ctx.buf)
        end,
      },
    },
    {
      'BufReadPost',
      {
        group = string.format('lspconfig_bufread_%s', server_name),
        pattern = file_patterns,
        callback = function(ctx)
          if M.is_client_active(server_name, ctx.buf) then return end
          M.launch_server_on_buf(server_name, lspcfg.get_config_for_server(server_name), ctx.buf)
        end,
      },
    },
  })
end

local function setup_lspconfig_servers_once(filetypes, file_patterns, servers)
  for _, server_name in ipairs(servers) do
    if CustomServerSetup[server_name] then
      CustomServerSetup[server_name]()
    else
      setup_lspconfig_server_once(filetypes, file_patterns, server_name)
    end
  end
end


function M.setup()
  for filetype, filetype_config in pairs(require('userlib.filetypes.config')) do
    if type(filetype_config.lspconfig) == 'table' then
      local file_patterns = filetype_config.patterns or { string.format('*.%s', filetype) }
      local filetypes = filetype_config.filetypes or { filetype }
      local servers = filetype_config.lspconfig

      setup_lspconfig_servers_once(filetypes, file_patterns, servers)
    end
  end
end

return M
