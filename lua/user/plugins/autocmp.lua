local pack = require('userlib.runtime.pack')

pack.plug({
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    dependencies = { 'rafamadriz/friendly-snippets', 'saadparwaiz1/cmp_luasnip' },
  },
  {
    'petertriho/cmp-git',
    ft = 'gitcommit',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        }),
      })
    end,
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
      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match('^%s*$') == nil
      end
      local lspkind = require('lspkind')
      local icons = require('userlib.icons')

      lspkind.init({
        symbol_map = {
          Copilot = '',
        },
      })

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
          vim.uv.cwd() .. '/.vscode',
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
        codeium = icons.copilot .. 'AI',
        copilot = icons.copilot .. 'AI',
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
          --- from all loaded buffers
          -- return vim.api.nvim_list_bufs()
          -- ----
          -- from visible bufs.
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          --- alternative buf.
          local alter = vim.fn.bufnr('#')
          if alter > 0 then bufs[vim.fn.bufnr('#')] = true end
          return vim.tbl_keys(bufs)
        end,
      }
      local select_option = {
        behavior = cmp.SelectBehavior.Insert,
      }

      cmp.setup({
        performance = {
          max_view_entries = 15,
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
          ['<C-p>'] = cmp.mapping.select_prev_item(select_option),
          ['<C-n>'] = cmp.mapping.select_next_item(select_option),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(function(fallback)
            if vim.bo.buftype == 'prompt' then return fallback() end
            local entry = cmp.get_selected_entry()
            local has_ai_suggestions = (vim.b._copilot and vim.b._copilot.suggestions ~= nil)
              or (vim.b._codeium_completions and vim.b._codeium_completions.items ~= nil)
            local has_ai_suggestion_text = function()
              if vim.b._copilot and vim.b._copilot.suggestions ~= nil then
                local suggestion = vim.b._copilot.suggestions[1]
                if suggestion ~= nil then suggestion = suggestion.displayText end
                return suggestion ~= nil
              end

              if vim.b._codeium_completions and vim.b._codeium_completions.items then
                local index = vim.b._codeium_completions.index or 0
                local suggestion = vim.b._codeium_completions.items[index + 1] or {}
                local parts = suggestion.completionParts or {}
                if type(parts) ~= 'table' then return false end
                return #parts >= 1
              end

              return false
            end
            -- copilot.vim
            if not entry and has_ai_suggestions then
              if not has_ai_suggestion_text() then
                if cmp.visible() and has_words_before() then
                  cmp.confirm({ select = true })
                else
                  fallback()
                end
              else
                if vim.b._copilot then
                  vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
                elseif vim.b._codeium_completions then
                  vim.fn.feedkeys(vim.fn['codeium#Accept'](), '')
                end
              end
            elseif cmp.visible() and has_words_before() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end), -- invoke complete
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
            if cmp.visible() and has_words_before() then
              cmp.select_next_item(select_option)
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
          { name = 'nvim_lsp', priority = 50, max_item_count = 6 },
          -- { name = "copilot",                 priority = 30, max_item_count = 4 },
          { name = 'codeium', priority = 7, max_item_count = 4 },
          { name = 'nvim_lsp_signature_help', priority = 40, max_item_count = 3 },
          { name = 'npm', priority = 3 },
          -- { name = 'cmp_tabnine',             priority = 6,  max_item_count = 3 },
          { name = 'luasnip', priority = 6, max_item_count = 2 },
          {
            name = 'buffer',
            priority = 6,
            keyword_length = 2,
            option = buffer_option,
            max_item_count = 5,
          },
          { name = 'nvim_lua', priority = 5, ft = 'lua' },
          { name = 'path', priority = 4 },
          { name = 'calc', priority = 3 },
        },
        sorting = {
          comparators = {
            -- require("copilot_cmp.comparators").prioritize,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,

            deprioritize_snippet,
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find('^_+')
              local _, entry2_under = entry2.completion_item.label:find('^_+')
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
            cmp.config.compare.locality,
          },
        },
        confirmation = {
          -- get_commit_characters = function (commit_characters) return { '.', ')' } end,
        },
        window = {
          completion = cmp.config.window.bordered({
            border = vim.cfg.ui__float_border,
            winhighlight = 'CursorLine:CursorLine,NormalFloat:NormalFloat,FloatBorder:NormalFloat',
            winblend = 0,
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:NormalFloat',
            border = vim.cfg.ui__float_border,
          }),
        },
        experimental = {
          -- can be anoying.
          ghost_text = false,
          -- ghost_text = {
          --   hl_group = "LspCodeLens",
          -- },
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
        mapping = cmp.mapping.preset.cmdline({
          ['<C-p>'] = cmp.config.disable,
          ['<C-n>'] = cmp.config.disable,
        }),
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
        max_lines = 800,
        max_num_results = 3,
        sort = false,
        show_prediction_strength = false,
        run_on_every_keystroke = false,
        snipper_placeholder = '..',
        ignored_file_types = vim.cfg.misc__ignored_file_types,
      })
      -- cmp npm
      require('cmp-npm').setup({
        ignore = {},
        only_semantic_versions = true,
      })
    end,
  },
})

