-- https://github.com/echasnovski/nvim/blob/master/after/ftplugin/markdown.lua
vim.cmd([[setlocal nospell]])

require('ty.core.utils').try(
  function()
    require('legendary').command({
      'MarkdownPreviewToggle',
      description = 'Toggle markdown preview',
    })
  end
)

do
  -- NOTE: currently modified for theme everforest.
  -- fix lspsaga floating window hl.
  -- @see https://github.com/sainnhe/everforest/blob/master/colors/everforest.vim
  local ns = vim.api.nvim_create_namespace('markdown')
  vim.api.nvim_win_set_hl_ns(0, ns)

  vim.api.nvim_set_hl(ns, 'ErrorText', { link = 'Normal' })
  vim.api.nvim_set_hl(ns, 'WarningText', { link = 'Normal' })
  vim.api.nvim_set_hl(ns, 'InfoText', { link = 'Normal' })
  vim.api.nvim_set_hl(ns, 'HintText', { link = 'Normal' })
end
