return {
  'bennypowers/splitjoin.nvim',
  keys = {
    {
      'gj',
      function()
        if vim.bo.buftype ~= "" then return end
        require 'splitjoin'.join()
      end,
      desc = 'Join the object under cursor'
    },
    {
      'g,',
      function()
        if vim.bo.buftype ~= "" then return end
        require 'splitjoin'.split()
      end,
      desc = 'Split the object under cursor'
    },
  }
}
