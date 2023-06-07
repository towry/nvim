return {
  'akinsho/nvim-toggleterm.lua',
  keys = {
    {
      '<leader>//',
      '<cmd>Telescope termfinder find<cr>',
      desc = 'Find terminals with telescope',
    }
  },
  cmd = { 'ToggleTerm', 'TermExec' },
  branch = 'main',
  tag = 'v2.2.1',
  config = function()
    local au = require('libs.runtime.au')

    require('toggleterm').setup({
      -- size can be a number or function which is passed the current terminal
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      -- f24 = shift + f12
      open_mapping = nil,
      hide_numbers = true,       -- hide the number column in toggleterm buffers
      highlights = {
        -- highlights which map to a highlight group name and a table of it's values
        -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
        Normal = {
          link = 'Normal',
        },
        NormalFloat = {
          link = 'Normal',
        },
        FloatBorder = {
          -- guifg = <VALUE-HERE>,
          -- guibg = <VALUE-HERE>,
          link = 'FloatBorder',
        },
      },
      shade_filetypes = { 'none' },
      shade_terminals = true,
      shading_factor = 1,           -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
      start_in_insert = true,
      insert_mappings = true,       -- whether or not the open mapping applies in insert mode
      persist_size = false,
      persist_mode = false,
      auto_scroll = false,
      direction = 'horizontal',       -- | 'horizontal' | 'window' | 'float',
      close_on_exit = true,           -- close the terminal window when the process exits
      shell = vim.o.shell,            -- change the default shell
      -- This field is only relevant if direction is set to 'float'
      float_opts = {
        -- The border key is *almost* the same as 'nvim_win_open'
        -- see :h nvim_win_open for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = 'double',         -- single/double/shadow/curved
        winblend = 15,
      },
      winbar = {
        enabled = false,
      },
      on_open = function(_term)
        au.do_usercmd(au.user_autocmds.TermIsOpen)
        vim.cmd('startinsert!')
      end,
    })
  end,
  init = function()
    local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
    _G._plugin_set_terminal_keymaps = function()
      local opts = { noremap = true }
      nvim_buf_set_keymap(0, 't', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
      nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
      nvim_buf_set_keymap(0, 't', '<C-e>', [[<C-\><C-n>:]], opts)
      nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
      nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
      nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
      nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
    end

    vim.cmd('autocmd! TermOpen term://* lua _plugin_set_terminal_keymaps()')
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

    -- kill all at exits.
    vim.api.nvim_create_autocmd('VimLeavePre', {
      pattern = '*',
      callback = function()
        local is_shut = require('libs.terminal.toggleterm_kill_all')()
        if is_shut then
          Ty.ECHO({ { 'Shutting down all terminals', 'WarningMsg' } }, false, {})
        end
      end
    })
  end,
}
