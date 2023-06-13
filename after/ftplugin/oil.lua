vim.b.minianimate_disable = true
vim.opt.spell = false

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set({ 'n', 'i' }, '<Char-0xAA>', '<ESC>:e!<CR>', {
  desc = '<Cmd-s> to discard changes in oil buffer',
  buffer = bufnr,
})
