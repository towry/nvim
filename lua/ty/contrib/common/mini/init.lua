local M = {}

M.setup = function()
  require('mini.bufremove').setup({
    set_vim_settings = false,
  })
  require('mini.align').setup()
  -- trail ws hl and remove ops.
  require('mini.trailspace').setup()
  -- Extend and create a/i textobjects
  require('mini.ai').setup()
  -- hi the indent line and provide indent scope textobjects.
  vim.g.miniindentscope_disable = false
  require('mini.indentscope').setup({
    symbol = '│',
    options = {
      try_as_border = true,
    },
  })
  -- enhance the ftFT; motions.
  require('mini.jump').setup()

  -- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-bufremove.txt
end

M.init = function()
  vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('MiniIdentEnter', {
      clear = true,
    }),
    callback = function()
      if vim.bo.buftype == '' then
        -- normal file.
        vim.b.miniindentscope_disable = false
      else
        vim.b.miniindentscope_disable = true
      end
    end,
  })
end

return M
