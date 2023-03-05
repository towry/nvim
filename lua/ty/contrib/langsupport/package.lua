local config = require('ty.core.config')
local pack = require('ty.core.pack').langsupport

pack({
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = function()
    if #vim.api.nvim_list_uis() == 0 then
      -- update sync if running headless
      vim.cmd.TSUpdateSync()
    else
      -- otherwise update async
      vim.cmd.TSUpdate()
    end
  end,
  dependencies = {
    'yioneko/nvim-yati',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'RRethy/nvim-treesitter-textsubjects',
    'nvim-treesitter/nvim-treesitter-refactor',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'mrjones2014/nvim-ts-rainbow',
    -- 'kiyoon/treesitter-indent-object.nvim',
  },
  ImportConfig = 'treesitter',
})

pack({
  'iamcco/markdown-preview.nvim',
  build = 'cd app && npm install',
  init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  ft = { 'markdown' },
})

--- package.json
pack({
  'vuki656/package-info.nvim',
  event = 'BufEnter package.json',
  ImportConfig = 'package_info',
})

-- document etc.
pack({
  'danymat/neogen',
  cmd = 'Neogen',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = true,
})

-- Show color in source code.
pack({
  'NvChad/nvim-colorizer.lua',
  ft = config.langsupport.colorizer_ft,
  ImportOption = 'colorizer',
  Feature = 'colorizer',
})

-- Highlight arguments' definitions and usages, asynchronously, using Treesitter
pack({
  'm-demare/hlargs.nvim',
  event = 'BufReadPost',
  ImportOption = 'hlargs',
})

pack({
  'axelvc/template-string.nvim',
  ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'python' },
  ImportOption = 'template_string',
})
