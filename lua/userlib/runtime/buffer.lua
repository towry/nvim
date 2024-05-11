local Table = require('userlib.runtime.table')
local M = {}

function M.is_empty_buffer(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = bufnr,
  })
  if buftype == 'nofile' then
    return true
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  return filename == ''
end

function M.set_options(buf, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_set_option_value(k, v, {
      buf = buf,
    })
  end
end

-- see https://github.com/nathanlc/dotfiles/blob/4eab9adac18965899fbeec0e6b0201997a3668fe/nvim/lua/utils/buffer.lua
---@return table<number, string> map of buffer number to buffer name
function M.list()
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == '' then
      return false
    end

    return vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)

  return Table.reduce(function(nrNameMap, b)
    nrNameMap[b] = vim.api.nvim_buf_get_name(b)

    return nrNameMap
  end, {}, valid_buffers)
end

---@param extra_filter? function bufnr
function M.list_bufnrs(extra_filter)
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == '' then
      return false
    end

    if extra_filter and extra_filter(b) == false then
      return false
    end

    return vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)
  return valid_buffers
end

--- Get buf numbers of normal files.
function M.list_normal_bufnrs()
  return M.list_bufnrs(function(b)
    if vim.api.nvim_get_option_value('buftype', {
      buf = b,
    }) ~= '' then
      return false
    end
  end)
end

local function buf_navigatable(buf)
  local getopt = function(opt)
    return vim.api.nvim_get_option_value(opt, { buf = buf })
  end

  local buflisted = getopt('buflisted')
  if not buflisted then
    return false
  end
  local buftype = getopt('buftype')
  if buftype == 'terminal' then
    return false
    -- return true
  end

  return buftype == '' and getopt('modifiable')
end
function M.next_bufnr(curbuf)
  curbuf = curbuf or 0
  curbuf = curbuf == 0 and vim.api.nvim_get_current_buf() or curbuf
  local bufs = vim.api.nvim_list_bufs()
  local current_idx = 0
  local next_bufnr = nil

  for idx, bufnr in ipairs(bufs) do
    if bufnr == curbuf then
      current_idx = idx
      break
    end
  end

  for i = current_idx + 1, #bufs do
    local bufnr = bufs[i]
    if buf_navigatable(bufnr) then
      next_bufnr = bufnr
      break
    end
  end

  -- loop through
  if next_bufnr == nil then
    for i = 1, current_idx - 1 do
      local bufnr = bufs[i]
      if buf_navigatable(bufnr) then
        next_bufnr = bufnr
        break
      end
    end
  end

  return next_bufnr
end

function M.prev_bufnr(curbuf)
  curbuf = curbuf or 0
  curbuf = curbuf == 0 and vim.api.nvim_get_current_buf() or curbuf
  local bufs = vim.api.nvim_list_bufs()
  local current_idx = 0
  local prev_bufnr = nil

  for idx, bufnr in ipairs(bufs) do
    if bufnr == curbuf then
      current_idx = idx
      break
    end
  end

  if current_idx > 1 then
    for i = current_idx - 1, 1, -1 do
      local bufnr = bufs[i]
      if buf_navigatable(bufnr) then
        prev_bufnr = bufnr
        break
      end
    end
  elseif current_idx == 1 then
    local last_idx = #bufs
    for i = last_idx, 1, -1 do
      local bufnr = bufs[i]
      if buf_navigatable(bufnr) then
        prev_bufnr = bufnr
        break
      end
    end
  end

  return prev_bufnr
end
-- _G.prev_bufnr = M.prev_bufnr
-- _G.next_bufnr = M.next_bufnr

--- Get current tab's visible buffers.
function M.list_tab_buffers()
  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  local bufnrs = {}
  for _, win in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_get_option_value('buflisted', {
      buf = bufnr,
    }) or vim.bo[bufnr].buftype == 'acwrite' then
      table.insert(bufnrs, bufnr)
    end
  end
  return bufnrs
end

--- filter buffers
function M.filter_bufnrs(filter)
  local all_buffers = vim.api.nvim_list_bufs()
  return Table.filter(function(b)
    return filter(b)
  end, all_buffers)
end

---@param callback function carry, bufnr
function M.reduce_bufnrs(callback, carry)
  local all_buffers = vim.api.nvim_list_bufs()
  return Table.reduce(callback, carry, all_buffers)
end

---@param opts? {perf?:boolean}
---@return table<number> list of buffer numbers
function M.unsaved_list(opts)
  opts = opts or {}
  local all_buffers = vim.api.nvim_list_bufs()
  if opts.perf and #all_buffers > 40 then
    return {}
  end
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == '' then
      return false
    end

    local is_modified = vim.api.nvim_get_option_value('modified', {
      buf = b,
    })
    if not is_modified then
      return false
    end

    return vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)
  return valid_buffers
end

---@return number|nil buffer number
function M.get_current_empty_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  -- local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local ft = vim.api.nvim_get_option_value('filetype', {
    buf = bufnr,
  })
  if name == '' and ft == '' then
    return bufnr
  end
  return nil
end

function M.getfsize(bufnr)
  local file = nil
  if bufnr == nil then
    file = vim.fn.expand('%:p')
  else
    file = vim.api.nvim_buf_get_name(bufnr)
  end

  local size = vim.fn.getfsize(file)
  if size <= 0 then
    return 0
  end
  return size
