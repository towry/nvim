--[[
  use luacc command to bundle multiple neovim config files into one file/module.
  The luacc command usage is like: `luacc -o <output_file.lua> -i <prefix_path_to_search_modules> <main_lua_file> lua.module.name1 lua.module.name2`

  The steps to run:
  1. get current neovim config root path
  2. given a module folder path, like 'user.plugins', search files/modules inside the `user.plugins`, then generate the command line string.
  3. call the command using vim or lua system api.
]]
local M = {}
local unpack = table.unpack or unpack

---@param glob_path string for example `user/plugins/*.lua`
---@return table for example ['user/plugins/ui']
local function get_bundle_files(glob_path)
  local path = require('libs.runtime.path')
  local user_config_path = path.join(vim.fn.stdpath("config"), 'lua')

  local files = vim.fn.globpath(user_config_path, glob_path, false, true)
  -- trim the home path from the paths
  -- remove .lua extention from the paths
  files = vim.tbl_map(function(x) return string.gsub(x, user_config_path .. '/', '') end, files)
  files = vim.tbl_map(function(x) return string.gsub(x, '.lua', '') end, files)
  return files
end

---@see https://github.com/mihacooper/luacc
---<br />
---Generate the bundled plugin module
--- Do not forget the position string.
---`{ main = 'user/plug.lua', output = 'user/plug.bundle.lua', glob_dir = 'user/plugins/**' }`
---@param opts {main:string, output:string, glob_dir:string}
M.run_command = function(opts)
  local Path = require('libs.runtime.path')
  opts = opts or {}
  local files = get_bundle_files(opts.glob_dir)
  --- replace lua/user/abc to lua.user.abc
  local files_as_module = vim.tbl_map(function(x) return string.gsub(x, '/', '.') end, files)
  if #files_as_module == 0 then
    error("no files found")
  end
  local user_config_path = vim.fn.stdpath("config")
  local cmds = {
    "luacc",
    "-o",
    Path.join(user_config_path, 'lua', opts.output),
    "-p",
    "LuaCC code block",
    "-i",
    Path.join(user_config_path, 'lua'),
    opts.main,
    unpack(files_as_module),
  }
  local output = vim.fn.system(cmds)
  vim.print(output)
end

return M
