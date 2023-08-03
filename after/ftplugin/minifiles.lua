local bufnr = vim.api.nvim_get_current_buf()
local key = require('userlib.runtime.keymap').map_buf_thunk(bufnr)
vim.b.minianimate_disable = true
vim.opt.spell = true

local MF = require('mini.files')
local keyopts = {
  noremap = true,
  silent = true,
  nowait = true
}

local show_dotfiles = true
local filter_show = function(fs_entry) return true end
local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, '.')
end
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  MF.refresh({ content = { filter = new_filter } })
end

local get_current_dir = function()
  local fsentry = MF.get_fs_entry()
  if not fsentry then return nil end
  return vim.fs.dirname(fsentry.path)
end

local tabpage = vim.api.nvim_get_current_tabpage()
if vim.cfg.mf_tabpage_cwd_paths == nil then
  vim.cfg.mf_tabpage_cwd_paths = {}
end


-- keymaps
--------------------
key({ 'n', 'v' }, 'd', '"*d', {
  noremap = true,
  silent = true,
  nowait = true,
})
key({ 'n', 'v' }, 'D', '"*D', {
  desc = 'Delete to end of line and yank to register d',
  silent = true,
  noremap = true,
})
key({ 'v' }, 'x', '"*x', {
  noremap = true,
  silent = true,
  nowait = true,
})
key({ 'v' }, 'X', '"*X', {
  noremap = true,
  silent = true,
  nowait = true,
})
-- x in normal is yanked to register x.

key('n', '-', function()
  local lcwd = vim.cfg.mf_tabpage_cwd_paths[tabpage]
  if lcwd ~= nil then
    MF.open(lcwd)
    vim.cfg.mf_tabpage_cwd_paths[tabpage] = nil
  else
    vim.cfg.mf_tabpage_cwd_paths[tabpage] = get_current_dir()
    --- toggle with current and project root.
    MF.open(require('userlib.runtime.utils').get_root(), false)
    MF.trim_left()
  end
end)
key('n', 'm', function()
  local fsentry = MF.get_fs_entry()
  if not fsentry then return nil end
  require('userlib.hydra.folder-action').open(fsentry.path, bufnr, function()
    MF.close()
  end)
end, keyopts)
key('n', 'M', function()
  local cwd = get_current_dir()
  require('userlib.hydra.file-action').open(cwd, bufnr, function()
    MF.close()
  end)
end, keyopts)
key('n', 'g.', toggle_dotfiles, keyopts)
key('n', '<C-c>', function()
  MF.close()
end, keyopts)
key('n', 's', function()
  require('flash').jump({
    search = {
      mode = "search",
      max_length = 0,
      exclude = {
        function(win)
          return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "minifiles"
        end,
      }
    },
    label = { after = { 0, 0 } },
    pattern = "^"
  })
end, keyopts)

key('n', '<CR>', function()
  local fsentry = MF.get_fs_entry()
  if fsentry.fs_type ~= 'file' then
    MF.go_in()
    return
  end
  local win_pick = require('window-picker')
  local win_picked = win_pick.pick_window({
    autoselect_one = true,
    -- hint = 'floating-big-letter',
    include_current_win = false,
  })
  if not win_picked then return end
  MF.set_target_window(win_picked)
  MF.go_in()
  MF.close()
end, keyopts)

---- open in split.
local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    local fsentry = MF.get_fs_entry()
    if fsentry.fs_type ~= 'file' then return end
    -- Make new window and set it as target
    local new_target_window
    vim.api.nvim_win_call(MF.get_target_window(), function()
      vim.cmd(direction .. ' split')
      new_target_window = vim.api.nvim_get_current_win()
    end)

    MF.set_target_window(new_target_window)
    MF.go_in()
    MF.close()
  end

  -- Adding `desc` will result into `show_help` entries
  local desc = 'Split ' .. direction
  vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end
map_split(bufnr, '<C-x>', 'belowright horizontal')
map_split(bufnr, '<C-v>', 'belowright vertical')
