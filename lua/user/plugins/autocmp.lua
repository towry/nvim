local au = require('userlib.runtime.au')
local pack = require('userlib.runtime.pack')
local Path = require('userlib.runtime.path')
local libutils = require('userlib.runtime.utils')

local enable_cody = false

local MAX_INDEX_FILE_SIZE = 2000

pack.plug({
  {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    build = function(plug)
      local cwd = plug.dir
      vim.cmd(string.format('tabe term://%s//%s', cwd, 'make .venv/bin/mypy ; python3 -u -m coq deps'))
    end,
    cmd = {
      'COQhelp',
      'COQnow',
      'COQdeps',
    },
    dependencies = {
      { 'ms-jpq/coq.artifacts', branch = 'artifacts' },
      {
        'ms-jpq/coq.thirdparty',
        branch = '3p',
      },
    },
    enabled = vim.cfg.edit__use_coq_cmp and vim.cfg.edit__use_native_cmp,
    event = { 'LspAttach', 'User LazyInsertEnter', 'CmdlineEnter' },
    lazy = true,
    config = function() end,
    init = function()
      -- https://github.com/ms-jpq/coq_nvim/blob/4337cb19c7bd922fa9b374456470a753dc1618d4/config/defaults.yml#L1C1-L1C1
      vim.g.coq_settings = {
        auto_start = 'shut-up',
        keymap = {
          recommended = false,
          manual_complete = '',
          jump_to_mark = '',
          bigger_preview = '',
        },
        display = {
          ghost_text = {
            --- chars surrounding the ghost_text for current selection item.
            context = { ' ', '' },
          },
          pum = {
            fast_close = false,
          },
        },
        -- https://github.com/ms-jpq/coq_nvim/blob/coq/docs/FUZZY.md
        weights = {
          prefix_matches = 4,
        },
        clients = {
          lsp = {
            resolve_timeout = 0.04,
            weight_adjust = 1,
          },
          -- high cpu
          tabnine = {
            enabled = false,
          },
        },
        completion = {
          skip_after = { ';', ',', ':', '[', ']', '{', '}', ' ', '`' },
        },
      }
    end,
  },
  {
    'echasnovski/mini.completion',
    dependencies = {
      'echasnovski/mini.fuzzy',
    },
    enabled = vim.cfg.edit__use_native_cmp and not vim.cfg.edit__use_coq_cmp,
    event = { 'LspAttach', 'User LazyInsertEnter' },
    config = function()
      local MC = require('mini.completion')
      local MiniFuzzy = require('mini.fuzzy')
      MC.setup({
        set_vim_settings = false,
        -- h: ins-completion
        fallback_action = vim.schedule_wrap(function()
          if vim.bo.completefunc and vim.bo.completefunc ~= '' then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-u>', true, false, true), 'i', false)
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-g><C-g><C-n>', true, false, true), 'n', false)
        end),
        delay = { completion = 250, info = 250, signature = 100 },
        lsp_completion = {
          source_func = 'omnifunc',
          auto_setup = false,
          process_items = function(items, base)
            -- Don't show 'Text' and 'Snippet' suggestions
            items = vim.tbl_filter(function(x)
              -- TODO: remove this when neovim cmp sideeffect is done.
              return x.kind ~= 15
              -- return x.kind ~= 1 and x.kind ~= 15
            end, items)
            -- return MC.default_process_items(items, base)
            -- better
            return MiniFuzzy.process_lsp_items(items, base)
          end,
        },
        window = {
          info = { border = 'solid', winblend = 30 },
          signature = { border = 'single', winblend = 80 },
        },
      })
    end,
    init = function()
      au.on_lsp_attach(function(_, bufnr)
        vim.api.nvim_set_option_value('omnifunc', 'v:lua.MiniCompletion.completefunc_lsp', {
          buf = bufnr,
        })
      end)
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    event = 'User LazyInsertEnter',
    build = 'make install_jsregexp',
    version = 'v2.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      --'saadparwaiz1/cmp_luasnip'
    },
    config = function()
      local luasnip = require('luasnip')
      luasnip.config.set_config({
        -- update_events = { 'TextChangedI', 'TextChanged' },
      })
      -- make sure the package.json exists and is valid json file.
      luasnip.log.set_loglevel('error')
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = {
          './user-snippets',
          vim.uv.cwd() .. '/.vscode',
          Path.path_join(vim.cfg.runtime__starts_cwd, '.vscode'),
        },
      })

      local luasnip_ns = vim.api.nvim_create_namespace('luasnip')

      Ty.luasnip_notify_clear = function()
        vim.api.nvim_buf_clear_namespace(0, luasnip_ns, 0, -1)
      end

      Ty.luasnip_notify = function()
        Ty.luasnip_notify_clear()
        if not luasnip.expandable() then
          return
        end

        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_set_extmark(0, luasnip_ns, line, 0, {
          virt_text = { { '!', 'Special' } },
          virt_text_pos = 'eol',
        })
      end

      -- vim.cmd([[au InsertEnter,CursorMovedI,TextChangedI,TextChangedP * lua pcall(Ty.luasnip_notify)]])
      -- vim.cmd([[au InsertLeave * lua pcall(Ty.luasnip_notify_clear)]])
    end,
  },
  {
    'petertriho/cmp-git',
    ft = 'gitcommit',
    enabled = vim.cfg.edit__use_plugin_cmp,
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
    'lukas-reineke/cmp-rg',
    cond = function()
      return vim.fn.executable('rg') == 1 and vim.cfg.edit__use_plugin_cmp
    end,
    ft = 'rgflow',
    dependencies = {
      'hrsh7th/nvim-cmp',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup.filetype('rgflow', {
        sources = cmp.config.sources({
          { name = 'rg' },
        }, {
          { name = 'buffer' },
        }),
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    enabled = vim.cfg.edit__use_plugin_cmp,
    event = { 'User LazyInsertEnter', 'CmdlineEnter' },
    dependencies = {
      'noearc/cmp-registers',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'onsails/lspkind-nvim',
      -- 'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      -- 'dmitmel/cmp-cmdline-history',
      -- {
      --   'tzachar/cmp-tabnine',
      --   build = './install.sh',
      -- },
      'David-Kunz/cmp-npm',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local has_words_before = function()
        if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then
          return false
        end
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

      -- local cmp_tabnine_status_ok, tabnine = pcall(require, 'cmp_tabnine.config')
      -- if not cmp_tabnine_status_ok then return end

      local cmp_status_ok, cmp = pcall(require, 'cmp')
      if not cmp_status_ok then
        return
      end

      local snip_status_ok, luasnip = pcall(require, 'luasnip')
      if not snip_status_ok then
        return
      end

      -- TODO: move to config
      local select_first_on_enter = false

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Utils                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      local types = require('cmp.types')

      local check_backspace = function()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
      end

      local function deprioritize_snippet(entry1, entry2)
        if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
          return false
        end
        if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
          return true
        end
      end

      local buffer_option = {
        -- Complete from all visible buffers (splits)
        get_bufnrs = function()
          if vim.b.is_big_file then
            return {}
          end
          --- from all loaded buffers
          local bufs = {}
          local loaded_bufs = vim.api.nvim_list_bufs()
          for _, bufnr in ipairs(loaded_bufs) do
            -- Don't index giant files
            if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE then
              table.insert(bufs, bufnr)
            end
          end
          return bufs
          -- ----
          -- from visible bufs.
          -- local bufs = {}
          -- for _, win in ipairs(vim.api.nvim_list_wins()) do
          --   bufs[vim.api.nvim_win_get_buf(win)] = true
          -- end
          -- --- alternative buf.
          -- local alter = vim.fn.bufnr('#')
          -- if alter > 0 then bufs[vim.fn.bufnr('#')] = true end
          -- return vim.tbl_keys(bufs)
        end,
      }
      local select_option = {
        behavior = cmp.SelectBehavior.Insert,
      }

      local cmp_options = {
        enabled = function()
          return not vim.b.is_big_file
        end,
        performance = {
          max_view_entries = 15,
          -- debounce = 250,
          -- throttle = 2000,
          -- fetching_timeoul = 1400,
        },
        -- https://github.com/hrsh7th/nvim-cmp/issues/1271
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(select_option),
          ['<C-n>'] = cmp.mapping.select_next_item(select_option),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(function(fallback)
            if vim.bo.buftype == 'prompt' then
              return fallback()
            end
            local entry = cmp.get_selected_entry()
            -- copilot.vim
            if not entry and Ty.has_ai_suggestions() then
              if not Ty.has_ai_suggestion_text() then
                if cmp.visible() and has_words_before() then
                  cmp.confirm({ select = true })
                else
                  fallback()
                end
              else
                if vim.b._copilot then
                  vim.fn.feedkeys(vim.fn['copilot#Accept'](), 'i')
                elseif vim.b._codeium_completions then
                  vim.fn.feedkeys(vim.fn['codeium#Accept'](), 'i')
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
          ['<CR>'] = cmp.mapping.confirm({
            select = select_first_on_enter,
            behavior = cmp.ConfirmBehavior.Replace,
          }),
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
              require('neotab').tabout()
              -- fallback()
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
              -- require('neotab').tabout()
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
          completeopt = 'menuone,noinsert,noselect',
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'text_symbol',
            maxwidth = 40,
          }),
        },
        -- You should specify your *installed* sources.
        sources = {
          { name = 'nvim_lsp', priority = 10, max_item_count = 5 },
          -- { name = "copilot",                 priority = 30, max_item_count = 4 },
          -- { name = 'codeium', priority = 7, max_item_count = 4 },
          { name = 'nvim_lsp_signature_help', priority = 10, max_item_count = 3 },
          { name = 'npm', priority = 3 },
          -- { name = 'cmp_tabnine',             priority = 6,  max_item_count = 3 },
          { name = 'luasnip', priority = 6, max_item_count = 2 },
          {
            name = 'buffer',
            priority = 8,
            keyword_length = 2,
            option = buffer_option,
            max_item_count = 4,
          },
          -- { name = 'nvim_lua', priority = 5, ft = 'lua' },
          { name = 'path', priority = 4 },
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
            winhighlight = 'CursorLine:PmenuSel,NormalFloat:NormalFloat,FloatBorder:FloatBorder',
            winblend = 0,
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
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
      }

      if enable_cody and libutils.has_plugin('sg.nvim') then
        -- insert cody source to cmp source
        table.insert(cmp_options.sources, {
          name = 'cody',
          priority = 9,
          max_item_count = 4,
        })
      end

      cmp.setup(cmp_options)

      -- `/` cmdline setup.
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
          { name = 'registers' },
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
          { name = 'registers' },
          -- { name = 'cmdline_history', max_item_count = 3, },
        }),
      })

      -- ╭────────-─────────────────────────────────────────────────╮
      -- │ Tabnine Setup                                            │
      -- ╰──────────────────────────────────────────────────────────╯
      -- tabnine:setup({
      --   max_lines = 30,
      --   max_num_results = 3,
      --   sort = false,
      --   show_prediction_strength = false,
      --   run_on_every_keystroke = false,
      --   snipper_placeholder = '..',
      --   ignored_file_types = vim.cfg.misc__ignored_file_types,
      -- })
      -- cmp npm
      require('cmp-npm').setup({
        ignore = {},
        only_semantic_versions = true,
      })

      vim.api.nvim_create_user_command('CmpInfo', function()
        cmp.status()
      end, {})
    end,
  },
})

