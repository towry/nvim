local M = {}

M.init = function()
  -- auto create jump position at cursor hold.
  -- then use portal to navigate it.
  -- This is lua port of below vim script
  -- :autocmd CursorHold * normal! m'
  vim.api.nvim_create_autocmd('CursorHold', {
    pattern = '*',
    callback = function()
      vim.cmd('normal! m\'')
    end
  })
end

return M
