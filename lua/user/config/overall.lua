local plugin_opts = {
  ---runtime
  runtime__disable_builtin_plugins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "matchit",
    "matchparen",
    "logiPat",
    "rust_vim",
    "rust_vim_plugin_cargo",
    "rrhelper",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
  },
  runtime__disable_builtin_provider = {
    "perl",
    "node",
    "ruby",
    "python",
    "python3",
  },

  ---editor stuff
  --enable relative number or not.
  editor__relative_number = true,
  editor__highlight_yanked = true,
  editor__terminal_auto_insert = true,
  editor__jump_lastline_enable = true,
  editor__jump_lastline_ignore_filetypes = { "gitcommit", "gitrebase", "svn", "hgcommit", "Dashboard" },
  editor__jump_lastline_ignore_buftypes = { "quickfix", "nofile", "help" },
  -- editor extended features.
  editorExtend__colorizer_enable = true,
  editorExtend__colorizer_filetypes = {
    'html',
    'css',
    'javascript',
    'typescript',
    'typescriptreact',
    'javascriptreact',
    'lua',
    'sass',
    'scss',
    'less',
  },
  editorExtend__colorizer_enable_tailwind_color = true,

  ---languages
  lang__treesitter_ensure_installed = {
    'bash',
    'css',
    'html',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'python',
    'regex',
    'rust',
    'scss',
    'tsx',
    'typescript',
    'yaml',
    'markdown',
    'markdown_inline',
  }
  lang__treesitter_plugin_incremental_selection = false,
  lang__treesitter_plugin_highlight = true,
  lang__treesitter_plugin_indent = true,
  lang__treesitter_plugin_yati = true,
  lang__treesitter_plugin_rainbow = false,
  lang__treesitter_plugin_context_commentstring = true,
  lang__treesitter_plugin_refactor = false,
  lang__treesitter_plugin_textobjects_move = true,
  lang__treesitter_plugin_textsubjects = true,

  lang__lsp_enable_servers = {
    "tailwindcss",
    "cssls",
    "jsonls",
    "lua_ls",
    "volar",
    "bashls",
    "html",
  }
  lang__lsp_server_tailwindcss_prettier = false,
  lang__lsp_server_volar_takeover_mode = true,
  lang__lsp_ui_progress = true,
  lang__lsp_ui_progress_ignore_servers = {
    "null-ls",
    "tailwindcss",
  }
  lang__lsp_allow_incremental_sync = false,
  lang__lsp_debounce_text_changes = 600,

  ---misc stuff.
  misc__buf_exclude = {
    "netrw",
    "tutor",
  },
  misc__ft_exclude = {
    "alpha",
    "lazy",
    "TelescopePrompt",
    "term",
    "nofile",
    "spectre_panel",
    "help",
    "txt",
    "log",
    "Trouble",
    "NvimTree",
    "qf",
  },

  ---plugins specific.
  plugin__fidget_enable = true,
  plugin__fidget_text_spinner = "pipe",
  plugin__fidget_text_done = '  ',
  plugin__fidget_debug_logging = false,
}

return {
  setup = function()
    vim.cfg = plugin_opts
  end
}