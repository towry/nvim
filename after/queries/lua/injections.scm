;; extends

; see $DOTVIM/after/queries/lua/highlights.scm
; see also -- :EditQuery injections lua

; vim.cmd [[ ... ]]
((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @injection.content)))
  (#any-of? @_vimcmd_identifier
    "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec" "vim.api.nvim_exec2"
    "vim_cmd"  ; custom local function
    )
  (#set! injection.language "vim")
  )
