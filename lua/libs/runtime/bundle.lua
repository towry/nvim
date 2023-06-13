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

---@param glob_path string for example `lua/user/plugins/**`
---@return table for example ['lua/user/plugins/ui']
local function get_bundle_files(glob_path)
  local user_config_path = vim.fn.stdpath("config")

  local files = vim.fn.globpath(user_config_path, glob_path, false, true)
  return vim.tbl_map(function(x) return vim.fn.fnamemodify(x, ':p') end, files)
end

---@see https://github.com/mihacooper/luacc
---<br />
---Generate the bundled plugin module
--- Do not forget the position string.
---`{ main = 'lua/user/plug.lua', output = 'lua/user/plug.bundle.lua', glob_dir = 'lua/user/plugins/**' }`
---@param opts {main:string, output:string, glob_dir:string}
M.run_command = function(opts)
  opts = opts or {}
  local files = get_bundle_files(opts.glob_dir)
  vim.print(files)
  --- replace lua/user/abc to lua.user.abc
  local files_as_module = vim.tbl_map(function(x) return string.gsub(x, '/', '.') end, files)
  if #files_as_module == 0 then
    error("no files found")
  end
  local user_config_path = vim.fn.stdpath("config")
  local cmds = {
    "luacc",
    "-o",
    opts.output,
    "-p",
    "LuaCC code block",
    "-i",
    user_config_path,
    opts.main,
    unpack(files_as_module),
  }
  vim.print(cmds)
  local output = vim.fn.system(cmds)
  vim.print(output)
end

return M
