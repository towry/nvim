return {
  'bennypowers/splitjoin.nvim',
  keys = {
    { 'gj', function() require 'splitjoin'.join() end,  desc = 'Join the object under cursor' },
    { 'g,', function() require 'splitjoin'.split() end, desc = 'Split the object under cursor' },
  }
}
