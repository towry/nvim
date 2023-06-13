local plug = require('libs.runtime.pack').plug
local au = require('libs.runtime.au')

plug({
  {
    'tzachar/highlight-undo.nvim',
    keys = { 'u', '<C-r>' },
    opts = {
      hlgroup = 'IncSearch',
      duration = 800,
    }
  },

  {
    'mawkler/modicator.nvim',
    enabled = false,
    cond = vim.o.termguicolors == true,
    opts = {},
    event = au.user_autocmds.FileOpened_User,
  },

  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        timeout = '3000',
        max_width = function() return math.floor(vim.o.columns * 0.75) end,
        max_height = function() return math.floor(vim.o.lines * 0.75) end,
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_config(win, { border = 'rounded' }) end
        end,
        render = function(...)
          -- local notif = select(2, ...)
          local style = 'default'
          -- local style = notif.title[1] == '' and 'default' or 'default'
          require('notify.render')[style](...)
        end,
      })
    end,
    init = function()
      local banned_msgs = {
        'No information available',
        'LSP[tsserver] Inlay Hints request failed. File not opened in the editor.',
        'LSP[tsserver] Inlay Hints request failed. Requires TypeScript 4.4+.',
      }
      vim.notify = function(msg, ...)
        -- check banned_msgs contains msg with reg match
        if vim.tbl_contains(banned_msgs, msg) then return end

        require('notify')(msg, ...)
      end
    end,
  }
})
