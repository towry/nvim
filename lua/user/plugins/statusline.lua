local plug = require('userlib.runtime.pack').plug
local utils = require('userlib.runtime.utils')
local au = require('userlib.runtime.au')
local git_branch_icon = " "

local git_status_source = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed
    }
  end
end

local git_branch = {
  'FugitiveHead',
  icon = git_branch_icon,
}

local tabs_nrto_icons = {
  ['1'] = '❶ ',
  ['2'] = '❷ ',
  ['3'] = '❸ ',
  ['4'] = '❹ ',
  ['5'] = '❺ ',
  ['6'] = '❻ ',
  ['7'] = '❼ ',
  ['8'] = '❽ ',
  ['9'] = '❾ ',
  ['10'] = '❿ ',
}
local tabs_component = {
  'tabs',
  max_length = vim.o.columns / 3,
  mode = 1,
  use_mode_colors = false,
  tabs_color = {
    active = { fg = '#6f894e', gui = 'italic,bold' },
    inactive = { fg = 'gray' },
  },
  fmt = function(name, context)
    local tabnr = context.tabnr
    local icon = tabs_nrto_icons[tostring(tabnr)] or tabnr
    if context.last and context.tabId == 1 then
      return ''
    end
    return icon .. ''
  end,
}

-- TODO: move cwd component to a module.

