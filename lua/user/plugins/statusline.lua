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
    vim.api.nvim_create_autocmd('ColorScheme', {
      desc = 'Update Heirline colors',
      group = aug,
      callback = function()
        local colors = comp.setup_colors()
        heirline_utils.on_colorscheme(colors)
      end,
    })
    require('heirline').setup({
      winbar = {
        comp.DirAndFileName,
      },
      -- mode
      -- branch
      -- harpoon
      -- tabs
      -- lsp diagnostics
      -- git changes
      -- padding
      -- copilot
      -- formatter name
      -- filetype
      -- filesize
      -- root folder
      statusline = heirline_utils.insert(
        {
          static = comp.stl_static,
          hl = { fg = 'fg', bg = 'bg' },
        },
        comp.ViMode,
        comp.lpad({
          provider = [[$%{v:lua.Ty.stl_bufcount()}]],
        }),
        comp.lpad(comp.Branch),
        comp.lpad(comp.Gitinfo),
        comp.lpad(comp.GitStatus),
        -- comp.lpad(comp.ProfileRecording),
        comp.lpad(comp.Copilot),
        comp.lpad(comp.Codeium),
        comp.lpad(comp.Harpoon),
        comp.lpad(require('userlib.statusline.heirline.component_diagnostic')),
        comp.lpad(comp.TerminalStatusline),
        comp.lpad(comp.BufVisited),
        require('userlib.statusline.heirline').left_components,
        { provider = '%=' },
        comp.lpad(comp.Tabs),
        { provider = '%=' },
        require('userlib.statusline.heirline').right_components,
        comp.rpad(comp.Overseer),
        comp.rpad(comp.LastExCommand),
        comp.rpad(comp.NavigateDirection),
        comp.rpad(comp.Dap),
        comp.rpad(comp.LspFormatter),
        comp.rpad(comp.HelpFileName),
        comp.rpad(comp.FileType),
        comp.rpad(comp.DiagnosticsDisabled),
        comp.rpad(comp.WorkspaceRoot)
        -- comp.Ruler
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
          local filetype = vim.bo[buf].filetype
          local ignore_filetype = filetype == 'fugitive' or filetype == 'qf' or filetype:match('^git')
          local is_float = vim.api.nvim_win_get_config(0).relative ~= ''
          return ignore_buftype or ignore_filetype or is_float
        end,
      },
    })

    vim.api.nvim_create_user_command('HeirlineResetStatusline', function()
      vim.o.statusline = "%{%v:lua.require'heirline'.eval_statusline()%}"
    end, {})
    -- Because heirline is lazy loaded, we need to manually set the winbar on startup
    vim.opt_local.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
  end,
})
