local M = {}

M.option_cheatsheet = {
  bundled_plugin_cheatsheets = false,
  bundled_cheatsheets = false,
  include_only_installed_plugins = true,
}

M.option_chat_gpt = {
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

M.setup_im_select = function()
  require('im_select').setup({
    default_im_select = "com.apple.keylayout.ABC",
    default_command = "im-select",
    keep_quiet_on_no_binary = true,
  })
end

return M
