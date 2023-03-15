vim.cmd([[setlocal nospell]])
vim.cmd([[setlocal foldcolumn=0]])
vim.cmd([[setlocal signcolumn=no]])
vim.cmd([[setlocal nohlsearch]])
vim.cmd([[setlocal statuscolumn=]])

local gr = vim.api.nvim_create_augroup('outline_exit', { clear = true })
vim.api.nvim_create_autocmd('BufWinLeave', {
  group = gr,
  buffer = 0,
  callback = function(ctx)
    local bufnr = ctx.buf
    vim.schedule(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end,
})
