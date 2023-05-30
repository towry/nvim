vim.cmd('set nocursorline')

local bufnr = vim.api.nvim_get_current_buf()
local fts = { 'fugitive' }

-- close alpha when some buffer is opened.
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = "*",
  callback = function(ctx)
    -- local ft = vim.api.nvim_buf_get_option(ctx.buf, 'filetype')
    local ft = vim.api.nvim_get_option_value("filetype", {
      buf = ctx.buf,
    })
    local alpha_buf_is_loaded = vim.api.nvim_buf_is_loaded(bufnr)
    if alpha_buf_is_loaded and vim.tbl_contains(fts, ft) then
      vim.schedule(function()
        vim.cmd('bdelete ' .. bufnr)
      end)
    end
  end,
})
