local plug = require('userlib.runtime.pack').plug
local utils = require('userlib.runtime.utils')
local au = require('userlib.runtime.au')
local git_branch_icon = ' '
local enable_lualine = true

local function is_treesitter()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end

local git_status_source = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
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
local cwd_component = {
  function() return vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short end,
  icon = ' ',
}
local tabs_component = {
  'tabs',
  max_length = vim.o.columns / 2,
  mode = 1,
  use_mode_colors = true,
  draw_empty = false,
  -- tabs_color = {
  --   active = { fg = 'Green', gui = 'bold,underline' },
  --   inactive = { fg = 'Comment' },
  -- },
  cond = function() return vim.fn.tabpagenr('$') > 1 end,
  fmt = function(name, context)
    local cwd = vim.t[context.tabnr].cwd
    if cwd then
      cwd = vim.fn.fnamemodify(cwd, ':t')
    elseif not cwd then
      cwd = name
    end
    return string.format('%s%s', context.tabnr, cwd ~= '' and ':' .. cwd or '')
  end,
}

plug({
  'nvim-lualine/lualine.nvim',
  enabled = enable_lualine,
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = {
    {
      -- 'pze/lualine-copilot',
      'ofseed/copilot-status.nvim',
      dev = false,
      enabled = true,
    },
    'tpope/vim-fugitive',
  },
  event = { 'User LazyUIEnterOncePost', 'User OnLeaveDashboard' },
  -- event = 'BufReadPre',
  config = function()
    require('user.config.options').setup_statusline()
    local auto_format_disabled = require('userlib.lsp.servers.null_ls.autoformat').disabled
    local format_utils = require('userlib.lsp.servers.null_ls.fmt')
    -- local Buffer               = require('userlib.runtime.buffer')
    local terms = require('userlib.statusline.lualine.terminal_component')

    local spectre_extension = {
      sections = {
        lualine_a = { 'mode', tabs_component },
      },
      filetypes = { 'spectre_panel' },
    }
    local dashboard_extension = {
      sections = {
        lualine_a = {},
        lualine_b = {
          cwd_component,
          git_branch,
        },
        lualine_c = {
          -- tabs_component,
        },
      },
      winbar = {},
      filetypes = { 'starter', 'alpha' },
    }
    local empty_buffer_extension = {
      sections = {
        lualine_a = {
          tabs_component,
        },
      },
      winbar = {
        lualine_a = {
          function()
            return '  Hello Towry!'
          end,
          cwd_component,
          git_branch,
        },
      },
      filetypes = { '' },
    }
    local overseer_extension = {
      tabline = {
        lualine_a = {
          function()
            return 'Overseer list'
          end,
        }
      },
      filetypes = { 'OverseerList' },
    }
    local toggleterm_extension = {
      tabline = {},
      sections = {
        lualine_a = {
          'mode',
          {
            terms,
          },
        },
        lualine_c = {
          -- tabs_component,
        },
      },
      filetypes = { 'toggleterm' },
    }
    local present, lualine = pcall(require, 'lualine')

    if not present then
      Ty.NOTIFY('lualine not installed')
      return
    end

    lualine.setup({
      extensions = {
        spectre_extension,
        dashboard_extension,
        toggleterm_extension,
        overseer_extension,
        empty_buffer_extension,
        'neo-tree',
        'quickfix',
      },
      options = {
        theme = vim.cfg.workbench__lualine_theme,
        globalstatus = true,
        component_separators = '│',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { winbar = vim.cfg.misc__ft_exclude, statusline = { 'dashboard', 'lazy', 'alpha' } },
      },
      winbar = {
        lualine_z = {
          {
            function()
              local cwd = vim.fn.fnamemodify(vim.b.cwd or vim.cfg.runtime__starts_cwd, ':t')
              return cwd
            end,
            icon = '󰉋 '
          },
        },
        lualine_a = {
          {
            'filename',
            file_status = true,
            path = 4,
            fmt = function(name)
              if name == '[No Name]' then return '' end
              local bufnr = vim.fn.bufnr('%')
              return string.format('%s#%s', bufnr, name)
            end
          },

        }
      },
      inactive_winbar = {
        lualine_z = {
          {
            function()
              local cwd = vim.fn.fnamemodify(vim.b.cwd or vim.cfg.runtime__starts_cwd, ':t')
              return cwd
            end,
            icon = '󰉋 '
          },
        },
        lualine_a = {
          {
            'filename',
            file_status = true,
            path = 4,
            fmt = function(name)
              local bufnr = vim.fn.bufnr('%')
              return string.format('%s#%s', bufnr, name)
            end
          },
        }
      },
      sections = {
        lualine_a = {
          { 'mode', fmt = function(str) return str:sub(1, 1) end },
          git_branch,
          tabs_component,
        },
        lualine_b = {
          {
            function()
              local idx = require('harpoon.mark').status()
              return idx
            end,
            cond = function()
              local harpoon_has = utils.pkg_loaded('harpoon')
              if not harpoon_has then return false end
              local idx = require('harpoon.mark').status()
              return idx and idx ~= ''
            end,
            icon = {
              '',
              color = {
                fg = 'red',
              },
            },
          },
        },
        lualine_c = {
          {
            'diagnostics',
            update_in_insert = false,
            symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            cond = function()
              return vim.b.diagnostic_disable ~= true
            end
          },
        },
        lualine_x = {
          'searchcount',
          -- copilot status
          -- require('copilot_status').status_string,
          {
            'copilot',
          },
          {
            function()
              return ''
            end,
            name = "overseer-placeholder"
          },
          {
            terms,
          },
          {
            'encoding',
            cond = function() return vim.opt.fileencoding and vim.opt.fileencoding:get() ~= 'utf-8' end,
          },
          {
            function()
              local ret = vim.trim(vim.fn['codeium#GetStatusString']() or '')
              if ret == '*' then
                return '󱥸 '
              elseif ret == '0' then
                return ' '
              elseif ret ~= '' then
                return ret
              else
                return '󰛿 '
              end
            end,
            cond = function() return vim.cfg.plug__enable_codeium_vim end,
          },
          {
            function()
              local icon = '󰎟 '
              if auto_format_disabled(0) then
                icon = '󰙧 '
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
            function() return '  ' .. require('dap').status() end,
            cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
            color = utils.fg('Debug'),
          },
          {
            'fileformat',
            cond = function() return not vim.tbl_contains({ 'unix', 'mac' }, vim.bo.fileformat) end,
          },
          {
            'filetype',
            icon = { align = 'left' },
            colored = false,
            icon_only = false,
          },
        },
        lualine_y = {
          'filesize',
          {
            'diff',
            source = git_status_source,
          },
        },
        lualine_z = {
          {
            function()
              if is_treesitter() then return '' end
              return '󰐆'
            end,
          },
          {
            function()
              if vim.diagnostic.is_disabled() then return '' end
              return ''
            end,
            cond = function()
              return vim.diagnostic.is_disabled()
            end,
          },
          {
            function()
              return vim.cfg.runtime__starts_cwd_short
            end,
            icon = ' '
          }
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
    'b0o/incline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    enabled = false,
    config = function()
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
        render = function(ctx)
          local buf = ctx.buf
          local cwd = vim.fn.fnamemodify(vim.b[buf].cwd or vim.cfg.runtime__starts_cwd, ':t')
          local bufname = vim.api.nvim_buf_get_name(buf)
          bufname = require('userlib.runtime.path').make_relative(bufname, cwd)
          bufname = require('userlib.runtime.path').shorten(bufname, 5)

          local icon = ' '
          return {
            { bufname },
            { icon },
            { cwd },
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
    config = function(_, opts) require('satellite').setup(opts) end,
  },
})