plug({
  'nvim-lualine/lualine.nvim',
  dependencies = {
    {
      'pze/lualine-copilot',
      dev = false,
      enabled = false,
    },
    'tpope/vim-fugitive',
  },
  event = { 'User LazyUIEnterOncePost', 'User OnLeaveDashboard' },
  config = function()
    require('user.config.options').setup_statusline()
    local auto_format_disabled = require('userlib.lsp.fmt.autoformat').disabled
    local format_utils         = require('userlib.lsp.fmt')
    local Buffer               = require('userlib.runtime.buffer')
    local terms                = require('userlib.statusline.lualine.terminal_component')

    local spectre_extension    = {
      sections = {
        lualine_a = { 'mode', tabs_component },
      },
      filetypes = { 'spectre_panel' },
    }
    local dashboard_extension  = {
      sections = {
        lualine_a = {
          {
            function()
              return vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short
            end,
            icon = ' ',
          }
        },
        lualine_b = {
          git_branch,
        },
        lualine_c = {
          tabs_component,
        }
      },
      winbar = {},
      filetypes = { 'starter', 'alpha' },
    }
    local toggleterm_extension = {
      winbar = {},
      sections = {
        lualine_a = {
          "mode",
          {
            function()
              return vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short
            end,
            icon = ' ',
          },
        },
        lualine_b = {
          tabs_component,
        },
        lualine_x = {
          {
            terms,
          },
        }
      },
      filetypes = { 'toggleterm' }
    }
    local present, lualine     = pcall(require, 'lualine')

    if not present then
      Ty.NOTIFY('lualine not installed')
      return
    end

    lualine.setup({
      extensions = {
        spectre_extension,
        dashboard_extension,
        toggleterm_extension,
        'nvim-tree',
        'quickfix',
      },
      options = {
        theme = vim.cfg.workbench__lualine_theme,
        globalstatus = true,
        -- component_separators = '│',
        component_separators = '',
        section_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        disabled_filetypes = { winbar = vim.cfg.misc__ft_exclude, statusline = { 'dashboard', 'lazy', 'alpha' } },
      },
      winbar = {
        lualine_a = {
          {
            function()
              return vim.api.nvim_win_get_number(0)
            end,
            icon = ''
          },
          {
            --section_separators = { left = '', right = '' },
            separator = { right = '', left = '' },
            left_padding = 2,
            'filename',
            path = 1,
            symbols = {
              modified = '',
              readonly = '',
            }
          },
        },
        lualine_b = {
          {
            function()
              local idx = require('harpoon.mark').status()
              return idx
            end,
            cond = function()
              local harpoon_has = utils.pkg_loaded('harpoon')
              if not harpoon_has then
                return false
              end
              local idx = require('harpoon.mark').status()
              return idx and idx ~= ''
            end,
            icon = {
              '',
              color = {
                fg = 'red',
              }
            }
          },
        },
        lualine_c = {
          { 'diagnostics', update_in_insert = false, symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
          {
            'diff',
            source = git_status_source
          },
        },
        lualine_z = {}
      },
      inactive_winbar = {
        lualine_a = {
          {
            function()
              return vim.api.nvim_win_get_number(0)
            end,
            icon = ''
          },
          {
            -- section_separators = { left = '', right = '' },
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
        lualine_z = {
        }
      },
      sections = {
        lualine_a = {
          { 'mode', fmt = function(str) return str:sub(1, 1) end },
          {
            function()
              return vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short
            end,
            icon = ' ',
          }
        },
        lualine_b = {
          'searchcount',
          git_branch,
        },
        -- filename is displayed by the incline.
        lualine_c = {
          -- TODO: move to component.
          {
            function()
              local unsaved_count = #Buffer.unsaved_list({ perf = true })
              local has_modified = unsaved_count > 0
              local unsaved_count_text = unsaved_count > 0 and (':' .. unsaved_count) or ''
              vim.b['has_modified_file'] = has_modified
              local listed_count = #vim.fn.getbufinfo({ buflisted = 1 })
              if listed_count <= 1 and unsaved_count <= 0 then
                return ''
              end
              return listed_count .. unsaved_count_text
            end,
            icon = {
              ' ',
              color = function()
                if vim.b['has_modified_file'] then
                  return {
                    fg = '#C20505',
                  }
                end
              end,
            },
          },
          tabs_component,
        },
        lualine_x = {
          -- copilot status
          -- require('copilot_status').status_string,
          -- {
          --   'copilot',
          -- },
          {
            terms,
          },
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
        lualine_y = { 'filesize' },
        lualine_z = {
          -- { 'location', left_padding = 0 },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { '' },
        -- lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
})


plug({
  {
    'luukvbaal/statuscol.nvim',
    event = 'User LazyUIEnterOnce',
    cond = function() return vim.fn.has('nvim-0.9.0') == 1 end,
    config = function()
      local statuscol = require('statuscol')
      local builtin = require('statuscol.builtin')

      statuscol.setup({
        ft_ignore = vim.cfg.misc__ft_exclude,
        buf_ignore = vim.cfg.misc__buf_exclude,
        separator = '│',
        relculright = true,
        setopt = true,
        segments = {
          {
            sign = { name = { 'GitSigns' }, maxwidth = 1, colwidth = 1, auto = false },
            click = 'v:lua.ScSa',
          },
          -- {
          --   sign = { name = { '.*' }, maxwidth = 2, colwidth = 2, auto = true },
          -- },
          {
            sign = { namespace = { '.*' }, maxwidth = 2, colwidth = 3, auto = true },
          },
          { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
          { text = { builtin.foldfunc, '' }, click = 'v:lua.ScFa' },
          {
            sign = { name = { 'Diagnostic' }, maxwidth = 1, auto = false },
            click = 'v:lua.ScSa',
          },
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
          focused_win = false,
          only_win = false,
        },
        window = {
          margin = {
            vertical = 0,
            horizontal = 0,
          },
        },
        render = function()
          local path = vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short
          local icon = ' '
          return {
            { icon },
            { path },
          }
        end,
      })
    end,
  },

  {
    'lewis6991/satellite.nvim',
    -- enabled = vim.list_contains ~= nil,
    enabled = false,
    version = '*',
    -- event = 'VeryLazy',
    cmd = { 'SatelliteEnable', 'SatelliteDisable', 'SatelliteRefresh' },
    event = au.user_autocmds.FileOpenedAfter_User,
    opts = {
      gitsigns = {
        enable = false,
      },
      current_only = false,
      winblend = 8,
      zindex = 40,
      width = 4,
      excluded_filetypes = vim.cfg.misc__ft_exclude,
    },
    config = function(_, opts)
      require('satellite').setup(opts)
    end
  }
})