---autopairs
pack.plug({
  enabled = true,
  'windwp/nvim-autopairs',
  event = { 'InsertEnter' },
  config = function()
    local npairs = require('nvim-autopairs')
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmpcore = require('cmp')

    local args = {
      disable_filetype = {
        'TelescopePrompt',
      },
      ignored_next_char = '[%w%.{("\']',
      disable_in_macro = true,
      disable_in_replace_mode = true,
      enable_check_bracket_line = true,
      check_ts = true,
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
      },
    }
    npairs.setup(args)

    local Kind = cmpcore.lsp.CompletionItemKind
    local handlers = require('nvim-autopairs.completion.handlers')
    local default_handler = function(char, item, bufnr, commit_character)
      -- do not add pairs if commit characters exists, like `.`, or `,`.
      if commit_character ~= nil then return end
      -- do not add pairs if in jsx.
      local ts_current_line_node_type = Ty.TS_GET_NODE_TYPE()
      if
        vim.tbl_contains({ 'jsx_self_closing_element', 'jsx_opening_element' }, ts_current_line_node_type)
        and (item.kind == Kind.Function or item.kind == Kind.Method)
      then
        return
      end

      handlers['*'](char, item, bufnr, commit_character)
    end

    cmpcore.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done({
        filetypes = {
          ['*'] = {
            ['('] = {
              handler = default_handler,
            },
          },
          -- disable for tex
          tex = false,
        },
      })
    )
    --- setup rules.
    -- TODO: move to config.
    local allowed_rules = {
      'auto_jsx_closing',
    }
    local rules = require('userlib.autopairs-rules')
    for _, rule in ipairs(allowed_rules) do
      -- if rule exist in module and is a function, call it.
      if rules[rule] and type(rules[rule]) == 'function' then rules[rule]() end
    end
  end,
})

--- AI autocompletion tools.
pack.plug({
  {
    -- 'pze/codeium.nvim',
    'jcdickinson/codeium.nvim',
    cmd = 'Codeium',
    dev = false,
    event = { 'InsertEnter' },
    enabled = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      {
        'jcdickinson/http.nvim',
        build = 'cargo build --workspace --release',
      },
    },
    opts = {
      -- config_path = '~/.codeium/config.json'
    },
    init = function()
      --- https://github.com/jcdickinson/codeium.nvim/pull/74/files
      if not vim.ui.inputsecret then
        ---@param opts {on_submit:function,prompt:string}
        vim.ui.inputsecret = function(opts)
          opts = opts or {}
          local callback = opts.on_submit
          local prompt = opts.prompt or 'Input '
          local result = vim.fn.inputsecret(prompt)
          if result then
            callback(result)
          else
            callback(nil)
          end
        end
      end
    end,
  },
  {
    --- have bug when behind proxy.
    'Exafunction/codeium.vim',
    event = { 'InsertEnter' },
    cmd = { 'Codeium' },
    enabled = false,
    config = function()
      local set = vim.keymap.set

      set('i', '<M-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, {
        expr = true,
      })
      set('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, {
        expr = true,
      })
      -- force trigger ai completion.
      set('i', '<D-/>', function() return vim.fn['codeium#Complete']() end, {
        expr = true,
      })
    end,
    init = function()
      vim.g.codeium_disable_bindings = 1
      vim.g.codeium_no_map_tab = true
      vim.g.codeium_filetypes = {
        ['*'] = true,
        ['TelescopePrompt'] = false,
        ['TelescopeResults'] = false,
      }
    end,
  },
  {
    -- https://github.com/dermoumi/dotfiles/blob/418de1a521e4f4ac6dc0aa10e75ffb890b0cb908/nvim/lua/plugins/copilot.lua#L4
    'github/copilot.vim',
    enabled = false,
    event = { 'InsertEnter' },
    keys = {
      { '<C-/>', mode = 'i' },
      {
        '<leader>zp',
        '<cmd>Copilot panel<cr>',
        desc = 'Open Copilot panel',
      },
    },
    cmd = { 'Copilot' },
    config = function()
      -- <C-/>
      vim.keymap.set({ 'i' }, '<C-/>', 'copilot#Suggest()', {
        silent = true,
        expr = true,
        script = true,
      })
    end,
    init = function()
      vim.g.copilot_filetypes = {
        ['*'] = true,
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
  },
})