end

-- set the current buffer, if already showed in visible windows,
-- switch focus to it's window.
function M.set_current_buffer_focus(bufnr, tabonly)
  if tabonly == nil then
    tabonly = true
  end

  if not tabonly then
    local buf_win_id = unpack(vim.fn.win_findbuf(bufnr))
    if buf_win_id ~= nil then
      vim.api.nvim_set_current_win(buf_win_id)
      return
    end
  else
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  vim.api.nvim_set_current_buf(bufnr)
end

--- Taken from flatten.nvim
---@param focus_bufnr? number
---@return integer?
function M.smart_open(focus_bufnr)
  -- set of valid target windows
  local valid_targets = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local win_buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_config(win).zindex == nil and vim.bo[win_buf].buftype == '' then
      valid_targets[win] = true
    end
  end

  local layout = vim.fn.winlayout()

  -- traverse the window tree to find the first available window
  local stack = { layout }
  local win_alt = vim.fn.win_getid(vim.fn.winnr('#'))
  local win

  -- prefer the alternative window if it's valid
  if valid_targets[win_alt] and win_alt ~= vim.api.nvim_get_current_win() then
    win = win_alt
  else
    while #stack > 0 do
      local node = table.remove(stack)
      if node[1] == 'leaf' then
        if valid_targets[node[2]] then
          win = node[2]
          break
        end
      else
        for i = #node[2], 1, -1 do
          table.insert(stack, node[2][i])
        end
      end
    end
  end

  -- allows using this function as a utility to get a window to open something in
  if not focus_bufnr then
    return win
  end

  if win then
    vim.api.nvim_win_set_buf(win, focus_bufnr)
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, focus_bufnr)
  end
end

--- Focus buffer in current tab's visible window
function M.focus_buf_in_visible_windows(bufnr)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      vim.api.nvim_set_current_win(win)
      return win
    end
  end
  return
end

M.edit_alt_buf = function()
  local altnr = vim.fn.bufnr('#')
  if not altnr or altnr < 1 then
    return
  end
  if not vim.api.nvim_buf_is_loaded(altnr) then
    -- buf is deleted but not wipped out
    ---@diagnostic disable-next-line: cast-local-type
    altnr = M.next_bufnr()
  end
  if not altnr then
    return
  end
  M.set_current_buffer_focus(altnr)
  print('#' .. altnr)
end

M.next_unsaved_buf = function()
  local unsaved_buffers = M.unsaved_list()
  if #unsaved_buffers <= 0 then
    vim.notify('No unsaved buffer', vim.log.levels.WARN)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()

  local current_buf_index = vim.fn.index(unsaved_buffers, current_buf)
  if current_buf_index < 0 then
    current_buf_index = 0
  end

  local next_buf_index = current_buf_index + 1
  if next_buf_index > #unsaved_buffers then
    next_buf_index = 1
  end
  local next_buf = unsaved_buffers[next_buf_index]
  if not next_buf or next_buf < 1 then
    return
  end

  M.set_current_buffer_focus(next_buf)
  -- vim.api.nvim_set_current_buf(next_buf)
end

M.prev_unsaved_buf = function()
  local unsaved_buffers = M.unsaved_list()
  if #unsaved_buffers <= 0 then
    vim.notify('No unsaved buffer', vim.log.levels.WARN)
    return
  end
  local current_buf = vim.api.nvim_get_current_buf()

  local current_buf_index = vim.fn.index(unsaved_buffers, current_buf)
  if current_buf_index < 0 then
    current_buf_index = 2
  end

  local prev_buf_index = current_buf_index - 1
  if prev_buf_index < 1 then
    prev_buf_index = #unsaved_buffers
  end
  local prev_buf = unsaved_buffers[prev_buf_index]
  if not prev_buf or prev_buf < 1 then
    return
  end
  M.set_current_buffer_focus(prev_buf)
  -- vim.api.nvim_set_current_buf(prev_buf)
end

function M.preserve_window(callback, ...)
  local win = vim.api.nvim_get_current_win()
  callback(...)
  if win ~= vim.api.nvim_get_current_win() then
    vim.cmd.wincmd('p')
  end
end

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param min_height number
---@param max_height number
function M.adjust_split_height(min_height, max_height)
  vim.api.nvim_win_set_height(0, math.max(math.min(vim.fn.line('$'), max_height), min_height))
end

---@param bufnr? number
function M.buffer_display_in_other_window(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return #vim.fn.win_findbuf(bufnr) > 1
end

---@param opts {size?:number,lines?:number}
function M.is_big_file(buf, opts)
  opts = opts or {}
  local size = opts.size or (1024 * 1000)
  local lines = opts.lines or 20000

  --- NOTE: what if user changed file content make it small?
  if vim.b[buf].is_big_file ~= nil then
    return vim.b[buf].is_big_file
  end

  if M.getfsize(buf) > size then
    return true
  end
  if vim.api.nvim_buf_line_count(buf) > lines then
    return true
  end
end

--- Return the windows count in current tab
--- exclude float windows.
--- NOTE: windows like fidget is floating window.
function M.current_tab_windows_count()
  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  local count = 0
  for _, win in ipairs(tab_wins) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      count = count + 1
    end
  end
  return count
end

return M
