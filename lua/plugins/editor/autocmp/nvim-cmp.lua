return {
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = { 'rafamadriz/friendly-snippets', 'saadparwaiz1/cmp_luasnip' },
  },
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
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
    config = function()
      local lspkind = require('lspkind')
      local icons = require('libs.icons')

      local cmp_tabnine_status_ok, tabnine = pcall(require, 'cmp_tabnine.config')
      if not cmp_tabnine_status_ok then return end

      local cmp_status_ok, cmp = pcall(require, 'cmp')
      if not cmp_status_ok then return end

      local snip_status_ok, luasnip = pcall(require, 'luasnip')
      if not snip_status_ok then return end

      -- TODO: move to config
      local select_first_on_enter = false

      -- make sure the package.json exists and is valid json file.
      luasnip.log.set_loglevel('error')
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = {
          './user-snippets',
          vim.loop.cwd() .. '/.vscode',
        },
      })

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Utils                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      local types = require('cmp.types')

      local check_backspace = function()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
      end

      local function deprioritize_snippet(entry1, entry2)
        if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then return false end
        if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then return true end
      end

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Setup                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      local source_mapping = {
        npm = icons.terminal .. 'NPM',
        cmp_tabnine = icons.light,
        codeium = icons.pie .. 'AI',
        nvim_lsp = icons.paragraph .. 'LSP',
        nvim_lsp_signature_help = icons.typeParameter .. 'ARG',
        buffer = icons.buffer .. 'BUF',
        nvim_lua = icons.bomb,
        luasnip = icons.snippet .. 'SNP',
        calc = icons.calculator,
        path = icons.folderOpen2,
        treesitter = icons.tree,
        zsh = icons.terminal .. 'ZSH',
      }

      local buffer_option = {
        -- Complete from all visible buffers (splits)
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          return vim.tbl_keys(bufs)
        end,
      }

      cmp.setup({
        performance = {
          max_view_entries = 5,
          -- debounce = 250,
          -- throttle = 2000,
          -- fetching_timeoul = 1400,
        },
        -- https://github.com/hrsh7th/nvim-cmp/issues/1271
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          -- invoke complete
          ['<C-s>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = select_first_on_enter }),
          ['<S-CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<Tab>'] = cmp.mapping(function(fallback)
            local entry = cmp.get_selected_entry()
            if not entry and vim.b._copilot and vim.b._copilot.suggestions ~= nil then
              -- Make sure the suggestion exists and it does not start with whitespace
              -- This is to prevent the user from accidentally selecting a suggestion
              -- when trying to indent
              local suggestion = vim.b._copilot.suggestions[1]
              if suggestion ~= nil then suggestion = suggestion.displayText end
              if suggestion == nil or (suggestion:find('^%s') ~= nil and suggestion:find('^\n') == nil) then
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              else
                vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
              end
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
          ['<C-l>'] = cmp.mapping(function(fallback)
            if luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
          ['<C-h>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            'i',
            's',
          }),
        }),
        completion = {
          -- this is important
          -- @see https://github.com/hrsh7th/nvim-cmp/discussions/1411
          completeopt = 'menu,menuone,noinsert,noselect',
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, { with_text = true })
            local menu = source_mapping[entry.source.name]
            local maxwidth = 50

            if entry.source.name == 'cmp_tabnine' then
              if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
                menu = menu .. entry.completion_item.data.detail
              else
                menu = menu .. 'TBN'
              end
            end

            vim_item.menu = menu
            vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)

            return vim_item
          end,
        },
        -- You should specify your *installed* sources.
        sources = {
          { name = 'nvim_lsp',                priority = 50, max_item_count = 6 },
          -- { name = 'codeium', priority = 7,   },
          { name = 'nvim_lsp_signature_help', priority = 40 },
          { name = 'npm',                     priority = 3 },
          { name = 'cmp_tabnine',             priority = 6,  max_item_count = 3 },
          { name = 'luasnip',                 priority = 6,  max_item_count = 4 },
          {
            name = 'buffer',
            priority = 6,
            keyword_length = 4,
            option = buffer_option,
          },
          { name = 'nvim_lua', priority = 5, ft = 'lua' },
          { name = 'path',     priority = 4 },
          { name = 'calc',     priority = 3 },
        },
        sorting = {
          comparators = {
            deprioritize_snippet,
            cmp.config.compare.score,
            cmp.config.compare.exact,
            cmp.config.compare.locality,
            cmp.config.compare.recently_used,
            cmp.config.compare.order,
            cmp.config.compare.offset,
            cmp.config.compare.sort_text,
          },
        },
        confirmation = {
          -- get_commit_characters = function (commit_characters) return { '.', ')' } end,
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = 'CursorLine:CmpMenuSel,NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          }),
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      })

      -- ╭───────────────────────────────────────────────────�������──────╮
      -- │ Cmdline Setup                                            │
      -- ╰──────────────────────────────────────────────────────────╯

      -- `/` cmdline setup.
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })

      -- ╭────────-─────────────────────────────────────────────────╮
      -- │ Tabnine Setup                                            │
      -- ╰──────────────────────────────────────────────────────────╯
      tabnine:setup({
        max_lines = 1000,
        max_num_results = 3,
        sort = true,
        show_prediction_strength = true,
        run_on_every_keystroke = true,
        snipper_placeholder = '..',
        ignored_file_types = {},
      })
      -- cmp npm
      require('cmp-npm').setup({
        ignore = {},
        only_semantic_versions = true,
      })

      -- hls
      local au = require('libs.runtime.au')
      au.register_event(au.events.AfterColorschemeChanged, {
        name = 'update_cmp_hl',
        immediate = true,
        callback = function()
          vim.api.nvim_set_hl(0, 'CmpMenuSel', {
            bg = '#a7c080',
            fg = '#ffffff',
            bold = true,
          })
        end,
      })
    end,
  }
}
