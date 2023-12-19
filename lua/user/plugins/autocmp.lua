local pack = require('userlib.runtime.pack')
local Path = require('userlib.runtime.path')

local has_ai_suggestions = function()
  return (vim.b._copilot and vim.b._copilot.suggestions ~= nil)
      or (vim.b._codeium_completions and vim.b._codeium_completions.items ~= nil)
end
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

local MAX_INDEX_FILE_SIZE = 2000

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
    'lukas-reineke/cmp-rg',
    cond = function()
      return vim.fn.executable('rg')
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
    end
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
      -- 'dmitmel/cmp-cmdline-history',
      'hrsh7th/cmp-calc',
      -- {
      --   'tzachar/cmp-tabnine',
      --   build = './install.sh',
      -- },
      'David-Kunz/cmp-npm',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local has_words_before = function()
        if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then return false end
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
          Path.path_join(vim.cfg.runtime__starts_cwd, '.vscode'),
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
            -- copilot.vim
            if not entry and has_ai_suggestions() then
              if not has_ai_suggestion_text() then
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
          end),                           -- invoke complete
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
          { name = 'nvim_lsp',                priority = 10, max_item_count = 5 },
          -- { name = "copilot",                 priority = 30, max_item_count = 4 },
          -- { name = 'codeium', priority = 7, max_item_count = 4 },
          { name = 'nvim_lsp_signature_help', priority = 10, max_item_count = 3 },
          { name = 'npm',                     priority = 3 },
          -- { name = 'cmp_tabnine',             priority = 6,  max_item_count = 3 },
          { name = 'luasnip',                 priority = 6,  max_item_count = 2 },
          {
            name = 'buffer',
            priority = 10,
            keyword_length = 2,
            option = buffer_option,
            max_item_count = 4,
          },
          { name = 'nvim_lua', priority = 5, ft = 'lua' },
          { name = 'path',     priority = 4 },
          { name = 'calc',     priority = 3 },
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
      })


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
          },
          {
            { name = 'cmdline', },
            -- { name = 'cmdline_history', max_item_count = 3, },
          }
        ),
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

      vim.api.nvim_create_user_command("CmpInfo", function()
        cmp.status()
      end, {})
    end,
  },
})

---autopairs
pack.plug({
  enabled = not vim.cfg.lang__treesitter_next,
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
      if vim.tbl_contains({ 'jsx_self_closing_element', 'jsx_opening_element' }, ts_current_line_node_type)
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
    enabled = vim.cfg.plug__enable_codeium_vim,
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
    enabled = vim.cfg.plug__enable_codeium_vim,
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
    enabled = true,
    event = { 'InsertEnter' },
    keys = {
      {
        '<C-]>',
        function()
          if vim.b.copilot_enabled == false then return end
          local cmp = require('cmp')
          if cmp.visible() then cmp.close() end
          if has_ai_suggestion_text() then
            vim.cmd([[call copilot#Next()]])
          else
            vim.cmd([[call copilot#Schedule()]])
            vim.cmd([[call copilot#Suggest()]])
          end
        end,
        mode = 'i',
        silent = false,
      },
      {
        '<leader>zp',
        '<cmd>Copilot panel<cr>',
        desc = 'Open Copilot panel',
      },
      {
        '<leader>tc',
        '<cmd>ToggleCopilotAutoMode<cr>',
        desc = 'Toggle copilot',
      }
    },
    cmd = { 'Copilot' },
    config = function()
    end,
    init = function()
      vim.g.copilot_filetypes = {
        ['*'] = false,
        ['TelescopePrompt'] = false,
        ['TelescopeResults'] = false,
        ['OverseerForm'] = true,
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
            ["*"] = false
          }, vim.g.copilot_filetypes)
          vim.notify("Copilot auto mode disabled X")
        else
          vim.g.copilot_auto_mode = true
          vim.g.copilot_filetypes = vim.tbl_extend('keep', {
            ["*"] = true
          }, vim.g.copilot_filetypes)
          vim.notify("Copilot auto mode enabled ✔")
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
          if client_name ~= 'copilot' then return end
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
        end
      })
    end,
  },
})

pack.plug({
  "sourcegraph/sg.nvim",
  cmd = {
    'SourcegraphLogin',
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
  build = "nvim -l build/init.lua",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim"
  },
  opts = {
    on_attach = function() end
  },
  init = function()
    -- create user command: CodyOpenDoc to open https://sourcegraph.com/docs/cody/clients/install-neovim
    vim.api.nvim_create_user_command("CodyOpenDoc", function()
      vim.ui.open("https://sourcegraph.com/docs/cody/clients/install-neovim")
    end, {})
  end,
})
