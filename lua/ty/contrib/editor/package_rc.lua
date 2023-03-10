local M = {}
local config = require('ty.core.config').editor

M.setup_dashboard = require('ty.contrib.editor.dashboard').setup
M.setup_todo_comments = function()
  local todo_comments = require('todo-comments')

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Setup                                                    │
  -- ╰──────────────────────────────────────────────────────────╯
  todo_comments.setup({
    signs = false, -- show icons in the signs column
    sign_priority = 8, -- sign priority
    -- keywords recognized as todo comments
    keywords = {
      FIX = {
        alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
      },
      WARN = { alt = { 'WARNING' } },
      PERF = { alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
    },
    highlight = {
      before = '', -- "fg" or "bg" or empty
      -- keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
      keyword = 'wide', -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
      after = '', -- "fg" or "bg" or empty
      pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
      comments_only = true, -- uses treesitter to match keywords in comments only
      max_line_len = 1500, -- ignore lines longer than this
      exclude = {}, -- list of file types to exclude highlighting
    },
  })
end

M.init_cursor_beacon = function()
  vim.g.beacon_ignore_buffers = { 'quickfix' }
  vim.g.beacon_ignore_filetypes = {
    'alpha',
    'lazy',
    'TelescopePrompt',
    'term',
    'nofile',
    'spectre_panel',
    'help',
    'txt',
    'log',
    'Trouble',
    'NvimTree',
    'qf',
  }
  vim.g.beacon_size = 60
end
M.setup_cursor_beacon = function()
  local colors = require('ty.contrib.ui').colors()
  vim.api.nvim_set_hl(0, 'Beacon', {
    bg = colors.beacon_guibg,
  })
end

M.setup_session_manager = function()
  local session_manager = require('session_manager')
  local Path = require('plenary.path')

  session_manager.setup({
    sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
    path_replacer = '__', -- The character to which the path separator will be replaced for session files.
    colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
    autosave_last_session = config:get('session.auto_save_last'), -- Automatically save last session on exit and on session switch.
    autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
    autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
      'gitcommit',
    },
    autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
    max_path_length = 80, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
  })
end

M.setup_indent_line = function()
  local colors = require('ty.contrib.ui').colors()

  require('indent_blankline').setup({
    use_treesitter = true,
    show_current_context = false,
    buftype_exclude = {
      'nofile',
      'terminal',
    },
    filetype_exclude = {
      'help',
      'startify',
      'aerial',
      'alpha',
      'dashboard',
      'lazy',
      'neogitstatus',
      'NvimTree',
      'neo-tree',
      'Trouble',
    },
  })

  local _ = colors.indent_line_fg and vim.api.nvim_set_hl(0, 'IndentBlanklineChar', { fg = colors.indent_line_fg })
      or nil
end

M.option_true_zen = {
  integrations = {
    lualine = true,
  },
}

M.setup_statuscol = function()
  local statuscol = require('statuscol')
  local builtin = require('statuscol.builtin')

  statuscol.setup {
    separator = '│',
    foldfunc = 'builtin',
    relculright = true,
    setopt = true,
    -- N: line number, S: sign column, F: fold column, s: Separator string. w: whitespace
    segments = {
      { text = { "%s" },                  click = "v:lua.ScSa" },
      {
        text = { builtin.lnumfunc, " " },
        condition = { true, builtin.not_empty },
        click = "v:lua.ScLa",
      },
      { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
    }
  }
end

M.option_guess_indent = {
  auto_cmd = true, -- Set to false to disable automatic execution
  filetype_exclude = config:get('guess_indent.ignore_filetypes'),
  buftype_exclude = config:get('guess_indent.ignore_buftypes'),
}

M.option_rooter = {
  rooter_patterns = config:get('rooter.patterns'),
  trigger_patterns = { '*' },
  manual = false,
  Feature = 'rooter',
}

M.option_buf_lastplace = {
  lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help' },
  lastplace_ignore_filetype = { 'spectre_panel', 'gitcommit', 'gitrebase', 'svn', 'hgcommit' },
  lastplace_open_folds = true,
}

return M
