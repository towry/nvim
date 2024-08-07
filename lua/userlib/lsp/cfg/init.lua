local M = {}

---- lsp server do not attach if root_dir not found.

local servers_path = 'userlib.lsp.servers.'
local capabilities = nil
local lspconfig_cache = {}

local lsp_flags = {
  debounce_text_changes = 50,
  allow_incremental_sync = true,
}

function M.get_config_for_server(server_name)
  local handlers = require('userlib.lsp.cfg.handlers')
  if not capabilities then
    capabilities = require('userlib.lsp.cfg.capbilities')()
  end

  if lspconfig_cache[server_name] then
    return lspconfig_cache[server_name]
  end

  local lsp_configs = {}
  local load_ok, server_rc = pcall(require, servers_path .. server_name)
  if type(server_rc) ~= 'table' then
    load_ok = false
  end
  if type(server_rc) == 'function' then
    return function(income_cfgs)
      return server_rc(income_cfgs)
    end
  end
  if load_ok then
    lsp_configs = vim.tbl_extend('force', {
      flags = lsp_flags,
      capabilities = capabilities,
      handlers = handlers,
    }, server_rc)
  else
    lsp_configs = {
      flags = lsp_flags,
      capabilities,
      handlers,
    }
  end

  lspconfig_cache[server_name] = lsp_configs
  return lsp_configs
end

return M
