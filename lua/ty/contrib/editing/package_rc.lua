local M = {}

M.setup_lspconfig = require('ty.contrib.editing.lsp').setup
M.init_lspconfig = require('ty.contrib.editing.lsp').init
M.setup_nvim_ufo = require('ty.contrib.editing.folding').setup_ufo
M.setup_switch = require('ty.contrib.editing.switch_rc').setup
M.setup_yanky = require('ty.contrib.editing.yanky_rc').setup
M.setup_lspsaga = function()
  require('lspsaga').setup({
    request_timeout = 1500,
    code_action = {
      num_shortcut = true,
      show_server_name = true,
      extend_gitsigns = true,
      keys = {
        -- string | table type
        quit = '<ESC>',
        exec = '<CR>',
      },
    },
    lightbulb = {
      enable = false,
      enable_in_insert = false,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    diagnostic = {
      on_insert = false,
      on_insert_follow = false,
      show_virt_line = false,
      border_follow = true,
      text_hl_follow = true,
      show_code_action = false,
      keys = {
        quit = '<ESC>',
      },
    },
    callhierarchy = {
      keys = {
        quit = '<ESC>',
        vsplit = 'v',
        split = 'x',
      },
    },
    symbol_in_winbar = {
      enable = false,
    },
    beacon = {
      enable = false,
    },
    ui = {
      border = Ty.Config.ui.float.border, -- single, double, rounded, solid, shadow.
      winblend = 1,
    },
  })

  require('ty.core.autocmd').do_need_hl_update()
end

M.setup_comment = function()
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
end
M.option_mason = {
  PATH = 'prepend',
  ui = {
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = Ty.Config.ui.float.border or 'rounded',
  },
}
return M
