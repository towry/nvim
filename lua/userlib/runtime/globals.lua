_G.unpack = _G.unpack or table.unpack
_G.Ty = {}
_G.R = require

vim.g.miniclues = {}

--- vim.uv.cwd can return nil
local local_cwd = vim.uv.cwd() or vim.uv.os_homedir()

---@param loose_or_path? boolean|string
_G.safe_cwd = function(loose_or_path)
  local _cwd = vim.uv.cwd() or vim.uv.os_homedir()

  if loose_or_path == true then
    return _cwd
  end
  local cwd = (type(loose_or_path) == 'string' and loose_or_path ~= '') and loose_or_path or _cwd
  local pathutil = require('userlib.runtime.path')
  if pathutil.is_home_dir(cwd) or pathutil.is_fs_root(cwd) then
    return local_cwd
  end
  return cwd
end
---see `require`

Ty.P = function(v)
  vim.print(v)
  return v
end

Ty.RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

---@param mod string
---@param fn_call string
Ty.ModFnCall = function(mod, fn_call, ...)
  local ok, mode = pcall(require, mod)
  if not ok then
    return
  end
  return mode[fn_call](...)
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

---@param sign? Sign
---@param len? number
local function get_icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or '', 0, len) ---@type string
  text = text .. string.rep(' ', len - vim.fn.strchars(text))
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

---@return Sign?
---@param buf number
---@param lnum number
local function get_mark(buf, lnum)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match('[a-zA-Z]') then
      return { text = mark.mark:sub(2), texthl = 'DiffDelete' }
    end
  end
end

--- FIXME: if two window opened, the marks will be also displayed on the second
--- window.
--- return string for statuscolumn's number
--- https://github.com/LazyVim/LazyVim/blob/864c58cae6df28c602ecb4c94bc12a46206760aa/lua/lazyvim/util/ui.lua#L112
Ty.stl_num = function()
  local el = '%='
  local mark = get_mark(tonumber(vim.g.actual_curbuf, 10), vim.v.lnum)
  local mark_icon = mark and get_icon(mark) or nil
  -- local mark_icon = false
  if mark_icon then
    return mark_icon
  end
  local space = ' '
  --- if option number is off, return empty string
  if vim.o.number == false or vim.v.virtnum ~= 0 then
    return ''
  end
  --- if option relativenumber is on, return relative number
  if vim.o.relativenumber == true then
    if vim.v.relnum == 0 then
      return vim.v.lnum .. space
    else
      return el .. vim.v.relnum .. space
    end
  end
  return el .. vim.v.lnum .. space
end

Ty.stl_relative_bufname = function(buf)
  local bufnr = buf or tonumber(vim.g.actual_curbuf)
  if not bufnr or vim.bo[bufnr].buftype ~= '' then
    return '%f'
  end
  local fullname = vim.api.nvim_buf_get_name(bufnr)
  local relative = vim.fn.fnamemodify(fullname, ':.')
  if relative == fullname then
    relative = vim.fn.fnamemodify(fullname, ([[:s?%s?%s?]]):format(vim.cfg.runtime__starts_cwd, ''))
  end
  if relative == '' or not relative then
    return ''
  end
  local tail = vim.fn.fnamemodify(relative, ':t')
  local root = vim.fn.fnamemodify(relative, ':h')
  local winwidth = vim.fn.winwidth(0)
  if winwidth < 40 then
    root = '.'
  elseif vim.fn.strlen(relative) / winwidth > 0.8 then
    root = '!'
  end
  return string.format('%%#WidgetTextHighlight#%s%%#StatusLine#%s', tail, root == '.' and '' or ('│' .. root))
end

--- "│"
Ty.stl_foldlevel = function()
  if vim.b.stl_foldlevel == false or not vim.wo[0].foldenable then
    return ''
  end

  local _ = function(c)
    return '' .. c .. ''
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
      return _(' ')
    end
  else
    return _(' ')
  end
end
Ty.stl_bufcount = function()
  return #vim.fn.getbufinfo({
    buflisted = 1,
  })
end
Ty.stl_bufChangedCount = function()
  return #require('userlib.runtime.buffer').unsaved_list()
end

