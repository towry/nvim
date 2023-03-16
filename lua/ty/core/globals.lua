_G.Ty = {}

Ty.P = function(v)
  print(vim.pretty_print(v))
  return v
end

Ty.RELOAD = function(...) return require('plenary.reload').reload_module(...) end

Ty.R = function(name)
  Ty.RELOAD(name)
  return require(name)
end

-- Global fn for cinnamon plugin
Ty.SCROLL = function(...)
  require('cinnamon.scroll').scroll(...)
  -- vim.cmd("Beacon")
end

Ty.NOTIFY = function(...) require('notify').notify(...) end
Ty.ECHO = function(...) vim.api.nvim_echo(...) end

Ty.TS_UTIL = function() return require('nvim-treesitter.ts_utils') end
-- get node type at current cursor
Ty.TS_GET_NODE_TYPE = function() return require('nvim-treesitter.ts_utils').get_node_at_cursor(0):type() end
Ty.ToggleTheme = function(mode)
  if vim.o.background == mode then return end

  if vim.o.background == 'light' then
    vim.o.background = 'dark'
    Ty.NOTIFY('Light out 🙅')
  else
    vim.o.background = 'light'
    Ty.NOTIFY('Light on 😛')
  end
end

---@usage Ty.Func.explorer.project_files()
Ty.Func = require('ty.core.func')

---@usage Ty.Config.ui.float.border
Ty.Config = require('ty.core.config')
