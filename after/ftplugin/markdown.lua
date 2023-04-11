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
  -- fix lspsaga floating window hl.
  -- @see https://github.com/sainnhe/everforest/blob/master/colors/everforest.vim
  local ns = vim.api.nvim_create_namespace('markdown')
  vim.api.nvim_win_set_hl_ns(0, ns)

  -- remove the undercurl in the diagnostics float window.
  -- because it makes it hard to read the error messages.
  vim.cmd('hi! link ErrorText Normal')
  vim.cmd('hi! link WarningText Normal')
  vim.cmd('hi! link InfoText Normal')
  vim.cmd('hi! link HintText Normal')
end
