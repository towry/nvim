vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd<cr>', { nowait = true, noremap = true, silent = true })

vim.schedule(function()
  local ft = vim.bo.filetype
  if ft ~= 'fugitive' then
    return
  end
  vim.cmd('normal! 5j')
end)
