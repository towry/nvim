vim.b.minicursorword_disable = true
if vim.fn.exists('&winfixbuf') == 1 then
  vim.cmd('setlocal winfixbuf')
end

local alterbuf = vim.fn.winbufnr(vim.fn.winnr('#'))
vim.t.neotree_last_buf = alterbuf
