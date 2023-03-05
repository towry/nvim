local pack = require('ty.core.pack').tools

pack({
  'pze/cheatsheet.nvim',
  dev = false,
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  cmd = 'Cheatsheet',
  ImportOption = 'cheatsheet',
})

pack({
  'michaelb/vim-tips',
  init = function() vim.g.vim_tips_display_at_startup = 0 end,
})

pack({
  'RishabhRD/nvim-cheat.sh',
  cmd = { 'Cheat', 'CheatWithoutComments', 'CheatList', 'CheatListWithoutComments' },
  dependencies = {
    'RishabhRD/popfix',
  },
  init = function() vim.g.cheat_default_window_layout = 'vertical_split' end,
})

pack({
  'pze/ChatGPT.nvim',
  cmd = { 'ChatGPT', 'ChatGPTActAs' },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  enabled = function()
    -- create OPENAI_API_KEY in `$HOME/.dotfiles/source/private.sh`
    return os.getenv('OPENAI_API_KEY') ~= nil
  end,
  ImportOption = 'chat_gpt',
})
