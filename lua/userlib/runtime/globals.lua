_G.unpack = _G.unpack or table.unpack
_G.Ty = {}

---see `require`

Ty.P = function(v)
  vim.print(v)
  return v
end

Ty.RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

Ty.R = function(name)
  Ty.RELOAD(name)
  return require(name)
end

Ty.NOTIFY = function(...)
  vim.notify(...)
end

--- deprecated
Ty.TS_GET_NODE_TYPE = function()
  return require('nvim-treesitter.ts_utils').get_node_at_cursor(0):type()
end
Ty.ToggleTheme = function(mode)
  if vim.o.background == mode then
    return
  end

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
  opts = opts or {
    flame = true,
  }
  require('plenary.profile').start(filename or vim.fn.expand('$HOME/nvim-profile.log'), opts)
end
Ty.StopProfile = function()
  require('plenary.profile').stop()
end

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
  if vim.bo.filetype == 'gitcommit' then
    return ''
  end
  if basename == 'RCONFL' then
    return 'REMOTE'
  end
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
  local space = ' '
  --- if option number is off, return empty string
  if vim.o.number == false then
    return ''
  end
  --- if option relativenumber is on, return relative number
  if vim.o.relativenumber == true then
    if vim.v.relnum == 0 then
      return space .. vim.v.lnum .. space
    else
      return space .. vim.v.relnum .. space
    end
  end
  return space .. vim.v.lnum .. space
end

--- "│"
Ty.stl_foldlevel = function()
  if vim.b.stl_foldlevel == false or not vim.wo[0].foldenable then
    return ''
  end

  local _ = function(c)
    return ' ' .. c .. ''
  end
  local level = vim.fn.foldlevel(vim.v.lnum)
  if level > 0 then
    if level > vim.fn.foldlevel(vim.v.lnum - 1) then
      if vim.fn.foldclosed(vim.v.lnum) == -1 then
        return _('-')
      else
        return _('+')
      end
    else
      return _('│')
    end
  else
    return _('│')
  end
end

Ty.set_terminal_keymaps = vim.schedule_wrap(function()
  local nvim_buf_set_keymap = vim.keymap.set
  local buffer = vim.api.nvim_get_current_buf()
  local opts = { noremap = true, buffer = buffer, nowait = true }

  --- prevent <C-z> behavior in all terminals in neovim
  nvim_buf_set_keymap('t', '<C-z>', '<NOP>', opts)

  -- do not bind below keys in fzf-lua terminal window.
  if vim.bo.filetype == 'fzf' then
    return
  end

  nvim_buf_set_keymap('t', '<ESC>', [[<C-\><C-n>]], opts)
  --- switch windows
  nvim_buf_set_keymap('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  nvim_buf_set_keymap('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  nvim_buf_set_keymap('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  nvim_buf_set_keymap('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)

  --- resize
  nvim_buf_set_keymap('t', '<A-h>', [[<C-\><C-n><A-h>]], opts)
  nvim_buf_set_keymap('t', '<A-j>', [[<C-\><C-n><A-j>]], opts)
  nvim_buf_set_keymap('t', '<A-k>', [[<C-\><C-n><A-k>]], opts)
  nvim_buf_set_keymap('t', '<A-l>', [[<C-\><C-n><A-l>]], opts)
end)

Ty.lsp_methods = function()
  return require('vim.lsp.protocol').Methods
end

--- Return false if client doesn't support method
--- Return true if client supports method or neovim not sure about it.
--- bug: https://github.com/neovim/neovim/issues/18686
Ty.client_support = function(client, method)
  if client.supports_method then
    return client.supports_method(method)
  end
  return true
end
