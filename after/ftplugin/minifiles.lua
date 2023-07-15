vim.b.minianimate_disable = true
vim.opt.spell = true

local MF = require('mini.files')
local bufnr = vim.api.nvim_get_current_buf()
local key = vim.keymap.set
local keyopts = {
  noremap = true,
  silent = true,
  buffer = bufnr
}

--------------------

key('n', '-', function()
  MF.open(nil, false)
end, keyopts)
key('n', '_', function()
  if vim.w.oil_lcwd ~= nil then
    MF.open(vim.w.oil_lcwd, false)
    vim.w.oil_lcwd = nil
  else
    vim.w.oil_lcwd = MF.get_latest_path()
    --- toggle with current and project root.
    MF.open(require('userlib.runtime.utils').get_root(), false)
  end

end)
key('n', '<C-c>', function()
  MF.close()
end, keyopts)
