vim.b.minianimate_disable = true
vim.opt.spell = true

local MF = require('mini.files')
local bufnr = vim.api.nvim_get_current_buf()
local key = vim.keymap.set
local keyopts = {
  noremap = true,
  silent = true,
  buffer = bufnr,
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
--------------------

key('n', '-', function()
  MF.go_out()
end, keyopts)

key('n', '_', function()
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
  local cwd = get_current_dir()
  require('userlib.hydra.folder-action').open(cwd, bufnr, function()
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
