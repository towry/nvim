local plug = require('userlib.runtime.pack').plug

return plug({
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      },
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionToggle',
      'CodeCompanionActions',
    },
    keys = {
      {
        '<C-a>',
        '<cmd>CodeCompanionActions<cr>',
        silent = true,
        noremap = true,
        desc = 'CodeCompanion: Run action on code',
        mode = { 'n', 'v' },
      },
      {
        '<leader>t?',
        '<cmd>CodeCompanionToggle<cr>',
        silent = true,
        noremap = true,
        desc = 'CodeCompanion: Toggle chat buffer',
      },
    },
    config = function(_, opts)
      require('codecompanion').setup({
        adapters = {
          chat = 'ollama',
          inline = 'ollama',
        },
      })
    end,
  },
  {
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
    opts = {
      loading_text = '加载中',
      question_sign = '?',
      answer_sign = 'A',
      chat_window = {
        border = {
          text = {
            top = ' ChatGPT   ',
          },
        },
      },
      chat_input = {
        border = {
          text = {
            top = ' ~~ ',
          },
        },
      },
    },
  },
})
