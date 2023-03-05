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