Ty.set_terminal_keymaps = vim.schedule_wrap(function(bufnr)
  local nvim_buf_set_keymap = vim.keymap.set
  local buffer = bufnr or vim.api.nvim_get_current_buf()
  local opts = { noremap = true, buffer = buffer, nowait = true, silent = true }

  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end

  --- prevent <C-z> behavior in all terminals in neovim
  nvim_buf_set_keymap('t', '<C-z>', '<NOP>', opts)

  -- do not bind below keys in fzf-lua terminal window.
  if vim.tbl_contains({ 'yazi', 'fzf' }, vim.bo.filetype) then
    return
  end

  nvim_buf_set_keymap('t', '<esc><esc>', function()
    vim.cmd.stopinsert()
  end, opts)
  nvim_buf_set_keymap({ 'n', 't' }, '<F2>', function()
    if not vim.b.osc7_dir then
      return
    end
    vim.cmd('stopinsert')

    vim.schedule(function()
      local choice = vim.fn.confirm('Cd into: ' .. vim.b.osc7_dir .. ' ?', '&Yes\n&No', 2)
      if choice == 1 then
        vim.cmd('Cdin ' .. vim.b.osc7_dir)
        return
      end
      vim.cmd.startinsert()
    end)
  end, opts)

  nvim_buf_set_keymap('n', 'q', [[:startinsert<cr>]], opts)
  -- nvim_buf_set_keymap('t', '<ESC>', [[<C-\><C-n>]], opts)
  --- switch windows
  nvim_buf_set_keymap('t', '<C-\\><C-h>', [[<C-\><C-n><C-W>h]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-j>', [[<C-\><C-n><C-W>j]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-k>', [[<C-\><C-n><C-W>k]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-l>', [[<C-\><C-n><C-W>l]], opts)

  --- resize
  -- nvim_buf_set_keymap('t', '<A-h>', [[<C-\><C-n><A-h>]], opts)
  -- nvim_buf_set_keymap('t', '<A-j>', [[<C-\><C-n><A-j>]], opts)
  -- nvim_buf_set_keymap('t', '<A-k>', [[<C-\><C-n><A-k>]], opts)
  -- nvim_buf_set_keymap('t', '<A-l>', [[<C-\><C-n><A-l>]], opts)
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

Ty.has_ai_suggestions = function()
  return (vim.b._copilot and vim.b._copilot.suggestions ~= nil)
    or (vim.b._codeium_completions and vim.b._codeium_completions.items ~= nil)
end
Ty.has_ai_suggestion_text = function()
  if vim.b._copilot and vim.b._copilot.suggestions ~= nil then
    local suggestion = vim.b._copilot.suggestions[1]
    if suggestion ~= nil then
      suggestion = suggestion.displayText
    end
    return suggestion ~= nil
  end

  if vim.b._codeium_completions and vim.b._codeium_completions.items then
    local index = vim.b._codeium_completions.index or 0
    local suggestion = vim.b._codeium_completions.items[index + 1] or {}
    local parts = suggestion.completionParts or {}
    if type(parts) ~= 'table' then
      return false
    end
    return #parts >= 1
  end

  return false
end

Ty.capture_tmux_pane = function(pid)
  if not pid or pid == 0 then
    -- rerun last
    local last_cmd = vim.b.over_dispatch or ''
    -- if last_cmd contains "tmux capture-pane"
    if vim.fn.match(last_cmd, 'tmux capture-pane') ~= -1 then
      -- rerun current scope's dispatch command
      vim.cmd('OverDispatch')
      -- vim.cmd('Copen')
      return
    end
    return
  end
  vim.cmd(string.format('OverDispatch tmux capture-pane -t %s -p', pid))
end

Ty.feedkeys = function(keys)
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true))
end

Ty.source_vimscripts = function(filename)
  local user_config_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')
  local vimscript = user_config_dir .. '/vimscripts/' .. filename
  if vim.fn.filereadable(vimscript) == 0 then
    vim.notify("Can't locate " .. vimscript, vim.log.levels.ERROR)
    return
  end
  vim.cmd('source ' .. vimscript)
end

Ty.buf_vtext = function()
  if vim.fn.exists('*getregion()') == 1 then
    local list = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'))
    return #list > 0 and list[1] or ''
  end
  return ''
end

Ty.resize = {
  --- record current state.
  record = function()
    local ok, m = pcall(require, 'bufresize')
    if ok then
      m.register()
    end
  end,
  --- block until sync action taken.
  block = function()
    local ok, m = pcall(require, 'bufresize')
    if ok then
      m.block_register()
      vim.g.resize_info_win = vim.api.nvim_get_current_win()
    end
  end,
  --- sync after terminal resized
  sync = function()
    local ok, m = pcall(require, 'bufresize')
    if ok then
      m.resize()
    end
  end,
  --- sync after something closed
  after_close = function()
    local ok, m = pcall(require, 'bufresize')
    if ok then
      m.resize_close()
      -- vim.schedule(vim.cmd.stopinsert)
      vim.g.resize_info_win = nil
    end
  end,
  --- sync after something opened
  after_open = function()
    local ok, m = pcall(require, 'bufresize')
    if ok then
      m.resize_open()
      -- vim.schedule(vim.cmd.stopinsert)
      vim.g.resize_info_win = nil
    end
  end,
}

--- check window cols and rows to determine vertical split or horizontal split
Ty.smart_split_cmd = function(cmd)
  local rows, cols = vim.o.lines, vim.o.columns
  if rows > cols then
    vim.cmd('vert ' .. cmd)
  else
    vim.cmd('hor ' .. cmd)
  end
end
