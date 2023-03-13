local pack = require('ty.core.pack').autocmp
-- all about code auto completion etc.

pack({
  'L3MON4D3/LuaSnip',
  lazy = true,
  dependencies = { 'rafamadriz/friendly-snippets', 'saadparwaiz1/cmp_luasnip' },
})

-- nvim-cmp
pack({
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  Feature = 'autocomplete',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'onsails/lspkind-nvim',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-calc',
    {
      'tzachar/cmp-tabnine',
      build = './install.sh',
    },
    'David-Kunz/cmp-npm',
    'saadparwaiz1/cmp_luasnip',
  },
  config = function() require('ty.contrib.autocmp.cmp_rc').setup_cmp() end,
})

pack({
  'pze/codeium.nvim',
  cmd = 'Codeium',
  dev = false,
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = true,
})

-- autopairs
pack({
  'windwp/nvim-autopairs',
  -- lazy = false,
  event = { 'InsertEnter' },
  Feature = 'autocomplete',
  config = function() require('ty.contrib.autocmp.autopairs_rc').setup() end,
})

pack({
  -- https://github.com/dermoumi/dotfiles/blob/418de1a521e4f4ac6dc0aa10e75ffb890b0cb908/nvim/lua/plugins/copilot.lua#L4
  'github/copilot.vim',
  event = { 'InsertEnter' },
  keys = { { '<C-_>', mode = 'i' } },
  cmd = { 'Copilot' },
  config = function()
    -- vim.keymap.set({ "i" }, "<C-e>", [[copilot#Accept("")]], {
    --   silent = true,
    --   expr = true,
    --   script = true,
    -- })
    vim.keymap.set({ 'i' }, '<C-_>', 'copilot#Suggest()', {
      silent = true,
      expr = true,
      script = true,
    })
    -- not useful
    vim.keymap.set({ 'n' }, '<S-l>', function()
      if vim.b._copilot and vim.b._copilot.suggestions ~= nil then
        -- Make sure the suggestion exists and it does not start with whitespace
        -- This is to prevent the user from accidentally selecting a suggestion
        -- when trying to indent
        local suggestion = vim.b._copilot.suggestions[1]
        if suggestion ~= nil then suggestion = suggestion.displayText end
        if suggestion == nil or (suggestion:find('^%s') ~= nil and suggestion:find('^\n') == nil) then
          return 'L'
        else
          return "copilot#Accept('')"
        end
      else
        return 'L'
      end
    end, {
      silent = true,
      expr = true,
      script = true,
    })
  end,
  init = function()
    vim.g.copilot_filetypes = {
      ["*"] = true,
      ['TelescopePrompt'] = false,
      ['TelescopeResults'] = false,
    }
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_tab_fallback = ''
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_proxy = '127.0.0.1:1080'
    vim.g.copilot_proxy_strict_ssl = false
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      pattern = 'copilot.*',
      callback = function(ctx)
        vim.keymap.set('n', 'q', '<cmd>close<cr>', {
          silent = true,
          buffer = ctx.buf,
          noremap = true,
        })
      end,
    })
  end,
})
