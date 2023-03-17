local pack = require('ty.core.pack').ui

pack({
  'ellisonleao/gruvbox.nvim',
  enabled = false,
  -- make sure we load this during startup if it is your main colorscheme
  lazy = false,
  -- make sure to load this before all the other start plugins
  priority = 1000,
  ImportConfig = 'gruvbo',
})

pack({
  'sainnhe/everforest',
  lazy = false,
  priority = 1000,
  ImportInit = 'everforest',
})

--- libs.
---
pack({ 'nvim-lua/popup.nvim' })
pack({
  'MunifTanjim/nui.nvim',
})
pack({
  'stevearc/dressing.nvim',
  init = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require('ty.core.pack').load({ plugins = { 'dressing.nvim' } })
      return vim.ui.select(...)
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.input = function(...)
      require('ty.core.pack').load({ plugins = { 'dressing.nvim' } })
      return vim.ui.input(...)
    end
  end,
  ImportConfig = 'dressing',
})
pack({
  'rcarriga/nvim-notify',
  init = function()
    local banned_msgs = {
      "No information available",
      "LSP[tsserver] Inlay Hints request failed. File not opened in the editor.",
      "LSP[tsserver] Inlay Hints request failed. Requires TypeScript 4.4+.",
    }
    vim.notify = function(msg, ...)
      -- check banned_msgs contains msg with reg match
      if vim.tbl_contains(banned_msgs, msg) then
        return
      end

      require('notify')(msg, ...)
    end
  end,
  ImportConfig = 'notify',
})
