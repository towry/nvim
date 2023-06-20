local plug = require('libs.runtime.pack').plug
local utils = require('libs.runtime.utils')
local au = require('libs.runtime.au')

plug({
  'nvim-lualine/lualine.nvim',
  dependencies = {
    -- {
    --   'pze/lualine-copilot',
    --   dev = false,
    -- },
  },
  event = { 'BufNewFile', 'BufReadPost', 'User OnLeaveDashboard' },
  config = function()
    require('user.config.options').setup_statusline()
    local auto_format_disabled = require('libs.lsp-format.autoformat').disabled
    local format_utils         = require('libs.lsp-format')
    local Buffer               = require('libs.runtime.buffer')
    local terms                = require('libs.statusline.lualine.terminal_component')

    local spectre_extension    = {
      sections = {
        lualine_a = { 'mode' },
      },
      filetypes = { 'spectre_panel' },
    }
    local present, lualine     = pcall(require, 'lualine')

    if not present then
      Ty.NOTIFY('lualine not installed')
      return
    end

    lualine.setup({
      extensions = {
        spectre_extension,
        'toggleterm',
        'nvim-tree',
      },
      options = {
        theme = vim.cfg.workbench__lualine_theme,
        globalstatus = true,
        -- component_separators = '│',
        component_separators = '',
        section_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        disabled_filetypes = { winbar = { 'lazy', 'alpha' }, statusline = { 'dashboard', 'lazy', 'alpha' } },
      },
      winbar = {
        lualine_a = {
          {
            separator = { right = '', left = '' },
            left_padding = 2,
            'filename',
            path = 1,
            symbols = {
              modified = '',
              readonly = '',
            }
          }
        },
      },
      inactive_winbar = {
        lualine_a = {
          {
            separator = { left = '', right = '' },
            left_padding = 2,
            'filename',
            path = 1,
            symbols = {
              modified = '',
              readonly = '',
            }
          }
        },
      },
      sections = {
        lualine_a = {
          {
            separator = { left = '', },
            right_padding = 2,
            function()
              local unsaved_count = #Buffer.unsaved_list()
              local has_modified = unsaved_count > 0
              local unsaved_count_text = unsaved_count > 0 and (':' .. unsaved_count) or ''
              vim.b['has_modified_file'] = has_modified
              local icon = has_modified and ' ' or ' '
              return icon .. #vim.fn.getbufinfo({ buflisted = 1 }) .. unsaved_count_text
            end,
            color = function()
              if vim.b['has_modified_file'] then
                return {
                  bg = '#C20505',
                  fg = '#ffffff',
                }
              end
            end,
          },
          { 'mode' },
          {
            terms,
          }
        },
        lualine_b = {
          {
            'branch',
            icon = " "
          },
          {
            function()
              -- local key = require('grapple').key()
              -- return ' [' .. key .. ']'
              local idx = require('harpoon.mark').status()
              return ' [' .. idx .. ']'
            end,
            cond = function()
              local harpoon_has = utils.has_plugin('harpoon')
              if not harpoon_has then
                return false
              end
              local idx = require('harpoon.mark').status()
              return idx and idx ~= ''
            end
          },
          'searchcount',
        },
        -- filename is displayed by the incline.
        lualine_c = {
          'diff',
          { 'diagnostics', update_in_insert = false, symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } }
        },
        lualine_x = {
          "overseer",
          -- copilot status
          require('copilot_status').status_string,
          -- {
          --   'copilot',
          -- },
          {
            'encoding',
            cond = function()
              return vim.opt.fileencoding and vim.opt.fileencoding:get() ~= 'utf-8'
            end
          },
          {
            function()
              local icon = '  '
              if auto_format_disabled() then
                icon = ' '
              end
              local ftr_name, impl_ftr_name = format_utils.current_formatter_name(0)
              if not ftr_name and not impl_ftr_name then
                return ''
              end
              return string.format('%s%s', icon, impl_ftr_name or ftr_name)
            end,
          },
          --- dap
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = utils.fg("Debug"),
          },
          {
            'fileformat',
            cond = function()
              return not vim.tbl_contains({ 'unix', 'mac' }, vim.bo.fileformat)
            end,
          },
          { 'filetype', colored = true, icon_only = true },
        },
        lualine_y = { 'filesize', 'progress' },
        lualine_z = { { 'location', separator = { left = '', right = '' }, left_padding = 0 } },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { '' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
})


plug({
  {
    'luukvbaal/statuscol.nvim',
    event = au.user_autocmds.FileOpened_User,
    cond = function() return vim.fn.has('nvim-0.9.0') == 1 end,
    config = function()
      local statuscol = require('statuscol')
      local builtin = require('statuscol.builtin')

      statuscol.setup({
        separator = '│',
        relculright = true,
        setopt = true,
        segments = {
          {
            sign = { name = { 'GitSigns' }, maxwidth = 1, colwidth = 1, auto = false },
            click = 'v:lua.ScSa',
          },
          {
            sign = { name = { 'Diagnostic' }, maxwidth = 1, auto = false },
            click = 'v:lua.ScSa',
          },
          {
            sign = { name = { '.*' }, maxwidth = 1, colwidth = 1, auto = true },
          },
          { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
          { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
        },
      })
    end,
  },
  {
    'b0o/incline.nvim',
    event = { 'BufReadPost', 'BufNewFile', 'BufWinEnter' },
    enabled = false,
    config = function()
      if vim.g.started_by_firenvim then return end

      require('incline').setup({
        hide = {
          cursorline = true,
          focused_win = true,
          only_win = true,
        },
        window = {
          margin = {
            vertical = 0,
            horizontal = 0,
          },
        },
        render = function(props)
          -- local bufid = props.buf
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          local icon, color = require('nvim-web-devicons').get_icon_color(filename)
          return {
            -- { '[' .. bufid .. '] ' },
            { icon .. ' ', guifg = color },
            { filename },
          }
        end,
      })
    end,
  },

  {
    'echasnovski/mini.map',
    version = '*',
    event = 'VeryLazy',
    -- event = au.user_autocmds.FileOpenedAfter_User,
    opts = {
      -- Symbols used to display data
      symbols = {
        -- Encode symbols. See `:h MiniMap.config` for specification and
        -- `:h MiniMap.gen_encode_symbols` for pre-built ones.
        -- Default: solid blocks with 3x2 resolution.
        encode = nil,
        -- Scrollbar parts for view and line. Use empty string to disable any.
        scroll_line = '█',
        scroll_view = '┃',
      },
      window = {
        focusable = false,
        side = 'right',
        width = 10,
        winblend = 10,
      }
    },
    config = function(_, opts)
      require('mini.map').setup(opts)
    end
  }
})
