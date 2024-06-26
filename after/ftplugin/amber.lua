vim.cmd('setlocal makeprg=amber\\ %')

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set('n', '<localleader>cc', function()
  vim.cmd('OverDispatch! amber ' .. vim.fn.expand('%') .. ' ' .. (vim.fn.expand('%:r') .. '.sh'))
end, {
  desc = 'Compile current amber file',
  buffer = bufnr,
})
