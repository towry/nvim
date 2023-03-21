local au = require('ty.core.autocmd')
local Utils = require('ty.core.utils')

return {
  common = function()
    return {
      mini = function()
        vim.api.nvim_create_autocmd('BufWinEnter', {
          pattern = '*',
          group = vim.api.nvim_create_augroup('MiniIdentEnter', {
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
    }
  end,
  autocmp = function() return {} end,
  buffer = function()
    return {
      init = function() end,
    }
  end,
  debugger = function()
    return {
      neotest = function() end,
    }
  end,
  editing = function()
    local editing_config = Ty.Config.editing

    return {
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
          local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
          if vim.tbl_contains(format_on_save_on_filetypes, ft) then lsp_formatting.setup_autoformat(client, bufnr) end
        end)

        vim.api.nvim_create_user_command(
          'LspToggleAutoFormat',
          'lua require("ty.contrib.editing.lsp.functions").toggle_format_on_save()',
          {}
        )
      end,
    }
  end,
  editor = function(F)
    return {
      init = function() require('alpha').start(true) end,
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
    }
  end,
  explorer = function() return {} end,
  git = function()
    return {
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
    }
  end,

  keymaps = function()
    return {
      init = function()
        local autocmd = au
        vim.api.nvim_create_autocmd('User', {
          pattern = 'VeryLazy',
          callback = function()
            require('ty.contrib.keymaps.basic')

            local aug = autocmd.with_group('attach_binding')
            autocmd.on_attach(require('ty.contrib.keymaps.attach.lsp'), aug.group)

            require('ty.contrib.keymaps.attach.git_blame')(aug)
            require('ty.contrib.keymaps.attach.npm')(aug)
            require('ty.contrib.keymaps.attach.jest')(aug)

            if Utils.has_plugin('which-key.nvim') then require('ty.contrib.keymaps.whichkey').init() end
          end,
        })
      end,
    }
  end,

  term = function()
    return {
      init = function()
        vim.api.nvim_create_autocmd('VimLeavePre', {
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
          vim.api.nvim_buf_set_keymap(0, 't', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-e>', [[<C-\><C-n>:]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
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
    }
  end,

  ui = function()
    local inited = false
    local ui_config = Ty.Config.ui

    return {
      init = function()
        if inited then return end
        Utils.try(
          function() vim.cmd('colorscheme ' .. ui_config.theme.colorscheme or default_colorscheme) end,
          'error when loading colorscheme'
        )
        local hl_update_callback = require('ty.contrib.ui.on_need_hl_update')
        hl_update_callback()
        au.on_need_hl_update(hl_update_callback)
        inited = true
      end,

      dressing = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.select = function(...)
          require('ty.core.pack').load({ plugins = { 'dressing.nvim' } })
          return vim.ui.select(...)
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.input = function(...)
          require('ty.core.pack').load({ plugins = { 'dressing.nvim' } })
          return vim.ui.input(...)
        end
      end,

      everforest = function()
        -- @see https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
        local theme = require('ty.contrib.ui').theme_everforest
        local config = ui_config

        vim.g.everforest_background = theme.background_contrast
        vim.g.everforest_ui_contrast = theme.ui_contrast
        vim.g.everforest_better_performance = config:get('theme_everforest.better_performance', 1)
        vim.g.everforest_enable_italic = config:get('theme_everforest.italic', 1)
        vim.g.everforest_disable_italic_comment = false
        vim.g.everforest_transparent_background = false
        vim.g.everforest_dim_inactive_windows = false
        vim.g.everforest_sign_column_background = 'none' -- "none" | "grey"
        vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
        vim.g.everforest_diagnostic_text_highlight = 0
        vim.g.everforest_diagnostic_line_highlight = 0
      end,
    }
  end,
}
