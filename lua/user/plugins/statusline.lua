local plug = require('libs.runtime.pack').plug
local Buffer = require('libs.runtime.buffer')
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
          function()
            if not vim.b.gitsigns_head or vim.b.gitsigns_git_status or vim.o.columns < 120 then
              return ""
            end

            local git_status = vim.b.gitsigns_status_dict

            local added = (git_status.added and git_status.added ~= 0) and (" +" .. git_status.added) or ""
            local changed = (git_status.changed and git_status.changed ~= 0) and (" ~" .. git_status.changed) or ""
            local removed = (git_status.removed and git_status.removed ~= 0) and (" -" .. git_status.removed) or ""

            return (added .. changed .. removed) ~= "" and (added .. changed .. removed) or ""
          end,
          -- 'diff',
          { 'diagnostics', update_in_insert = false, symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } }
        },
        lualine_x = {
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
    'lewis6991/satellite.nvim',
    version = '*',
    -- event = 'VeryLazy',
    cmd = { 'SatelliteEnable', 'SatelliteDisable', 'SatelliteRefresh' },
    event = au.user_autocmds.FileOpenedAfter_User,
    opts = {
      current_only = false,
      winblend = 50,
      zindex = 40,
      excluded_filetypes = vim.cfg.misc__ft_exclude,
    },
    config = function(_, opts)
      require('satellite').setup(opts)
    end
  }
})

---heirline
plug({
  "rebelot/heirline.nvim",
  event = "BufEnter",
  opts = function()
    local status = require "astronvim.utils.status"
    return {
      opts = {
        disable_winbar_cb = function(args)
          return not Buffer.is_valid(args.buf)
              or Buffer.buffer_matches({
                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
              }, args.buf)
        end,
      },
      statusline = {
        -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info { filetype = {}, filename = false, file_modified = false },
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode { surround = { separator = "right" } },
      },
      winbar = {
        -- winbar
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        {
          condition = function() return not status.condition.is_active() end,
          status.component.separated_path(),
          status.component.file_info {
            file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        status.component.breadcrumbs { hl = status.hl.get_attributes("winbar", true) },
      },
      tabline = { -- bufferline
        {
          -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            return status.condition.buffer_matches(
              { filetype = { "aerial", "dapui_.", "neo%-tree", "NvimTree", "edgy" } },
              vim.api.nvim_win_get_buf(self.winid)
            )
          end,
          provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } },               -- fill the rest of the tabline with background color
        {
          -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist {                                        -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          {
            -- close button for current tab
            provider = status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astronvim.utils.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      },
      statuscolumn = vim.fn.has "nvim-0.9" == 1 and {
            status.component.foldcolumn(),
            status.component.fill(),
            status.component.numbercolumn(),
            status.component.signcolumn(),
          } or nil,
    }
  end,
})
