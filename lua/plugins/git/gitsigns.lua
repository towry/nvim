local au = require('libs.runtime.au')

local M = {
  'lewis6991/gitsigns.nvim',
  event = au.user_autocmds.FileOpened
}

local gitsigns_current_blame_delay = 0

M.config = function()
  local signs = require('gitsigns')
  local autocmd = require('libs.runtime.au')

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Setup                                                    │
  -- ╰──────────────────────────────────────────────────────────╯
  signs.setup({
    signs = {
      add = { hl = 'GitSignsAdd', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
      change = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
      delete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
      topdelete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
      changedelete = { hl = 'GitSignsChangeNr', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
      untracked = { hl = 'GitSignsAddNr', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = gitsigns_current_blame_delay,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
      -- Options passed to nvim_open_win
      border = vim.cfg.ui__float_border,
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
    yadm = {
      enable = false,
    },
    on_attach = function(bufnr)
      autocmd.fire_event(autocmd.events.onGitsignsAttach, {
        bufnr = bufnr,
      })
    end,
  })
end

return M
