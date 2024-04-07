local plug = require('userlib.runtime.pack').plug

plug({
  --- Copied from stevearc's dotfiles
  ---@see https://github.com/stevearc/dotfiles/blob/860e18ee85d30a72cea5a51acd9983830259075e/.config/nvim/lua/plugins/heirline.lua#L4
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local comp = require('userlib.statusline.heirline.components')
    local heirline_utils = require('heirline.utils')

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
      winbar = {
        {
          comp.ShortFileName,
          {
            provider = ' [%n]',
          },
          {
            provider = '%m%w%r',
          },
        },
      },
      -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#tabline
      -- tabline = comp.TabLine,
      statusline = heirline_utils.insert(
        {
          static = comp.stl_static,
          hl = { fg = 'fg', bg = 'bg' },
        },
        comp.TabLine,
        comp.lpad({
          { provider = ' ' },
          comp.Branch,
          comp.GitStatus,
        }),
        comp.lpad({ provider = '%y%q' }),
        comp.lpad(comp.Overseer),
        { provider = '%=' },
        {
          condition = function()
            return vim.t.TabLabel and vim.t.TabLabel ~= ''
          end,
          provider = function()
            return '%-.20([' .. vim.t.TabLabel .. ']%) '
          end,
        },
        { provider = '%=' },
        {
          provider = '%=%v:%l ',
        },
        comp.rpad(comp.CocStl),
        comp.rpad(comp.Copilot),
        comp.rpad(comp.Codeium),
        comp.rpad(comp.Dap),
        { provider = '%P ' }
      ),

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

    vim.o.showtabline = 0
    vim.api.nvim_create_user_command('HeirlineResetStatusline', function()
      vim.o.statusline = "%{%v:lua.require'heirline'.eval_statusline()%}"
    end, {})
    if vim.o.laststatus == 0 then
      vim.opt.statusline = "%#VertSplit#%{repeat('-',winwidth('.'))}"
    end
    vim.opt_local.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
  end,
})
