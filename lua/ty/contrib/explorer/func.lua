local M = {}

function M.open_buffers() require('ty.contrib.common.telescope_rc.pickers').buffers() end

function M.search_and_replace() require('spectre').open_visual() end

function M.search_and_replace_cword_in_buffer()
  local path = vim.fn.fnameescape(vim.fn.expand('%:p:.'))
  if vim.loop.os_uname().sysname == 'Windows_NT' then path = vim.fn.substitute(path, '\\', '/', 'g') end
  require('spectre').open({
    path = path,
    is_close = true,
    search_text = vim.fn.expand('<cword>'),
  })
end

function M.oldfiles(opts)
  opts = opts or {}
  opts['oldfiles'] = true
  require('ty.contrib.common.telescope_rc.pickers').project_files(opts)
end

function M.project_files(...) require('ty.contrib.common.telescope_rc.pickers').project_files(...) end

function M.multi_rg_find_word(...) require('ty.contrib.common.telescope_rc.multi-rg-picker')(...) end

function M.find_folder() require('ty.contrib.common.telescope_rc.find-folders-picker')() end

function M.toggle_outline() vim.cmd([[SymbolsOutline]]) end

M.toggle_nvim_tree = require('ty.contrib.explorer.nvim-tree').toggle_nvim_tree
M.toggle_nvim_tree_find_file = require('ty.contrib.explorer.nvim-tree').toggle_nvim_tree_find_file

return M
