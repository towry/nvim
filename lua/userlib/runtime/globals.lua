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

Ty.NOTIFY = function(...) vim.notify(...) end

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

--- get 'BASE' or 'REMOTE' or 'LOCAL' from the buffer file name in git three way
--- diff mode.
Ty.stl_git_three_way_name = function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local basename = vim.fn.fnamemodify(bufname, ':t')
  if vim.bo.filetype == 'gitcommit' then return '' end
  if basename == 'RCONFL' then return 'REMOTE' end
  -- if basename contains REMOTE
  if vim.fn.match(basename, '_REMOTE_') ~= -1 then
    return 'REMOTE'
  elseif vim.fn.match(basename, '_LOCAL_') ~= -1 then
    return 'LOCAL'
  elseif vim.fn.match(basename, '_BASE_') ~= -1 then
    return 'BASE'
  else
    return 'MERGED'
  end
end

--- return string for statuscolumn's number
Ty.stl_num = function()
  --- if option number is off, return empty string
  if vim.o.number == false then return '' end
  --- if option relativenumber is on, return relative number
  if vim.o.relativenumber == true then
    if vim.v.relnum == 0 then return ' ' .. vim.v.lnum else return ' ' .. vim.v.relnum end
  end
  return ' ' .. vim.v.lnum
end
