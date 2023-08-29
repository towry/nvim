vim.uv = vim.uv or vim.loop

_G.unpack = _G.unpack or table.unpack
_G.Ty = {}

---see `require`

Ty.P = function(v)
  vim.print(v)
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
---@example
---```lua
---Ty.ECHO({{ 'hello', 'Comment'}})
---Ty.ECHO("hello", 'comment')
---```
---@param chunks string|string[]
---@param history? boolean|string
---@param opts? {verbose?:boolean}
Ty.ECHO = function(chunks, history, opts)
  if type(chunks) == 'string' then
    local hl = nil
    if type(history) == 'string' then
      hl = history
      history = false
    end
    chunks = { { chunks, hl } }
  elseif type(chunks) ~= 'table' then
    error('invalid arguments')
  end
  vim.api.nvim_echo(chunks, history, opts or {})
end

Ty.TS_UTIL = function() return require('nvim-treesitter.ts_utils') end
-- get node type at current cursor
Ty.TS_GET_NODE_TYPE = function() return require('nvim-treesitter.ts_utils').get_node_at_cursor(0):type() end
Ty.ToggleTheme = function(mode)
  if vim.o.background == mode then return end

  if vim.o.background == 'light' then
    vim.o.background = 'dark'
    Ty.NOTIFY('Light out 🌛 ')
  else
    vim.o.background = 'light'
    Ty.NOTIFY('Light on 🌞 ')
  end
end

---@param filename? string
---@param opts? {flame?:boolean}
Ty.StartProfile = function(filename, opts)
  opts = opts or {}
  require('plenary.profile').start(filename or 'profile.log', opts)
end
Ty.StopProfile = function() require('plenary.profile').stop() end

Ty.find_string = function(tab, str)
  local found = false
  for _, v in pairs(tab) do
    if v == str then
      found = true
      break
    end
  end
  return found
end
