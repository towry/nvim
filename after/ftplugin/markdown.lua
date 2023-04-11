-- https://github.com/echasnovski/nvim/blob/master/after/ftplugin/markdown.lua
vim.cmd([[setlocal nospell]])
vim.b.miniindentscope_disable = true

require('ty.core.utils').try(
  function()
    require('legendary').command({
      'MarkdownPreviewToggle',
      description = 'Toggle markdown preview',
    })
  end
)

if vim.bo.buftype == "nofile" then
  local Util = require('ty.core.utils')
  -- NOTE: currently modified for theme everforest.
  -- fix lspsaga floating window hl.
  -- @see https://github.com/sainnhe/everforest/blob/master/colors/everforest.vim
  local ns = vim.api.nvim_create_namespace('markdown')
  vim.api.nvim_win_set_hl_ns(0, ns)

  Util.extend_hl('ErrorText', { undercurl = false, cterm = { undercurl = false } }, ns)
  Util.extend_hl('WarningText', { undercurl = false, cterm = { undercurl = false } }, ns)
  Util.extend_hl('InfoText', { undercurl = false, cterm = { undercurl = false } }, ns)
  Util.extend_hl('HintText', { undercurl = false, cterm = { undercurl = false } }, ns)
end