pack.plug({
  'kawre/neotab.nvim',
  event = 'InsertEnter',
  opts = {
    tabkey = '',
  },
})

---autopairs
pack.plug({
  enabled = not vim.cfg.lang__treesitter_next,
  'windwp/nvim-autopairs',
  event = { 'InsertEnter' },
  config = function()
    local npairs = require('nvim-autopairs')
    local args = {
      disable_filetype = {
        'TelescopePrompt',
      },
      ignored_next_char = '[%w%.{("\']',
      disable_in_macro = true,
      disable_in_replace_mode = true,
      enable_check_bracket_line = true,
      check_ts = false,
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
      },
    }
    npairs.setup(args)

    if vim.cfg.edit__use_plugin_cmp then
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmpcore = require('cmp')

      local Kind = cmpcore.lsp.CompletionItemKind
      local handlers = require('nvim-autopairs.completion.handlers')
      local default_handler = function(char, item, bufnr, commit_character)
        -- do not add pairs if commit characters exists, like `.`, or `,`.
        if commit_character ~= nil then
          return
        end
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
    end --- end cmp setup

    --- setup rules.
    -- TODO: move to config.
    local allowed_rules = {
      -- 'auto_jsx_closing',
    }
    local rules = require('userlib.autopairs-rules')
    for _, rule in ipairs(allowed_rules) do
      -- if rule exist in module and is a function, call it.
      if rules[rule] and type(rules[rule]) == 'function' then
        rules[rule]()
      end
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
    enabled = vim.cfg.plug__enable_codeium_nvim,
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
    keys = {
      {
        '<M-u>',
        function()
          if Ty.has_ai_suggestion_text() then
            local cmp = require('cmp')
            if cmp.visible() then
              cmp.close()
            end

            return vim.fn['codeium#CycleCompletions'](1)
          end
        end,
        mode = 'i',
        desc = 'Cycle codeium completion next',
        expr = true,
      },
      {
        '<leader>ta',
        '<cmd>Codeium Toggle<cr>',
        desc = 'Toggle AI',
      },

      {
        '<M-y>',
        function()
          return vim.fn['codeium#Complete']()
        end,
        mode = 'i',
        desc = 'Manually trigger codeium suggestion',
        expr = true,
      },
    },
    enabled = vim.cfg.plug__enable_codeium_vim,
    config = function() end,
    init = function()
      vim.g.codeium_enabled = false
      vim.g.codeium_disable_bindings = 1
      vim.g.codeium_no_map_tab = true
      vim.g.codeium_filetypes = {
        ['*'] = true,
        ['gitcommit'] = true,
        ['fzf'] = false,
        ['TelescopePrompt'] = false,
        ['TelescopeResults'] = false,
      }
    end,
  },
  {
    -- https://github.com/dermoumi/dotfiles/blob/418de1a521e4f4ac6dc0aa10e75ffb890b0cb908/nvim/lua/plugins/copilot.lua#L4
    'github/copilot.vim',
    enabled = vim.cfg.plug__enable_copilot_vim,
    event = { 'InsertEnter' },
    keys = {
      {
        '<leader>zp',
        '<cmd>Copilot panel<cr>',
        desc = 'Open Copilot panel',
      },
      {
        '<leader>ta',
        '<cmd>ToggleCopilotAutoMode<cr>',
        desc = 'Toggle copilot',
      },
    },
    cmd = { 'Copilot' },
    config = function() end,
    init = au.schedule_lazy(function()
      vim.g.copilot_filetypes = {
        ['*'] = false, -- start manually
        ['fzf'] = false,
        ['TelescopePrompt'] = false,
        ['TelescopeResults'] = false,
        ['OverseerForm'] = false,
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
      vim.api.nvim_create_user_command('ToggleCopilotAutoMode', function()
        if vim.g.copilot_auto_mode == true then
          -- disable
          vim.g.copilot_auto_mode = false
          vim.g.copilot_filetypes = vim.tbl_extend('keep', {
            ['*'] = false,
          }, vim.g.copilot_filetypes)
          vim.notify('Copilot auto mode disabled X')
        else
          vim.g.copilot_auto_mode = true
          vim.g.copilot_filetypes = vim.tbl_extend('keep', {
            ['*'] = true,
          }, vim.g.copilot_filetypes)
          vim.notify('Copilot auto mode enabled ✔')
        end
        vim.api.nvim_exec_autocmds('User', {
          pattern = 'CopilotStatus',
        })
      end, {})
      vim.api.nvim_create_autocmd('LspRequest', {
        callback = function(args)
          local client_id = args.data.client_id
          -- get client name by client_id
          local client_name = vim.lsp.get_client_by_id(client_id).name
          if client_name ~= 'copilot' then
            return
          end
          local request = args.data.request
          if request.type == 'pending' then
            vim.g.copilot_status = 'pending'
            vim.notify('Copilot is thinking ...', nil, {
              annote = ' ',
              key = 'copilot',
            })
          elseif request.type == 'cancel' then
            vim.g.copilot_status = 'cancel'
            vim.notify('Copilot is cancelled', nil, {
              annote = ' ',
              key = 'copilot',
            })
          elseif request.type == 'complete' then
            vim.g.copilot_status = 'complete'
            vim.notify('Copilot is done', nil, {
              annote = ' ',
              key = 'copilot',
            })
          end
          -- trigger user autocmd
          vim.api.nvim_command('doautocmd User CopilotStatus')
        end,
      })
    end),
  },
})

