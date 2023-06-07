return {
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
    }
  }
}
