vim.b.minianimate_disable = true

local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', '<S-q>', function()
  local current_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(current_win).relative ~= '' then
    -- float win
    require('oil').close()
    return
  end
  local ok, bufstack = pcall(require, 'window-bufstack.bufstack')
  local pre_buf = nil
  if ok then pre_buf = bufstack.pop() end
  require('oil').close()
  if ok and not pre_buf then vim.cmd('q') end
end, {
  desc = 'Close oil',
})

-- <C-o>
set('n', '<C-o>', function()
  local util = require('oil.util')
  local cache = require('oil.cache')
  local entry = require('oil').get_cursor_entry()
  local bufname = vim.api.nvim_buf_get_name(0)
  if entry.type ~= 'file' then return end
  -- https://github.com/stevearc/oil.nvim/blob/4088efb8ff664b6f1624aab5dac6c3fe11d3962c/lua/oil/init.lua#L495C44-L495C49
  if entry.id == nil or (entry.id and cache.get_parent_url(entry.id) ~= bufname) or (entry.parsed_name ~= entry.name) then
    vim.notify("New or Moved or Renamed file, please save it first before open")
    return
  end
  local scheme, dir = util.parse_url(bufname)
  local child = dir .. entry.name
  local url = scheme .. child
  local adapter = util.get_adapter(0)
  if not adapter then
    vim.notify("Could not find adapter to current buffer")
    return
  end

  local get_edit_path
  if adapter.get_entry_path then
    get_edit_path = function(edit_cb)
      adapter.get_entry_path(url, entry, edit_cb)
    end
  else
    get_edit_path = function(edit_cb)
      adapter.normalize_url(url, edit_cb)
    end
  end

  get_edit_path(function(normalized_url)
    local filename = util.escape_filename(normalized_url)
    local win = require("window-picker").pick_window({
      autoselect_one = true,
      -- hint = 'floating-big-letter',
      include_current_win = true,
    })
    if not win then return end

    require('oil').close()

    vim.api.nvim_set_current_win(win)
    vim.cmd({
      cmd = 'edit',
      args = { filename },
      mods = {
        vertical = false,
        horizontal = false,
        keepalt = true,
        emsg_silent = true,
      }
    })
  end)
end, {
  desc = 'Previous buffer',
  nowait = true,
  noremap = true,
})

set('n', 's', function()
  require('flash').jump({
    search = {
      mode = 'search',
      max_length = 0,
      exclude = {
        function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'oil' end,
      },
    },
    label = { after = { 0, 0 } },
    pattern = '^',
  })
end, {
  nowait = true,
})

set('n', 'W', function() require('oil').open(vim.cfg.runtime__starts_cwd) end, {
  nowait = true,
  desc = 'Open in root',
})
set('n', '_', function() require('oil').open(require('userlib.runtime.utils').get_root()) end, {
  nowait = true,
  desc = 'Open in project',
})
