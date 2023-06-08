return {
  'AckslD/messages.nvim',
  opts = {
    command_name = 'Messages',
  },
  keys = {
    {
      '<leader>tm',
      '<cmd>Messages messages<cr>',
      desc = 'Show messages in float'
    }
  },
  config = function(_, opts)
    opts.post_open_float = function(winnr)
      local bufnr = vim.api.nvim_win_get_buf(winnr)
      vim.keymap.set('n', '<esc>', function()
        vim.api.nvim_win_close(winnr, false)
      end, { buffer = bufnr })
      vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(winnr, false)
      end, { buffer = bufnr })
    end
    require('messages').setup(opts)
  end,
  init = function()
    Ty.Msg = function(...)
      require('messages.api').capture_thing(...)
    end
  end,
}
