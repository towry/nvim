local pack = require('ty.core.pack').editing
local config = require('ty.core.config').editing

--- lsp.
pack({
  'williamboman/mason.nvim',
  ImportOption = 'mason',
})
pack({
  'neovim/nvim-lspconfig',
  name = 'lsp',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'jose-elias-alvarez/typescript.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason-lspconfig.nvim',
    'j-hui/fidget.nvim',
  },
  Feature = 'lsp',
  ImportConfig = 'lspconfig',
  ImportInit = 'lspconfig',
})
pack({
  'glepnir/lspsaga.nvim',
  event = 'BufRead',
  dependencies = {
    --Please make sure you install markdown and markdown_inline parser
    { 'nvim-treesitter/nvim-treesitter' },
  },
  ImportConfig = 'lspsaga',
})
pack({
  'folke/neodev.nvim',
})

--- inlay hint for lsp.
pack({
  'lvimuser/lsp-inlayhints.nvim',
  event = 'LspAttach',
  config = true,
})

pack({
  'kevinhwang91/nvim-ufo',
  event = 'LspAttach',
  dependencies = {
    'kevinhwang91/promise-async',
  },
  ImportConfig = 'nvim_ufo',
})

pack({
  'dhruvasagar/vim-table-mode',
})

pack({
  'numToStr/Comment.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  ImportConfig = 'comment',
})

--[[
  switching between a single-line statement and a multi-line one

  The idea of this plugin is to introduce a single key binding (default: gS) for transforming a line like this:
  ```html
  <div id="foo">bar</div>
  ```
  into this:
  ```html
  <div id="foo">
    bar
  </div>
  ```
]]
pack({ 'AndrewRadev/splitjoin.vim', event = 'BufReadPost' })

pack({
  -- https://github.com/mg979/vim-visual-multi/wiki/Quick-start
  'mg979/vim-visual-multi',
  enabled = function() return config.visual_multi_cursor end,
  event = 'BufReadPost',
  config = function() vim.g.VM_leader = ';' end,
})

pack({
  -- easily switch variables, true <=> false
  'AndrewRadev/switch.vim',
  cmd = 'Switch',
  ImportConfig = 'switch',
})

pack({
  -- better yank.
  'gbprod/yanky.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'mrjones2014/legendary.nvim',
  },
  ImportConfig = 'yanky',
})
