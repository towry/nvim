vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<cmd>q<cr>', { silent = true, nowait = true, noremap = true })
vim.b[0].autoformat_disable = true
vim.opt_local.spell = true
vim.b.minivisits_disable = true

vim.schedule(function()
  vim.cmd('normal! gg')
end)
