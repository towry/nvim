local au = require('ty.core.autocmd')
local Utils = require('ty.core.utils')
local has_plugin = Utils.has_plugin
local vim_api = vim.api
local nvim_buf_set_keymap = vim_api.nvim_buf_set_keymap
local editing_config = Ty.Config.editing
local ui_config = Ty.Config.ui
local ui_inited = false
local nvim_create_autocmd = vim_api.nvim_create_autocmd
local start_without_buffer = vim.fn.argc(-1) == 0

return {
  common = {
    mini = function()
      nvim_create_autocmd('BufWinEnter', {
        pattern = '*',
        group = vim_api.nvim_create_augroup('MiniIdentEnter', {
          clear = true,
        }),
        callback = function()
          if vim.bo.buftype == '' then
            -- normal file.
            vim.b.miniindentscope_disable = false
          else
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
  },
  autocmp = {
    copilot = function()
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
      nvim_create_autocmd({ 'FileType' }, {
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
  buffer = {
    init = function()
    end,
  },
  debugger = {
    neotest = function()
    end,
  },
  editing = {
    init = function()
      local init_autocmds = function()
        local node_modules_pattern = '*/node_modules/*'

        au.with_group('no_ls_in_node_modules'):create({ 'BufRead', 'BufNewFile' }, {
          pattern = node_modules_pattern,
          command = 'lua vim.diagnostic.disable(0)',
        })

        local current_timeoutlen = vim.opt.timeoutlen:get() or 400
        au.with_group('no_insert_delay')
            :create('InsertEnter', {
              callback = function() vim.opt.timeoutlen = 1 end,
            })
            :create('InsertLeave', {
              callback = function() vim.opt.timeoutlen = current_timeoutlen end,
            })
      end

      init_autocmds()
    end,
    lspconfig = function()
      local format_on_save_on_filetypes = editing_config:get('format.format_on_save_on_filetypes') or {}
      au.on_attach(function(client, bufnr)
        local lsp_formatting = require('ty.contrib.editing.lsp.formatting')
        local ft = vim_api.nvim_buf_get_option(bufnr, 'filetype')
        if vim.tbl_contains(format_on_save_on_filetypes, ft) then lsp_formatting.setup_autoformat(client, bufnr) end
      end)
    end,
  },
  editor = {
    init = function()
      if start_without_buffer then
        nvim_create_autocmd({ 'UIEnter' }, {
          pattern = '*',
          once = true,
          callback = function()
            vim.defer_fn(function() require('alpha').start(true) end, 0)
          end,
        })
      end
    end,
    cursor_beacon = function()
      vim.g.beacon_ignore_buffers = { 'quickfix' }
      vim.g.beacon_ignore_filetypes = {
        'alpha',
        'lazy',
        'TelescopePrompt',
        'term',
        'nofile',
        'spectre_panel',
        'help',
        'txt',
        'log',
        'Trouble',
        'NvimTree',
        'qf',
      }
      vim.g.beacon_size = 60
    end,
  },
  explorer = {},
  git = {
    init = function()
      local function setup_lazyload_for_git()
        au.with_group('git_lazy_load'):create('BufReadPost', {
          pattern = '*',
          callback = function()
            -- in nvim diff mode.
            if vim.wo.diff then vim.cmd('GitConflictRefresh') end
          end,
        })
      end

      setup_lazyload_for_git()
    end,
  },
  keymaps = {
    init = function()
      local autocmd = au
      local aug = autocmd.with_group('attach_binding')
      local attach_keymaps = function()
        autocmd.on_attach(require('ty.contrib.keymaps.attach.lsp'), aug.group)

        require('ty.contrib.keymaps.attach.git_blame')(aug)
        require('ty.contrib.keymaps.attach.npm')(aug)
        require('ty.contrib.keymaps.attach.jest')(aug)
      end

      if start_without_buffer then
        nvim_create_autocmd('User', {
          pattern = 'VeryLazy',
          callback = function()
            attach_keymaps()
          end,
        })
      else
        attach_keymaps()
      end

      nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          if has_plugin('which-key.nvim') then require('ty.contrib.keymaps.whichkey').init() end
          require('ty.contrib.keymaps.basic')
        end,
      })
    end,
  },
  term = {
    init = function()
      nvim_create_autocmd('VimLeavePre', {
        pattern = '*',
        callback = function()
          local terms = require('toggleterm.terminal').get_all()
          local is_shut = false
          local job_ids = {}

          for _, term in ipairs(terms) do
            table.insert(job_ids, term.job_id)
            vim.fn.jobstop(term.job_id)
            is_shut = true
          end

          if #job_ids > 0 then vim.fn.jobwait(job_ids, 2000) end

          if is_shut then Ty.ECHO({ { 'Shutting down all terminals', 'WarningMsg' } }, false, {}) end
        end,
      })
    end,
    toggleterm = function()
      Ty.set_terminal_keymaps = function()
        local opts = { noremap = true }
        nvim_buf_set_keymap(0, 't', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
        nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
        nvim_buf_set_keymap(0, 't', '<C-e>', [[<C-\><C-n>:]], opts)
        nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
        nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
        nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
        nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
      end
      vim.cmd('autocmd! TermOpen term://* lua Ty.set_terminal_keymaps()')
      vim.keymap.set('n', '<C-\\>', function()
        if vim.tbl_contains({
              'NvimTree',
              'lazy',
            }, vim.bo.filetype) then
          return
        end
        if vim.v.count <= 1 then
          vim.cmd([[1ToggleTerm direction=float]])
        else
          vim.cmd(vim.v.count .. [[ToggleTerm direction=horizontal]])
        end
      end, {
        desc = 'toggle term',
        silent = true,
      })
    end,
  },
  ui = {
    init = function()
      if ui_inited then return end
      Utils.try(
        function() vim.cmd('colorscheme ' .. ui_config.theme.colorscheme or default_colorscheme) end,
        'error when loading colorscheme'
      )
      local hl_update_callback = require('ty.contrib.ui.on_need_hl_update')
      nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        once = true,
        callback = function()
          hl_update_callback()
          -- disable lazyredraw after startup.
          vim.opt.lazyredraw = false
        end,
      })
      au.on_need_hl_update(hl_update_callback)
      ui_inited = true
    end,
    dressing = function()
      local is_inited = false
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        if not is_inited then
          require('lazy').load({ plugins = { 'dressing.nvim' } })
          is_inited = true
        end
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        if not is_inited then
          require('lazy').load({ plugins = { 'dressing.nvim' } })
          is_inited = true
        end
        return vim.ui.input(...)
      end
    end,
    notify = function()
      local banned_msgs = {
        'No information available',
        'LSP[tsserver] Inlay Hints request failed. File not opened in the editor.',
        'LSP[tsserver] Inlay Hints request failed. Requires TypeScript 4.4+.',
      }
      vim.notify = function(msg, ...)
        -- check banned_msgs contains msg with reg match
        if vim.tbl_contains(banned_msgs, msg) then return end

        require('notify')(msg, ...)
      end
    end,
    everforest = function()
      -- @see https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
      local theme = require('ty.contrib.ui').theme_everforest
      vim.g.everforest_background = theme.background_contrast
      vim.g.everforest_ui_contrast = theme.ui_contrast
      vim.g.everforest_better_performance = ui_config:get('theme_everforest.better_performance', 1)
      vim.g.everforest_enable_italic = ui_config:get('theme_everforest.italic', 1)
      vim.g.everforest_disable_italic_comment = false
      vim.g.everforest_transparent_background = false
      vim.g.everforest_dim_inactive_windows = false
      vim.g.everforest_sign_column_background = 'none'  -- "none" | "grey"
      vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
      vim.g.everforest_diagnostic_text_highlight = 0
      vim.g.everforest_diagnostic_line_highlight = 0
    end,
  },
}
