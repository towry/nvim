vim.b.minicursorword_disable = true
if vim.fn.exists('&winfixbuf') == 1 then
  vim.cmd('setlocal winfixbuf')
end
