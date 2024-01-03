local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')
local libutils = require('userlib.runtime.utils')

plug({
  {
    'akinsho/toggleterm.nvim',
    dev = false,
    keys = {
      {
        '<leader>//',
        '<cmd>Telescope termfinder find<cr>',
        desc = 'Find terminals with telescope',
      },
      {
        '<leader>gv',
        '<cmd>lua require("userlib.terminal.term-git").toggle_tig()<cr>',
        desc = 'Tig commits',
      },
      {
        '<leader>gV',
        '<cmd>lua require("userlib.terminal.term-git").toggle_tig_file_history()<cr>',
        desc = 'Tig current file history',
      },
    },
    cmd = { 'ToggleTerm', 'TermExec' },
    branch = 'main',
    -- tag = 'v2.2.1',
    config = function()
      -- local au = require('userlib.runtime.au')

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
        hide_numbers = true, -- hide the number column in toggleterm buffers
        highlights = {
          -- highlights which map to a highlight group name and a table of it's values
          -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
          Normal = {
            link = 'Normal',
          },
          NormalFloat = {
            link = 'NormalFloat',
          },
          FloatBorder = {
            -- guifg = <VALUE-HERE>,
            -- guibg = <VALUE-HERE>,
            link = 'FloatBorder',
          },
        },
        shade_filetypes = { 'none' },
        shade_terminals = true,
        shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        persist_mode = false,
        auto_scroll = false,
        direction = 'horizontal', -- | 'horizontal' | 'window' | 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_win_open'
          -- see :h nvim_win_open for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = vim.cfg.ui__float_border, -- single/double/shadow/curved
          winblend = 15,
        },
        winbar = {
          enabled = false,
        },
        on_close = function()
          vim.schedule(function()
            if vim.g.cmd_on_toggleterm_close ~= nil then
              vim.cmd(vim.g.cmd_on_toggleterm_close)
              vim.g.cmd_on_toggleterm_close = nil
            end
          end)
        end,
        on_open = function(_term)
          au.do_useraucmd(au.user_autocmds.TermIsOpen_User)
          vim.cmd('startinsert!')
        end,
      })
    end,
    init = function()
      local nvim_buf_set_keymap = vim.keymap.set
      _G._plugin_set_terminal_keymaps = vim.schedule_wrap(function()
        if vim.bo.filetype == 'fzf' then
          return
        end
        local Terminal = require('toggleterm.terminal')

        local buffer = vim.api.nvim_get_current_buf()
        local _, current_term = Terminal.identify()
        if not current_term then
          return
        end
        -- local current_term_is_hidden = current_term.hidden
        local opts = { noremap = true, buffer = buffer, nowait = true }
        nvim_buf_set_keymap('t', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
        nvim_buf_set_keymap('t', '<C-S-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
      end)

      vim.cmd('autocmd! TermOpen term://* lua _plugin_set_terminal_keymaps()')
      --- open in project root.
      local misc_fts = {
        'NvimTree',
        'lazy',
        'fzf',
        'aerial',
      }
      vim.keymap.set('n', '<C-\\>', function()
        if vim.tbl_contains(misc_fts, vim.bo.filetype) then
          vim.notify('please open in normal buffer')
          return
        end
        if vim.v.count == 9 then
          vim.cmd([[9ToggleTerm direction=float]])
        else
          vim.cmd(vim.v.count .. [[ToggleTerm direction=horizontal]])
        end
      end, {
        desc = 'toggle term',
        silent = true,
      })
      --- open in workspace root.
      --- super+ctrl+/
      vim.keymap.set('n', vim.api.nvim_replace_termcodes('<C-S-\\>', true, true, false), function()
        if vim.tbl_contains(misc_fts, vim.bo.filetype) then
          vim.notify('please open in normal buffer')
          return
        end
        if vim.v.count == 9 then
          vim.cmd(([[9ToggleTerm direction=float dir=%s]]):format(vim.cfg.runtime__starts_cwd))
        else
          vim.cmd((vim.v.count .. [[ToggleTerm direction=horizontal dir=%s]]):format(vim.cfg.runtime__starts_cwd))
        end
      end, {
        desc = 'toggle term',
        silent = true,
      })
    end,
  },

  {
    'willothy/flatten.nvim',
    ft = { 'toggleterm', 'terminal', 'neo-term' },
    enabled = true,
    lazy = vim.env['NVIM'] == nil,
    priority = 1000,
    opts = function()
      local saved_terminal
      local is_neo_term = false
      return {
        one_per = {
          kitty = true,
        },
        callbacks = {
          should_block = function(argv)
            -- Note that argv contains all the parts of the CLI command, including
            -- Neovim's path, commands, options and files.
            -- See: :help v:argv

            -- In this case, we would block if we find the `-b` flag
            -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
            return vim.tbl_contains(argv, '-b') or vim.cfg.runtime__starts_as_gittool
          end,
          pre_open = function()
            if libutils.has_plugin('toggleterm.nvim') then
              local term = require('toggleterm.terminal')
              local termid = term.get_focused_id()
              saved_terminal = term.get(termid)
            end
            is_neo_term = vim.bo.filetype == 'neo-term'
          end,
          post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking and saved_terminal then
              -- vim.g.cmd_on_toggleterm_close = 'lua vim.api.nvim_set_current_win(' .. winnr .. ')'
              -- Hide the terminal while it's blocking
              saved_terminal:close()
            elseif not is_neo_term then
              -- If it's a normal file, just switch to its window
              vim.api.nvim_set_current_win(winnr)
            end
            if ft == 'gitcommit' or ft == 'gitrebase' then
              -- If the file is a git commit, create one-shot autocmd to delete it on write
              -- If you just want the toggleable terminal integration, ignore this bit and only use the
              -- code in the else block
              vim.api.nvim_create_autocmd('BufWritePost', {
                buffer = bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.api.nvim_buf_delete(bufnr, {})
                end),
              })
            end
          end,
          block_end = function()
            vim.schedule(function()
              if saved_terminal then
                saved_terminal:open()
                saved_terminal = nil
                vim.g.cmd_on_toggleterm_close = nil
              end
              if is_neo_term then
                is_neo_term = false
              end
            end)
          end,
        },
        window = {
          open = 'vsplit',
        },
      }
    end,
  },
})

plug({
  'nyngwang/NeoTerm.lua',
  cmd = { 'NeoTermToggle' },
  ft = 'terminal',
  keys = {
    {
      '<M-Tab>',
      function()
        vim.cmd('NeoTermToggle')
      end,
      desc = 'Enter neoterm',
    },
    {
      '<M-Tab>',
      '<cmd>NeoTermToggle<cr>',
      desc = 'Back to normal',
      mode = 't',
    },
  },
  config = function()
    require('neo-term').setup({
      exclude_filetype = { 'oil' },
      term_mode_hl = 'Normal',
    })
  end,
})
