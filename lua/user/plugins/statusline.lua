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
      winbar = {},
      -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#tabline
      -- tabline = comp.TabLine,
      statusline = heirline_utils.insert(
        {
          static = comp.stl_static,
          hl = { fg = 'fg', bg = 'bg' },
        },
        comp.lpad(comp.Tabs),
        {
          {
            provider = ' [%n]',
          },
          comp.ShortFileName,
          {
            provider = '%m%w%q%r',
          },
        },
        comp.lpad(comp.Overseer),
        comp.lpad(require('userlib.statusline.heirline.component_diagnostic')),
        require('userlib.statusline.heirline').left_components,
        { provider = '%=' },
        require('userlib.statusline.heirline').right_components,
        { provider = '%<%(' },
        comp.rpad(comp.CocStl),
        comp.rpad(comp.Copilot),
        comp.rpad(comp.Codeium),
        comp.rpad({ comp.Branch, comp.GitStatus }),
        comp.rpad({
          provider = '%c:%l',
        }),
        comp.rpad(comp.Dap),
        -- comp.rpad(comp.LspFormatter),
        -- comp.rpad(comp.DiagnosticsDisabled),
        { provider = '%)' }
      ),

      opts = {
        disable_winbar_cb = function(args)
          return true
        end,
      },
    })

    vim.o.showtabline = 0
    vim.api.nvim_create_user_command('HeirlineResetStatusline', function()
      vim.o.statusline = "%{%v:lua.require'heirline'.eval_statusline()%}"
      -- vim.o.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
    end, {})
    -- if not vim.g.hide_winbar then
    -- Because heirline is lazy loaded, we need to manually set the winbar on startup
    -- vim.opt_local.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
    -- end
    if vim.o.laststatus == 0 then
      vim.opt.statusline = "%#VertSplit#%{repeat('-',winwidth('.'))}"
    end
  end,
})
