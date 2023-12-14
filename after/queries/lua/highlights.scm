;; extends

; https://github.com/wookayin/dotfiles/blob/4b90c2a29fa1bf015847c741436be5f090166b11/nvim/after/queries/lua/highlights.scm
((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @string.injection @nospell)))
  (#any-of? @_vimcmd_identifier
    "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec" "vim.api.nvim_exec2"
    "vim_cmd"  ; custom local function
    )
  )
