--[[
  @usage:
  ```lua
  local pack = require("ty.core.pack").editing
  pack({
    "folke/lazy.nvim",
    Feature = "format",
    lazy = true,
  })
  ```
]]
--
local uv, api, fn = vim.loop, vim.api, vim.fn
local config = require('ty.core.config')
local utils = require('ty.core.utils')
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local Spec = {
  ImportConfig = 'ImportConfig',
  Feature = 'Feature',
  ImportOption = 'ImportOption',
  ImportInit = 'ImportInit',
}

if _G.cachedPack ~= nil then return _G.cachedPack end

local pack = {
  repos = {},
}

local lazy_opts = {
  -- lockfile = self.path_helper.join(self.data_path, 'lazy-lock.json'),
  dev = {
    path = '~/workspace/git-repos',
  },
  install = { colorscheme = { config.ui.theme.colorscheme } },
  checker = { enabled = false },
  defaults = { lazy = true },
  change_detection = {
    enabled = false,
  },
  git = {
    timeout = 120,
    url_format = 'https://ghproxy.com/https://github.com/%s',
  },
  ui = {
    icons = {
      lazy = ' ',
      plugin = ' ',
    },
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        'gzi',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}

function pack:load_modules_packages()
  local modules_dir = self.path_helper.join(self.config_path, 'lua', 'ty', 'contrib')
  self.repos = {}

  local list = vim.fn.globpath(modules_dir, '*/package.lua', false, true)

  if #list == 0 then return end

  local disable_modules = {}

  if fn.exists('g:disable_modules') == 1 then
    disable_modules = vim.split(vim.g.disable_modules, ',', { trimempty = true })
  end

  for _, f in pairs(list) do
    local _, pos = f:find(modules_dir)
    f = f:sub(pos - #'ty/contrib' + 1, #f - 4)
    if not vim.tbl_contains(disable_modules, f) then require(f) end
  end
end

function pack:startup()
  local modules_dir = self.path_helper.join(self.config_path, 'lua', 'ty', 'contrib')
  local list = vim.fn.globpath(modules_dir, '*/init.lua', false, true)
  if #list == 0 then return end
  for _, f in pairs(list) do
    local _, pos = f:find(modules_dir)
    f = f:sub(pos - #'ty/contrib' + 1, #f - 4)
    f = f:gsub('/init$', '') -- see below.
    local mod = require(f)
    if type(mod) == 'table' and type(mod.init) == 'function' then mod.init() end
  end
end

function pack:setup()
  self.path_helper = require('ty.core.path')
  self.data_path = vim.fn.stdpath('data')
  self.config_path = vim.fn.stdpath('config')

  local lazy_path = self.path_helper.join(self.data_path, 'lazy', 'lazy.nvim')
  local state = uv.fs_stat(lazy_path)
  if not state then
    local cmd = '!git clone https://github.com/folke/lazy.nvim ' .. lazy_path
    api.nvim_command(cmd)
  end
  vim.opt.runtimepath:prepend(lazy_path)
  local lazy = require('lazy')

  self:load_modules_packages()
  lazy.setup(self.repos, lazy_opts)
  self.repos = nil
end

function pack.package(repo) table.insert(pack.repos, repo) end

function pack.contrib(scope)
  return function(repo)
    -- control the plugin by feature.
    if repo.enabled == nil and repo.Feature then
      repo.enabled = config[scope][repo.Feature]['enable'] == false and false or true
    end
    -- load config.
    if type(repo[Spec.ImportConfig]) == 'string' and repo.config == nil then
      repo.config = function(...)
        local args = ...
        utils.try(function()
          local is_ok, rc = pcall(require, 'ty.contrib.' .. scope .. '.package_rc')
          if not is_ok then
            print('package rc not found for ' .. scope)
            return
          end
          local setup_method = rc['setup_' .. repo[Spec.ImportConfig]]
          if type(setup_method) == 'function' then
            setup_method(unpack(args))
          else
            error('invalid package ImportConfig for ' .. repo[Spec.ImportConfig])
          end
        end)
      end
    end
    -- load opts.
    if type(repo[Spec.ImportOption]) == 'string' and repo.opts == nil then
      repo.opts = function()
        return require('ty.contrib.' .. scope .. '.package_rc')['option_' .. repo[Spec.ImportOption]]
      end
    end
    -- load init.
    if type(repo[Spec.ImportInit]) == 'string' and repo.init == nil then
      repo.init = function() require('ty.contrib.' .. scope .. '.package_rc')['init_' .. repo[Spec.ImportInit]]() end
    end

    -- add.
    pack.package(repo)
  end
end

--- load plugin.
pack.load = function(...) return require('lazy').load(...) end

-- set __index on pack, so we use access pack.xxx, we take xxx as scope and
-- return pack.contrib(xxx).
setmetatable(pack, {
  __index = function(_, key) return pack.contrib(key) end,
})

_G.cachedPack = pack

return pack