pack.plug({
  --- require('sg.auth').get(): boolean check if authed.
  'sourcegraph/sg.nvim',
  event = 'VeryLazy',
  enabled = false,
  keys = {
    {
      '<leader>ai',
      '<cmd>CodyChat<cr>',
      desc = 'AI Assistant',
    },
    {
      '<leader>a<space>',
      '<cmd>CodyToggle<cr>',
      desc = 'Toggle cody view',
    },
    {
      '<leader>al',
      ':CodyTaskView<cr>',
      desc = 'Open last active cody task view',
    },
    {
      '<leader>ad',
      function()
        local doc = require('sg.cody.experimental.documentation')
        local start_line = vim.fn.line("'<") -- Get the start line of the visual selection
        local end_line = vim.fn.line("'>") -- Get the end line of the visual selection
        if not start_line or not end_line then
          return
        end
        doc.function_documentation(0, start_line, end_line)
      end,
      mode = 'v',
      desc = 'Experimental: Document the code',
    },
    {
      '<leader>a[',
      ':CodyTaskPrev<cr>',
      desc = 'Open prev cody task view',
    },
    {
      '<leader>a]',
      ':CodyTaskNext<cr>',
      desc = 'Open next cody task view',
    },
    {
      '<leader>ac',
      function()
        local ok, res = pcall(vim.fn.input, { prompt = 'CodyTask: ', cancelreturn = false })
        if not ok or res == false then
          return
        end
        vim.cmd(string.format(':CodyTask %s<cr>', res))
      end,
      mode = { 'n', 'v' },
      desc = 'Let AI Write Code',
    },
    {
      '<leader>aa',
      ':CodyTaskAccept<CR>',
      mode = 'n',
      desc = 'Confirm AI work',
    },
    {
      '<leader>aa',
      ':CodyAsk ',
      mode = { 'v', 'x' },
      desc = 'Ask Cody about selection',
    },
    {
      '<leader>ar',
      ':CodyAsk refactor following code<CR>',
      mode = { 'v', 'x' },
      desc = 'Request Refactoring',
    },
    {
      '<leader>ae',
      ':CodyAsk explain selected code<CR>',
      mode = { 'v', 'x' },
      desc = 'Request Explanation',
    },
    {
      '<leader>af',
      ':CodyAsk find potential vulnerabilities from following code<CR>',
      mode = { 'v', 'x' },
      desc = 'Request Potential Vulnerabilities',
    },
    {
      '<leader>at',
      ':CodyAsk rewrite following code more idiomatically<CR>',
      mode = { 'v', 'x' },
      desc = 'Request Idiomatic Rewrite',
    },
  },
  cmd = {
    'SourcegraphLogin',
    'SourcegraphLink',
    'SourcegraphSearch',
    'SourcegraphInfo',
    'SourcegraphBuild',
    'SourcegraphClear',
    'CodyAsk',
    'CodyChat',
    'CodyToggle',
    'CodyTask',
    'CodyTaskView',
    'CodyTaskAccept',
    'CodyTaskPrev',
    'CodyTaskNext',
    'CodyRestart',
    'CodyOpenDoc',
  },
  build = 'nvim -l build/init.lua',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    enable_cody = true,
    node_executable = Path.path_join(vim.env['FNM_DIR'], 'aliases/default/bin/node'),
    on_attach = function() end,
  },
  init = function()
    -- create user command: CodyOpenDoc to open https://sourcegraph.com/docs/cody/clients/install-neovim
    vim.api.nvim_create_user_command('CodyOpenDoc', function()
      vim.ui.open('https://sourcegraph.com/docs/cody/clients/install-neovim')
    end, {})
  end,
})

pack.plug({
  'towry/commit-msg-sg.nvim',
  dependencies = {
    'sourcegraph/sg.nvim',
  },
  enabled = false,
  dev = false,
  ft = 'gitcommit',
  opts = {
    on_attach = function(_, bufnr)
      local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

      set({ 'i', 'n' }, '<localleader>ac', function()
        CommitMsgSg.write()
      end, {
        desc = 'Write git commit message with AI',
        noremap = true,
      })
    end,
  },
})

pack.plug({
  'chrisgrieser/nvim-scissors',
  cmd = { 'NewSnippet', 'EditSnippet' },
  config = function()
    require('scissors').setup({
      snippetDir = vim.fn.stdpath('config') .. '/user-snippets',
      jsonFormatter = vim.fn.executable('jq') == 1 and 'jq' or 'none',
    })

    vim.api.nvim_create_user_command('NewSnippet', function()
      require('scissors').addNewSnippet()
    end, {
      desc = 'Create new snippet',
    })
    vim.api.nvim_create_user_command('EditSnippet', function()
      require('scissors').editSnippet()
    end, {
      desc = 'Edit snippet',
    })
  end,
})
