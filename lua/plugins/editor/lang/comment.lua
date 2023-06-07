local au = require('libs.runtime.au')
return {
  -- comment generate.
  {
    'danymat/neogen',
    cmd = 'Neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = true,
  },
  {
    'numToStr/Comment.nvim',
    -- event = au.user_autocmds.FileOpened_User,
    keys = { "gcc", "gc", "gcb", "gco", "gcO", "gcA", "g>", "g<", "gb", },
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = function()
      require('Comment').setup({
        ---Add a space b/w comment and the line
        ---@type boolean
        padding = true,
        ---Lines to be ignored while comment/uncomment.
        ---Could be a regex string or a function that returns a regex string.
        ---Example: Use '^$' to ignore empty lines
        ---@type string|function
        ignore = nil,
        ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
        ---@type table
        mappings = {
          ---operator-pending mapping
          ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
          basic = true,
          ---extra mapping
          ---Includes `gco`, `gcO`, `gcA`
          extra = true,
          ---extended mapping
          ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
          extended = false,
        },
        ---LHS of toggle mapping in NORMAL + VISUAL mode
        ---@type table
        toggler = {
          ---line-comment keymap
          line = 'gcc',
          ---block-comment keymap
          block = 'gbc',
        },
        ---LHS of operator-pending mapping in NORMAL + VISUAL mode
        ---@type table
        opleader = {
          ---line-comment keymap
          line = 'gc',
          ---block-comment keymap
          block = 'gb',
        },
        ---Pre-hook, called before commenting the line
        ---@type function|nil
        pre_hook = function(ctx) return require('ts_context_commentstring.internal').calculate_commentstring() end,
        ---Post-hook, called after commenting is done
        ---@type function|nil
        post_hook = nil,
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    keys = {
      {
        ']td', "<cmd>lua require('todo-comments').jump_next()<CR>", desc = 'Jump to next todo',
      },
      {
        ']td', "<cmd>lua require('todo-comments').jump_prev()<CR>", desc = 'Jump to next todo',
      }
    },
    event = au.user_autocmds.FileOpened_User,
    config = function()
      local todo_comments = require('todo-comments')

      todo_comments.setup({
        signs = false,     -- show icons in the signs column
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
          before = '',                     -- "fg" or "bg" or empty
          -- keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          keyword = 'wide',                -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          after = '',                      -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
          comments_only = true,            -- uses treesitter to match keywords in comments only
          max_line_len = 1500,             -- ignore lines longer than this
          exclude = {},                    -- list of file types to exclude highlighting
        },
      })
    end,
  }
}
