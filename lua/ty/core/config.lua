--- provide abstract configuration reading.
--- suppose user access the configurations like this:
--- require("ty.core.config").editing.format.enable, then the first segment `editing` is the module
--- inside `lua/ty/contrib/<module>/config.lua` and the second segment `format` is the configuration
--- section inside the module config file that describing the configuration for formatting stuff related to editing.
--- On accessing the first segment, if it is not found on the cached loaded modules, try load it from the module config file.
--- on accessing the rest segments, the the key not found, just return nil.
--- @module "ty.core.config"
--- @usage require("ty.core.config").editing.format.enable
--- @usage require("ty.core.config").editing:get("format.enable", false)
--- @usage require("ty.core.config").editing:merge("format.enable", false)
local M = {}
local Config = {}
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

--- Merge user config into default configs. config_path specific the user config.
---@usage require("ty.core.config").merge("editing.diagnostic", { enable = false })
---@param config_path string the dotted config path, for example `editing.format.enable`
---@param ... any varargs for table to be merged.
function M.merge(config_path, ...)
  local config = Config
  for segment in config_path:gmatch('[^%.]+') do
    config = config[segment]
    if config == nil then
      config = {}
      break
    end
  end
  if config == nil then config = {} end

  --- if config is boolean or string, it's meant for overridding, so just return.
  if type(config) ~= 'table' then return config end

  -- merge config with ..., but use config right most item.
  local args = { ... }
  table.insert(args, config)
  return vim.tbl_deep_extend('force', unpack(args))
end

-- config_path specific the user config.
-- If user config exist, use user config, otherwise use the provided defaults.
function M.with_default(config_path, defaults)
  local config = Config
  for segment in config_path:gmatch('[^%.]+') do
    config = config[segment]
    if config == nil then break end
  end
  if config == nil then return defaults end

  return config
end

setmetatable(M, {
  __index = function(_, k)
    local ok = nil
    local module = nil
    if Config[k] then
      module = Config[k]
    else
      ok, module = pcall(require, 'ty.contrib.' .. k .. '.config')
      if not ok or type(module) ~= 'table' then module = {} end
    end

    local metatable = {}
    --- @param key_path string the dotted key path, for example `editing.format.enable`
    --- @param default_value any the default value if key not found.
    function metatable:get(key_path, default_value)
      if not key_path then return default_value end
      local cfg = module
      for segment in key_path:gmatch('[^%.]+') do
        cfg = cfg[segment]
        if cfg == nil then return default_value end
      end
      return cfg
    end

    function metatable:merge(key_path, ...)
      local config = module
      for segment in key_path:gmatch('[^%.]+') do
        config = config[segment]
        if config == nil then
          config = {}
          break
        end
      end
      if config == nil then config = {} end

      --- if config is boolean or string, it's meant for overridding, so just return.
      if type(config) ~= 'table' then return config end

      -- merge config with ..., but use config right most item.
      local args = { ... }
      table.insert(args, config)
      return vim.tbl_deep_extend('force', unpack(args))
    end

    Config[k] = setmetatable(metatable, {
      __index = function(_, key) return module[key] end,
      -- readonly
      __newindex = function() error('attempt to update a read-only table', 2) end,
    })
    return Config[k]
  end,
  -- readonly
  __newindex = function() error('attempt to update a read-only table', 2) end,
})

return M
