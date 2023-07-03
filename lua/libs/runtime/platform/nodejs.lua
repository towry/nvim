local nvm_alias_for_nvim = 'nvim-node'
local nvim_npm_folder = vim.fn.expand('$HOME/.config/nvim-npm')
local stdpath = vim.fn.stdpath
local Path = require('libs.runtime.path')

---@diagnostic disable-next-line: deprecated
local M = {}

-- Some path utilities
M.resolve_path_in_nvim_npm_folder = function(...)
  if select('#', ...) <= 0 then error('path segments is required') end
  return Path.join(nvim_npm_folder, ...)
end
M.nvim_npm_bin_prefix = function(bin_name) return M.resolve_path_in_nvim_npm_folder('bin', bin_name) end

---@deprecated
M.get_nvm_node_path = function()
  local ok, md = pcall(require, 'nvm_node_path_generated')
  if ok then return md.node_bin_path end
  return nil
end

---@deprecated
M.compile_nvm_node_path = function()
  local output_path = Path.join(stdpath('config'), 'lua', 'nvm_node_path_generated.lua')
  local nvm_dir = os.getenv('NVM_DIR')
  if not nvm_dir then
    -- emit warning?
    return
  end

  local node_version = nil
  if pcall(function() io.input(Path.join(nvm_dir, 'alias', nvm_alias_for_nvim)) end) then
    node_version = io.read()
    io.close()
  end

  if not node_version then return end

  local node_bin_path = Path.join(nvm_dir, 'versions', 'node', node_version, 'bin', 'node')
  local output_file = io.open(output_path, 'w')
  if not output_file then return end
  output_file:write(string.format(
    [[
		local M = {}
		M.node_bin_path = %q
		return M
	]],
    node_bin_path
  ))
  output_file:close()
  return node_bin_path
end

---@deprecated use 'get_mason_node_cmd'
M.get_nvim_node_cmd = function(cmd_name, ...)
  local bin_full_name = M.nvim_npm_bin_prefix(cmd_name)
  local node_path = M.get_nvm_node_path()
  if not node_path then
    return { bin_full_name, ... }
  else
    return { node_path, bin_full_name, ... }
  end
end

M.resolve_path_in_node_modules = function(root_dir, path_segs)
  if path_segs == nil or #path_segs <= 0 then error('path segments is required') end

  local found_ts = nil
  local function check_dir(path)
    found_ts = Path.join(path, unpack(path_segs))
    if Path.exists(found_ts) then return found_ts end
  end

  if Path.search_ancestors(root_dir, check_dir) then return found_ts end
  return nil
end

---customize the lsp cmd.
---@param options table
M.get_mason_node_cmd = function(options)
  local cmd_name = options.cmd_name
  local args = options.args or {}
  local bin_full_name = require('mason-core.path').bin_prefix(cmd_name)
  local node_path = options.node_path or nil
  if not node_path then
    -- defaults
    return { bin_full_name, unpack(args) }
  else
    return { node_path, bin_full_name, unpack(args) }
  end
end

M.get_typescript_server_path = function(root_dir)
  local global_ts = M.resolve_path_in_nvim_npm_folder('lib/node_modules/typescript/lib')

  local found_ts = M.resolve_path_in_node_modules(root_dir, { 'node_modules', 'typescript', 'lib' })

  return found_ts or global_ts
end

return M
