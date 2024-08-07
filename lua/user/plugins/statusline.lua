local plug = require('userlib.runtime.pack').plug

plug({
  --- Copied from stevearc's dotfiles
  ---@see https://github.com/stevearc/dotfiles/blob/860e18ee85d30a72cea5a51acd9983830259075e/.config/nvim/lua/plugins/heirline.lua#L4
  'rebelot/heirline.nvim',
  event = 'User LazyUIEnterOncePost',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local comp = require('userlib.statusline.heirline.components')
    local heirline_utils = require('heirline.utils')
    local conditions = require('heirline.conditions')

    require('heirline').load_colors(comp.setup_colors())
    local aug = vim.api.nvim_create_augroup('Heirline', { clear = true })
    vim.api.nvim_create_autocmd('OptionSet', {
      desc = 'Update Heirline colors',
      group = aug,
      pattern = 'background',
      callback = function()
        local colors = comp.setup_colors()
        heirline_utils.on_colorscheme(colors)
      end,
    })
    require('heirline').setup({
      -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#tabline
      tabline = {
        hl = { fg = 'tabline_fg', bg = 'tabline_bg' },
        comp.TabLine,
        comp.lpad(comp.Overseer),
        comp.lpad(comp.Dap),
        {
          provider = '%=',
        },
        {
          comp.rpad(comp.LastExCommand),
          comp.rpad(comp.Copilot),
          comp.rpad(comp.Codeium),
          comp.rpad(comp.TrailStackNameCurrent),
          comp.rpad({
            comp.Branch,
            comp.GitStatus,
          }),
        },
      },
      statusline = heirline_utils.insert({
        static = comp.stl_static,
        hl = function()
          if conditions.is_active() then
            return { fg = 'fg', bg = 'bg' }
          end
          return {
            fg = 'fg_nc',
            bg = 'bg_nc',
          }
        end,
      }, {
        condition = function()
          return conditions.is_active()
        end,
        comp.ViMode,
        comp.lpad({
          {
            provider = function()
              local v = Ty.stl_relative_bufname(vim.api.nvim_get_current_buf())
              return v == '' and '[No Name] ' or v .. ' '
            end,
          },
          {
            provider = '[%n]',
          },
          {
            provider = '%m%w%r',
          },
          comp.BufVisited,
          comp.lpad(require('userlib.statusline.heirline.component_diagnostic')),
        }),
        comp.lpad(comp.CocStl),
        comp.lpad(comp.LSPActive),
        { provider = '%=' },
        { provider = '%=' },
        {
          provider = '%v:%l %P %<',
        },
      }, {
        condition = function()
          return not conditions.is_active()
        end,
        --- file info
        comp.lpad({
          {
            provider = function()
              local v = Ty.stl_relative_bufname(vim.api.nvim_get_current_buf())
              return v == '' and '[No Name] ' or v .. ' '
            end,
          },
          {
            provider = '[%n]',
          },
          {
            provider = '%m%w%r',
          },
          comp.BufVisited,
          comp.lpad(require('userlib.statusline.heirline.component_diagnostic')),
        }),
        comp.lpad(comp.CocStl),
        { provider = '%=' },
        {
          provider = '%v:%l %P %<',
        },
      }),

      opts = {
        disable_winbar_cb = function(args)
          local buf = args.buf
          local buftype = vim.bo[buf].buftype
          local ignore_buftype = vim.tbl_contains({
            -- 'nowrite',
            -- 'nofile',
            'quickfix',
            'tutor',
            'netrw',
          }, buftype)
          if ignore_buftype then
            return true
          end
          local filetype = vim.bo[buf].filetype
          local ignore_filetype = vim.tbl_contains({
            'fugitive',
            'qf',
            'fzf-lua',
          }, filetype) or filetype:match('^git')
          if ignore_filetype then
            return true
          end
          local is_float = vim.api.nvim_win_get_config(0).relative ~= ''
          return is_float
        end,
      },
    })

    vim.o.showtabline = 2
    vim.api.nvim_create_user_command('HeirlineResetStatusline', function()
      vim.o.statusline = "%{%v:lua.require'heirline'.eval_statusline()%}"
    end, {})
    if vim.o.laststatus == 0 then
      vim.opt.statusline = "%#VertSplit#%{repeat('-',winwidth('.'))}"
    end
    vim.o.laststatus = 2
  end,
})
